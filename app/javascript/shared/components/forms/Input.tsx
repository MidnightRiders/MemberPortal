import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import styles from './styles.module.css';

interface Props {
  autocomplete?: string;
  columns?: [number, number];
  label?: string;
  name: string;
  placeholder?: string;
  setValue: (value: string) => void;
  type?: string;
  value: string;
}

const Input = ({
  autocomplete,
  columns: [labelCol, inputCol] = [4, 8],
  label,
  name,
  placeholder,
  setValue,
  type = 'text',
  value,
}: Props) => (
  <Row center>
    {label && (
      <Column columns={labelCol}>
        <label class={styles.label} for={name}>
          {label}
        </label>
      </Column>
    )}
    <Column columns={inputCol} offset={label ? 0 : labelCol}>
      <input
        class={styles.textInput}
        type={type}
        name={name}
        id={name}
        value={value}
        onInput={({ currentTarget: { value } }) => setValue(value)}
        {...Object.fromEntries(
          [
            autocomplete && ['autocomplete', autocomplete],
            placeholder && ['placeholder', placeholder],
          ].filter(Boolean) as [string, string][],
        )}
      />
    </Column>
  </Row>
);

export default Input;
