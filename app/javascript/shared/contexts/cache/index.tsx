import { createContext, type FunctionComponent } from 'preact';
import { useCallback, useMemo, useState } from 'preact/hooks';

import { noop } from '~helpers/utils';

interface CacheGetter {
  <T>(key: string): T | null;
  <T>(key: string, defaultValue: T): T;
  <T>(key: string, cb: () => T | Promise<T>): T;
  (key: string): unknown;
}

interface CacheContext {
  cached: Record<string, unknown>;
  set: <T>(key: string, value: T) => void;
  get: CacheGetter;
}

const CacheCtx = createContext<CacheContext>({
  cached: {},
  set: noop,
  get: noop,
});

export const useCacheCtx = () => CacheCtx;

export const CacheProvider: FunctionComponent = ({ children }) => {
  const [cached, setCached] = useState<Record<string, unknown>>({});

  const set = useCallback((key: string, value: unknown) => {
    setCached((prev) => ({ ...prev, [key]: value }));
  }, []);

  const get: CacheGetter = useCallback(
    <T extends unknown>(key: string, orElse: T | (() => T | Promise<T>) | null = null) => {
      if (cached[key]) return cached[key] as T;
      if (typeof orElse === 'function') {
        const value = (orElse as () => T | Promise<T>)();
        if (value instanceof Promise) {
          value.then((v) => set(key, v));
        } else {
          set(key, orElse);
        }
        return null;
      }
      set(key, orElse);
      return orElse;
    },
    [cached, set],
  );

  const value = useMemo(() => ({ cached, set, get }), [cached, set, get]);

  return <CacheCtx.Provider value={value}>{children}</CacheCtx.Provider>;
};
