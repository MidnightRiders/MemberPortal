import Password from './Password';

import styles from './styles.module.css';

interface BaseFieldProps {
  name: string;
  setValue: (value: string) => void;
  value: string | number | null;
  required?: boolean;
}

type Autocomplete =
  | 'off'
  | 'on'
  | 'name'
  | 'honorific-prefix'
  | 'given-name'
  | 'additional-name'
  | 'family-name'
  | 'honorific-suffix'
  | 'nickname'
  | 'email'
  | 'username'
  | 'new-password'
  | 'current-password'
  | 'one-time-code'
  | 'organization-title'
  | 'organization'
  | 'street-address'
  | 'address-line1'
  | 'address-line2'
  | 'address-line3'
  | 'address-level4'
  | 'address-level3'
  | 'address-level2'
  | 'address-level1'
  | 'country'
  | 'country-name'
  | 'postal-code'
  | 'cc-name'
  | 'cc-given-name'
  | 'cc-additional-name'
  | 'cc-family-name'
  | 'cc-number'
  | 'cc-exp'
  | 'cc-exp-month'
  | 'cc-exp-year'
  | 'cc-csc'
  | 'cc-type'
  | 'transaction-currency'
  | 'transaction-amount'
  | 'language'
  | 'bday'
  | 'bday-day'
  | 'bday-month'
  | 'bday-year'
  | 'sex'
  | 'tel'
  | 'tel-country-code'
  | 'tel-national'
  | 'tel-area-code'
  | 'tel-local'
  | 'tel-extension'
  | 'impp'
  | 'url'
  | 'photo';

type BaseTextFieldProps = BaseFieldProps & {
  autocomplete?: Autocomplete;
  pattern?: string;
  placeholder?: string;
  minLength?: number;
  maxLength?: number;
};

export interface SimpleTextFieldProps extends BaseTextFieldProps {
  type?: 'text' | 'email' | 'tel' | 'url' | 'search';
}

export interface PasswordTextFieldProps extends BaseTextFieldProps {
  type: 'password';
}

export interface DateTextFieldProps extends BaseTextFieldProps {
  type: 'date' | 'datetime';
  min?: string;
  max?: string;
}

export interface NumberTextFieldProps extends BaseTextFieldProps {
  type: 'number';
  min?: number;
  max?: number;
}

export type TextFieldProps =
  | SimpleTextFieldProps
  | PasswordTextFieldProps
  | DateTextFieldProps
  | NumberTextFieldProps;

export interface TextareaFieldProps extends BaseTextFieldProps {
  type: 'textarea';
  rows?: number;
}

export interface SelectFieldProps extends BaseFieldProps {
  type: 'select';
  options: { label: string; value: string }[];
}

export type FieldProps = TextFieldProps | TextareaFieldProps | SelectFieldProps;

const Field = ({
  name,
  value,
  required = false,
  setValue,
  ...props
}: FieldProps) => {
  if (props.type === 'select') {
    const { options } = props;
    return (
      <select
        className={styles.select}
        name={name}
        id={name}
        value={value ?? ''}
        onInput={({ currentTarget: { value: v } }) => setValue(v)}
        required={required}
      >
        {options.map(({ label, value: v }) => (
          <option key={v} value={v}>
            {label}
          </option>
        ))}
      </select>
    );
  }

  if (props.type === 'textarea') {
    return (
      <textarea
        className={styles.textarea}
        name={name}
        id={name}
        value={value ?? ''}
        required={required}
        onInput={({ currentTarget: { value: v } }) => setValue(v)}
        rows={props.rows ?? 3}
        {...props}
      />
    );
  }

  if (props.type === 'password') {
    return (
      <Password
        name={name}
        value={value ?? ''}
        setValue={setValue}
        required={required}
        {...props}
      />
    );
  }

  return (
    <input
      className={styles.textInput}
      name={name}
      id={name}
      value={value ?? ''}
      required={required}
      onInput={({ currentTarget: { value: v } }) => setValue(v)}
      {...props}
    />
  );
};

export default Field;
