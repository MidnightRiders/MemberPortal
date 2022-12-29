import { captureException } from '@sentry/browser';
import { captureException as captureLogrocket } from 'logrocket';
import { createContext, FunctionComponent } from 'preact';
import {
  useCallback,
  useContext,
  useErrorBoundary,
  useMemo,
  useState,
} from 'preact/hooks';
import { noop } from '~helpers/utils';

interface Err {
  message: string;
}

interface ErrorsContext {
  errors: Record<string, Err[]>;

  addError: (key: string, message: string, flash?: number | undefined) => void;
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

export const useError = (key: string) => useErrorsCtx().getError(key);

export const useErrors = (key: string) => useErrorsCtx().getErrors(key);

export const ErrorsProvider: FunctionComponent = ({ children }) => {
  const [errors, setErrors] = useState<Record<string, Err[]>>({});

  const addError = useCallback(
    (key: string, message: string, flash = 5_000) => {
      const err: Err = { message };
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
      'message' in err
        ? (err.message as string)
        : 'An unexpected application error was encountered';
    captureException(err, { extra: { ...errInfo, message } });
    captureLogrocket(err, { extra: { ...errInfo, message } });
    addError('global', message, 0);
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

  const value = useMemo(
    () => ({ errors, addError, getError, getErrors }),
    [errors, addError, getError, getErrors],
  );

  return <ErrorsCtx.Provider value={value}>{children}</ErrorsCtx.Provider>;
};
