import clsx from 'clsx';
import { useCallback, useRef, useState } from 'preact/hooks';
import type { JSX } from 'preact';

import type { PasswordTextFieldProps } from './Field';

import styles from './styles.module.css';

const Password = ({
  type,
  name,
  value,
  setValue,
  required = false,
  ...props
}: PasswordTextFieldProps) => {
  const [showPassword, setShowPassword] = useState(false);
  const fieldRef = useRef<HTMLInputElement>(null);

  const toggleShow = useCallback<JSX.MouseEventHandler<HTMLButtonElement>>(
    (e) => {
      e.preventDefault();
      setShowPassword((v) => !v);
      fieldRef.current?.focus();
    },
    [],
  );

  return (
    <div class={styles.password}>
      <input
        class={styles.textInput}
        name={name}
        id={name}
        value={value}
        ref={fieldRef}
        required={required}
        onInput={({ currentTarget: { value } }) => setValue(value)}
        type={showPassword ? 'text' : 'password'}
        {...props}
      />
      <button
        type="button"
        onClick={toggleShow}
        title={showPassword ? 'Hide Password' : 'Show Password'}
      >
        <i
          class={clsx(
            'fa-regular',
            'fa-fw',
            showPassword ? 'fa-eye-slash' : 'fa-eye',
          )}
        />
      </button>
    </div>
  );
};

export default Password;
