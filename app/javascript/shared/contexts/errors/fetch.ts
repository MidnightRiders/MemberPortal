import { captureException } from '@sentry/browser';
import LogRocket from 'logrocket';
import { useCallback } from 'preact/hooks';

import {
  del,
  Fetcher,
  FetchError,
  FetchOptions,
  get,
  patch,
  post,
  put,
} from '~helpers/fetch';

import { useAuthCtx } from '../auth';

import { ErrorOptions, useErrorsCtx } from '.';

export interface Options extends ErrorOptions {
  capture?: boolean | ((err: unknown) => boolean);
  customMessage?: (err: unknown) => string;
  ignore?: boolean | ((err: unknown) => boolean);
}

export interface FetchHook {
  (name: string): <T>(
    url: string,
    data?: unknown,
    options?: FetchOptions,
  ) => Promise<T | false>;
  (name: string, options: Options, deps: unknown[]): <T>(
    url: string,
    data?: unknown,
    options?: FetchOptions,
  ) => Promise<T | false>;
}

const createFetchHook =
  (fetcher: Fetcher): FetchHook =>
  (
    name: string,
    { local, flash, capture, customMessage, ignore = false }: Options = {},
    deps: unknown[] = [],
  ) => {
    const { addError } = useErrorsCtx();
    const { jwt, setJwt } = useAuthCtx();

    return useCallback(
      async <T>(url: string, data?: unknown, opts?: FetchOptions) => {
        try {
          const fetchOptions: FetchOptions = opts ?? {};
          if (jwt) {
            fetchOptions.headers ??= {};
            fetchOptions.headers.Authorization = `Bearer ${jwt}`;
          }
          const resp = await fetcher<T & { jwt?: string | null }>(
            url,
            data,
            fetchOptions,
          );
          const { jwt: newJwt, ...body } = resp;
          if (newJwt !== undefined) setJwt(newJwt);
          return body as T;
        } catch (err) {
          if (
            ignore === false ||
            (typeof ignore === 'function' && !ignore(err))
          ) {
            const message = customMessage?.(err) ?? (err as FetchError).message;
            addError(name, message, { flash, local });
            if (
              capture === true ||
              (typeof capture === 'function' && capture(err))
            ) {
              LogRocket.captureException(err as Error, {
                extra: { name, url },
              });
              captureException(err, { extra: { name, url } });
            }
          }
          return false;
        }
      },
      [...deps, addError, jwt, setJwt], // eslint-disable-line react-hooks/exhaustive-deps
    );
  };

export const useGet = createFetchHook(get);
export const usePost = createFetchHook(post);
export const usePatch = createFetchHook(patch);
export const usePut = createFetchHook(put);
export const useDel = createFetchHook(del);
