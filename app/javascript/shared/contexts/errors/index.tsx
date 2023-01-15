import { captureException } from '@sentry/browser';
import LogRocket from 'logrocket';
import { createContext, FunctionComponent } from 'preact';
import {
  useCallback,
  useContext,
  useErrorBoundary,
  useMemo,
  useState,
} from 'preact/hooks';

import { noop } from '~helpers/utils';

import ErrorDisplay from './ErrorDisplay';

import styles from './styles.module.css';

interface Err {
  local: boolean;
  message: string;
  timestamp: number;
}

export interface ErrorOptions {
  flash?: number | undefined;
  local?: boolean | undefined;
}

interface ErrorsContext {
  errors: Record<string, Err[]>;

  addError: (key: string, message: string, opts?: ErrorOptions) => void;
  getError: (key: string) => string | null;
  getErrors: (key: string) => string[];
}

const ErrorsCtx = createContext<ErrorsContext>({
  errors: {},

  addError: noop,
  getError: () => null,
  getErrors: () => [],
});

export const useErrorsCtx = () => useContext(ErrorsCtx);

export const ErrorsProvider: FunctionComponent = ({ children }) => {
  const [errors, setErrors] = useState<Record<string, Err[]>>({});

  const addError = useCallback(
    (
      key: string,
      message: string,
      { flash = 5_000, local = false }: ErrorOptions = {},
    ) => {
      const err: Err = { local, message, timestamp: Date.now() };
      setErrors((prev) => ({
        ...prev,
        [key]: [...(prev[key] ?? []), err],
      }));

      if (!flash) return;

      setTimeout(() => {
        setErrors((prev) => {
          const errs = prev[key];
          if (!errs) return prev;

          const newErrs = errs.filter((e) => e !== err);
          if (newErrs.length === errs.length) return prev;

          if (!newErrs.length) {
            const { [key]: _, ...rest } = prev;
            return rest;
          }

          return {
            ...prev,
            [key]: newErrs,
          };
        });
      }, flash);
    },
    [],
  );

  useErrorBoundary((err, errInfo) => {
    const message: string =
      err && 'message' in err
        ? (err.message as string)
        : 'An unexpected application error was encountered';
    captureException(err, { extra: { ...errInfo, message } });
    LogRocket.captureException(err, { extra: { ...errInfo, message } });
    addError('global', message, { flash: 0 });
  });

  const getError = useCallback(
    (key: string) => {
      const errs = errors[key];
      return errs?.[errs.length - 1]?.message ?? null;
    },
    [errors],
  );

  const getErrors = useCallback(
    (key: string) => {
      const errs = errors[key];
      return errs?.map((err) => err.message) ?? [];
    },
    [errors],
  );

  const sortedErrors = useMemo(
    () =>
      Object.entries(errors)
        .reduce<(Err & { origin: string })[]>(
          (acc, [key, errs]) => [
            ...acc,
            ...errs
              .filter(({ local }) => !local)
              .map((err) => ({ ...err, origin: key })),
          ],
          [],
        )
        .sort((a, b) => a.timestamp - b.timestamp),
    [errors],
  );

  const value = useMemo(
    () => ({ errors, addError, getError, getErrors }),
    [errors, addError, getError, getErrors],
  );

  return (
    <ErrorsCtx.Provider value={value}>
      {!!sortedErrors.length && (
        <div className={styles.errors}>
          {sortedErrors.map(({ message, origin, timestamp }) => (
            <ErrorDisplay
              key={`${message}-${timestamp}`}
              message={message}
              origin={origin}
            />
          ))}
        </div>
      )}
      {children}
    </ErrorsCtx.Provider>
  );
};
