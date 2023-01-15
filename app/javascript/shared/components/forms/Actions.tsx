import clsx from 'clsx';
import type { FunctionComponent } from 'preact';

import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

import styles from './styles.module.css';

const Actions: FunctionComponent<{
  columns?: [number, number];
  expand?: true;
}> = ({ children, columns: [offset, cols] = [4, 8], expand }) => (
  <Row center>
    <Column
      class={clsx(styles.actions, expand && styles.expand)}
      columns={cols}
      offset={offset}
    >
      {children}
    </Column>
  </Row>
);

export default Actions;
