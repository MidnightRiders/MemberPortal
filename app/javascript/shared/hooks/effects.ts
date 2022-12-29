import { useEffect, useRef } from 'preact/hooks';

export const useOnMount = (
  callback: () => void | Promise<void> | (() => undefined),
) => {
  useEffect(() => {
    const resp = callback();
    if (typeof resp === 'function') return resp;
  }, []);
};

export const useOnUpdate = (
  callback: () => undefined | (() => undefined),
  deps: unknown[],
) => {
  const isInitialMount = useRef(true);
  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false;
    } else {
      return callback();
    }
  }, [deps]);
};
