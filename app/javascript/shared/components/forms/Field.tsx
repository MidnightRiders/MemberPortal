import Password from './Password';
import styles from './styles.module.css';

interface BaseFieldProps {
  name: string;
  setValue: (value: string) => void;
  value: string | number;
  required?: boolean;
}

type BaseTextFieldProps = BaseFieldProps & {
  autocomplete?: string;
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
        class={styles.select}
        name={name}
        id={name}
        value={value}
        onInput={({ currentTarget: { value } }) => setValue(value)}
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
        class={styles.textarea}
        name={name}
        id={name}
        value={value}
        required={required}
        onInput={({ currentTarget: { value } }) => setValue(value)}
        rows={props.rows ?? 3}
        {...props}
      />
    );
  }

  if (props.type === 'password') {
    return (
      <Password
        name={name}
        value={value}
        setValue={setValue}
        required={required}
        {...props}
      />
    );
  }

  return (
    <input
      class={styles.textInput}
      name={name}
      id={name}
      value={value}
      required={required}
      onInput={({ currentTarget: { value } }) => setValue(value)}
      {...props}
    />
  );
};

export default Field;
