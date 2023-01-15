import type { JSX } from 'preact';
import { useCallback, useMemo, useState } from 'preact/hooks';

import { useErrorsCtx } from '~shared/contexts/errors';

type Setters<F extends Record<string, unknown>> = {
  [K in keyof F]: (value: string) => void;
}[keyof F][];

export class FormSubmitError extends Error {
  public readonly name = 'FormSubmitError';
}

export type Field<T extends string | number = string | number> =
  | T
  | {
      optional?: true;
      type?: number extends T ? 'number' : 'string';
      value: T | null;
    };
type FieldType<F extends Field> = F extends Field<infer T> ? T : never;

type ValuesFromFields<T extends Record<string, Field>> = {
  [K in keyof T]: FieldType<T[K]>;
};

export const fieldIsOptional = (f: Field): boolean => {
  if (typeof f !== 'object') return false;
  return !!f.optional;
};

export const fieldIsEmpty = <F extends Field>(
  f: Field,
  value: F extends Field<infer T> ? T : never,
): boolean => {
  const isNumber = typeof f === 'object' && f.type === 'number';
  if (isNumber) {
    return value === null;
  }
  return !value;
};

interface UseForm {
  <R, F extends Record<string, Field<string | number>>>(
    endpoint: `/${string}`,
    fields: F,
    onSubmit: (response: R) => void | Promise<void>,
    deps?: unknown[],
  ): readonly [
    ValuesFromFields<typeof fields>,
    Setters<typeof fields>,
    JSX.GenericEventHandler<HTMLFormElement>,
  ];
}

const useForm: UseForm = <
  R,
  F extends Record<string, Field> = Record<string, Field<string | number>>,
>(
  endpoint: `/${string}`,
  fields: F,
  onSubmit: (response: R) => void | Promise<void>,
  deps: unknown[] = [],
) => {
  const { addError } = useErrorsCtx();

  const [values, setValues] = useState(
    () =>
      Object.fromEntries(
        Object.entries(fields).map(([key, field]) => [
          key,
          typeof field === 'object' ? field.value : field,
        ]),
      ) as ValuesFromFields<F>,
  );

  const setValue = useCallback(<K extends keyof F>(name: K, value: string) => {
    const field = fields[name];
    let coerced: FieldType<F[K]> | null;
    if (
      typeof field === 'number' ||
      (typeof field === 'object' &&
        (typeof field.value === 'number' || field.type === 'number'))
    ) {
      coerced = value === '' ? null : (Number(value) as FieldType<F[K]>);
    } else {
      coerced = value as FieldType<F[K]>;
    }
    setValues((prev) => ({
      ...prev,
      [name]: coerced,
    }));
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const setters: Setters<F> = useMemo(
    () =>
      (Object.keys(fields) as (keyof F)[]).map(
        (key) => (value: string) => setValue(key, value),
      ),
    [], // eslint-disable-line react-hooks/exhaustive-deps
  );

  const handleSubmit = useCallback<JSX.GenericEventHandler<HTMLFormElement>>(
    async (e) => {
      e.preventDefault();

      if (
        Object.entries(fields).some(
          ([key, field]) =>
            !fieldIsOptional(field) && fieldIsEmpty(field, values[key]),
        )
      ) {
        addError(endpoint, 'Error: missing required fields');
        return;
      }

      try {
        const response = await fetch(endpoint, {
          body: JSON.stringify(values),
          method: 'POST',
        });

        if (!response.ok) throw response;

        const body: R = await response.json();
        await onSubmit(body);
      } catch (err) {
        let message: string | undefined;
        if (err instanceof Response) {
          try {
            const body = await err.json();
            if (body.message) {
              message = `Error ${err.status} ${err.statusText}: ${body.message}`;
            }
          } catch {
            // noop
          }
          message ??= `Error: ${err.status} ${err.statusText}`;
        }
        addError(endpoint, message || 'An unexpected error occurred');
      }
    },
    [values, ...deps], // eslint-disable-line react-hooks/exhaustive-deps
  );

  return [values, setters, handleSubmit] as const;
};

export default useForm;
