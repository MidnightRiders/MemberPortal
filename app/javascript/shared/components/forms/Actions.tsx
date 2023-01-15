import type { FunctionComponent } from 'preact';

import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import styles from './styles.module.css';

const Actions: FunctionComponent<{ columns?: [number, number] }> = ({
  children,
  columns: [offset, cols] = [4, 8],
}) => (
  <Row center>
    <Column class={styles.actions} columns={cols} offset={offset}>
      {children}
    </Column>
  </Row>
);

export default Actions;
