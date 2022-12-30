import cookies from 'js-cookie';
import { COOKIE_NAME } from '~shared/contexts/auth';

export class FetchError extends Error {
  public readonly name = 'FetchError';

  public constructor(
    message: string,
    public readonly url: string,
    public readonly status: number,
  ) {
    super(message);
  }
}

export type FetchOptions = Omit<RequestInit, 'body' | 'method' | 'headers'> & {
  headers?: Record<string, string>;
};

export type Fetcher = <T>(
  url: string,
  data?: unknown,
  options?: FetchOptions,
) => Promise<T>;

const createFetch =
  (method: 'GET' | 'PATCH' | 'POST' | 'PUT' | 'DELETE'): Fetcher =>
  async <T extends unknown>(
    url: string,
    data?: unknown,
    options?: FetchOptions,
  ) => {
    try {
      let auth = options?.headers?.Authorization;
      if (!auth) {
        auth = cookies.get(COOKIE_NAME);
      }
      const authorization = auth ? { Authorization: auth } : {};
      const response = await fetch(url, {
        method,
        headers: {
          ...authorization,
          'X-CSRF-TOKEN':
            document
              .querySelector('meta[name="csrf-token"]')
              ?.getAttribute('content') ?? '',
          'Content-Type':
            options?.headers ?? data instanceof FormData
              ? 'multipart/form-data'
              : 'application/json',
          ...options?.headers,
        },
        body:
          data instanceof FormData || typeof data === 'string'
            ? data
            : JSON.stringify(data),
        ...options,
      });

      if (!response.ok) throw response;

      return response.json() as T;
    } catch (err) {
      let message = 'An unexpected error occurred';
      let status = 0;
      if (err instanceof Response) {
        try {
          const body = await err.json();
          ({ status } = err);
          if (
            typeof body === 'object' &&
            !Array.isArray(body) &&
            'message' in body
          ) {
            ({ message } = body);
          } else {
            message = err.statusText;
          }
        } catch {}
      }
      throw new FetchError(message, url, status);
    }
  };

export const get = createFetch('GET');
export const post = createFetch('POST');
export const put = createFetch('PUT');
export const patch = createFetch('PATCH');
export const del = createFetch('DELETE');
