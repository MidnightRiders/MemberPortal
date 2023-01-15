import clsx from 'clsx';

import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import Field, { FieldProps } from './Field';

import styles from './styles.module.css';

type Props = FieldProps & {
  columns?: [number, number];
  label?: string;
};

const Input = ({
  columns: [labelCol, inputCol] = [4, 8],
  label,
  ...props
}: Props) => (
  <Row center>
    {label && (
      <Column columns={labelCol}>
        <label
          className={clsx(styles.label, props.required && styles.required)}
          htmlFor={props.name}
        >
          {label}
          {props.required && <span title="required"> *</span>}
        </label>
      </Column>
    )}
    <Column columns={inputCol} offset={label ? 0 : labelCol}>
      <Field {...props} />
    </Column>
  </Row>
);

export default Input;
