import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import Link from '~shared/components/Link';
import Paths from '~shared/paths';

const FourOhFour = () => (
  <Row>
    <Column columns={6} center>
      <Block>
        <h1>404</h1>
        <p>Page not found</p>
        <p>
          Return <Link href={Paths.Home}>Home</Link>, read the{' '}
          <Link href={Paths.FAQ}>FAQ</Link>, or{' '}
          <Link href={Paths.ContactUs}>Contact Us</Link>.
        </p>
      </Block>
    </Column>
  </Row>
);

export default FourOhFour;
