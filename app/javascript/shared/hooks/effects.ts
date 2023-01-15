import { useEffect, useRef } from 'preact/hooks';

export const useOnMount = (
  callback: () => void | Promise<void> | (() => void),
) => {
  useEffect(() => {
    const resp = callback();
    if (typeof resp === 'function') return resp;
    return undefined;
  }, []); // eslint-disable-line react-hooks/exhaustive-deps
};

export const useOnUpdate = (
  callback: () => undefined | (() => undefined),
  deps: unknown[],
) => {
  const isInitialMount = useRef(true);
  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false;
      return undefined;
    }
    return callback();
  }, deps); // eslint-disable-line react-hooks/exhaustive-deps
};
