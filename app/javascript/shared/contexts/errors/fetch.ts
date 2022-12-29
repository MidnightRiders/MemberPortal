import { useCallback } from 'preact/hooks';
import {
  Fetcher,
  FetchError,
  get,
  post,
  patch,
  put,
  del,
} from '~helpers/fetch';
import { useErrorsCtx } from './errors';

export interface Options {
  flash?: number;
}

export interface FetchHook {
  (name: string): <T>(
    url: string,
    data?: unknown,
    options?: Omit<RequestInit, 'body' | 'method'>,
  ) => Promise<T | false>;
  (name: string, options: Options, deps: unknown[]): <T>(
    url: string,
    data?: unknown,
    options?: Omit<RequestInit, 'body' | 'method'>,
  ) => Promise<T | false>;
}

const createFetchHook =
  (fetcher: Fetcher): FetchHook =>
  (name: string, options?: Options, deps: unknown[] = []) => {
    const { addError } = useErrorsCtx();

    return useCallback(
      async <T>(
        url: string,
        data?: unknown,
        opts?: Omit<RequestInit, 'body'>,
      ) => {
        try {
          const resp = await fetcher<T>(url, data, opts);
          return resp;
        } catch (err) {
          addError(name, (err as FetchError).message, options?.flash);
          return false;
        }
      },
      deps,
    );
  };

export const useGet = createFetchHook(get);
export const usePost = createFetchHook(post);
export const usePatch = createFetchHook(patch);
export const usePut = createFetchHook(put);
export const useDel = createFetchHook(del);
