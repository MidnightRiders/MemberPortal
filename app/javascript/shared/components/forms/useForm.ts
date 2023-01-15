import type { JSX } from 'preact';
import { useCallback, useMemo, useState } from 'preact/hooks';

type Setters<F extends Record<string, unknown>> = {
  [K in keyof F]: (value: string) => void;
}[keyof F][];

const useForm = <F extends Record<string, unknown>, R>(
  endpoint: `/${string}`,
  fields: F,
  onSubmit: (response: R) => void | Promise<void>,
  onError: (err: unknown) => void | Promise<void>,
  deps: unknown[] = [],
) => {
  const [values, setValues] = useState(fields);

  const setValue = useCallback(<K extends keyof F>(name: K, value: string) => {
    setValues((prev) => ({
      ...prev,
      [name]: typeof fields[name] === 'number' ? Number(value) : value,
    }));
  }, []);

  const setters: Setters<F> = useMemo(
    () =>
      (Object.keys(fields) as (keyof F)[]).map(
        (key) => (value: string) => setValue(key, value),
      ),
    [],
  );

  const handleSubmit = useCallback<JSX.GenericEventHandler<HTMLFormElement>>(
    async (e) => {
      e.preventDefault();

      try {
        const response = await fetch(endpoint, {
          body: JSON.stringify(values),
        });

        if (!response.ok) throw response;

        const body = await response.json();
        await onSubmit(await response.json());
      } catch (err) {
        await onError(err);
      }
    },
    [values, ...deps],
  );

  return [values, setters, handleSubmit] as const;
};

export default useForm;
