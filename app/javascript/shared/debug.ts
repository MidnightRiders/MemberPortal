/* eslint-disable no-console */

export const debug = (...args: unknown[]) => {
  if (process.env.NODE_ENV === 'development') console.debug(...args);
};

export const warn = (...args: unknown[]) => {
  if (process.env.NODE_ENV === 'development') console.warn(...args);
};

export const error = (...args: unknown[]) => {
  if (process.env.NODE_ENV === 'development') console.error(...args);
};

export const table = (...args: unknown[]) => {
  if (process.env.NODE_ENV === 'development') console.table(...args);
};
