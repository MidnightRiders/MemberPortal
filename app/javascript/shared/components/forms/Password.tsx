import type { JSX } from 'preact';
import { useCallback, useRef, useState } from 'preact/hooks';

import Icon from '../Icon';

import type { PasswordTextFieldProps } from './Field';

import styles from './styles.module.css';

const Password = ({
  type: _t,
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
    <div className={styles.password}>
      <input
        className={styles.textInput}
        name={name}
        id={name}
        value={value ?? ''}
        ref={fieldRef}
        required={required}
        onInput={({ currentTarget: { value: v } }) => setValue(v)}
        type={showPassword ? 'text' : 'password'}
        {...props}
      />
      <button
        type="button"
        onClick={toggleShow}
        title={showPassword ? 'Hide Password' : 'Show Password'}
      >
        <Icon name={showPassword ? 'eye' : 'eye-slash'} />
      </button>
    </div>
  );
};

export default Password;
