import clsx from 'clsx';
import { useMemo } from 'preact/hooks';

import Column, { type ColSize } from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import Field, { type FieldProps } from './Field';

import styles from './styles.module.css';

interface Props {
  columns?: [ColSize, ColSize];
  label?: string;
  size: (FieldProps & { size?: ColSize })[];
}

const InputGroup = ({ columns: [labelCol, inputCol] = [4, 8], label, size }: Props) => {
  const fieldCols = useMemo<ColSize[]>(() => {
    if (size.some((f) => f.size)) {
      const takenCols = size.reduce((acc, f) => acc + (f.size || 0), 0);
      const remainingFields = size.reduce((c, f) => c + (f.size ? 0 : 1), 0);
      const remainingCols = 12 - takenCols;
      const remainingPerField = Math.round(remainingCols / remainingFields);
      return size.map((f) => (f.size ?? remainingPerField) as ColSize);
    }
    return size.map(() => Math.round(12 / size.length) as ColSize);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const required = useMemo(() => size.some((f) => f.required), [size]);

  return (
    <Row center>
      {label && (
        <Column size={labelCol}>
          <label className={clsx(styles.label, required && styles.required)} htmlFor={size[0].name}>
            {label}
            {required && <span title="required"> *</span>}
          </label>
        </Column>
      )}
      <Column size={inputCol} offset={label ? 0 : labelCol}>
        <Row>
          {size.map((props, i) => (
            <Column size={fieldCols[i]!}>
              <Field {...props} />
            </Column>
          ))}
        </Row>
      </Column>
    </Row>
  );
};

export default InputGroup;
