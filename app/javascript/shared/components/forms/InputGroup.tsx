import clsx from 'clsx';
import { useMemo } from 'preact/hooks';

import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import Field, { FieldProps } from './Field';

import styles from './styles.module.css';

interface Props {
  columns?: [number, number];
  label?: string;
  fields: (FieldProps & { columns?: number })[];
}

const InputGroup = ({
  columns: [labelCol, inputCol] = [4, 8],
  label,
  fields,
}: Props) => {
  const fieldCols = useMemo(() => {
    if (fields.some((f) => f.columns)) {
      const takenCols = fields.reduce((acc, f) => acc + (f.columns || 0), 0);
      const remainingFields = fields.reduce(
        (c, f) => c + (f.columns ? 0 : 1),
        0,
      );
      const remainingCols = 12 - takenCols;
      const remainingPerField = Math.round(remainingCols / remainingFields);
      return fields.map((f) => f.columns ?? remainingPerField);
    }
    return fields.map(() => Math.round(12 / fields.length));
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const required = useMemo(() => fields.some((f) => f.required), [fields]);

  return (
    <Row center>
      {label && (
        <Column size={labelCol}>
          <label
            className={clsx(styles.label, required && styles.required)}
            htmlFor={fields[0].name}
          >
            {label}
            {required && <span title="required"> *</span>}
          </label>
        </Column>
      )}
      <Column size={inputCol} offset={label ? 0 : labelCol}>
        <Row>
          {fields.map((props, i) => (
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
