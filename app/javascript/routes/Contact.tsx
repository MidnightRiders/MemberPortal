import Button from '~shared/components/Button';
import Actions from '~shared/components/forms/Actions';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import makeRoute from '~shared/makeRoute';
import Paths from '~shared/paths';

const Contact = makeRoute(Paths.ContactUs, () => (
  <Row>
    <Column columns={4}>
      <h2 className="white">Contact Us</h2>
    </Column>
    <Column columns={8}>
      <Block>
        <Actions columns={[0, 12]} expand>
          <Button
            leftIcon="envelope"
            as="a"
            href="mailto:info@midnightriders.com"
          >
            General Inquiries
          </Button>
          <Button
            ghost
            leftIcon="envelope"
            as="a"
            href="mailto:membership@midnightriders.com"
          >
            Membership Inquiries
          </Button>
          <Button
            ghost
            leftIcon="at"
            as="a"
            href="mailto:member-portal-support@midnightriders.com"
            secondary
          >
            Member Portal Inquiries
          </Button>
        </Actions>
      </Block>
    </Column>
  </Row>
));

export default Contact;
