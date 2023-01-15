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
      console.debug('takenCols', takenCols);
      const remainingFields = fields.reduce(
        (c, f) => c + (f.columns ? 0 : 1),
        0,
      );
      console.debug('remainingFields', remainingFields);
      const remainingCols = 12 - takenCols;
      console.debug('remainingCols', remainingCols);
      const remainingPerField = Math.round(remainingCols / remainingFields);
      return fields.map((f) => f.columns ?? remainingPerField);
    }
    return fields.map(() => Math.round(12 / fields.length));
  }, []);

  const required = useMemo(() => fields.some((f) => f.required), [fields]);

  return (
    <Row center>
      {label && (
        <Column columns={labelCol}>
          <label
            class={clsx(styles.label, required && styles.required)}
            for={fields[0].name}
          >
            {label}
            {required && <span title="required"> *</span>}
          </label>
        </Column>
      )}
      <Column columns={inputCol} offset={label ? 0 : labelCol}>
        <Row>
          {fields.map((props, i) => (
            <Column columns={fieldCols[i]!}>
              <Field {...props} />
            </Column>
          ))}
        </Row>
      </Column>
    </Row>
  );
};

export default InputGroup;
