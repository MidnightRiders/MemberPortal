import { forwardRef } from 'preact/compat';
import { Typography } from '@mui/material';
import type { PropsFor } from '@mui/system';

type TypographyProps = Omit<PropsFor<typeof Typography>, 'variant'>;

const typographyAlias = (variant: TypographyProps['variant']) =>
  forwardRef(({ children, ...props }: TypographyProps) => (
    <Typography variant={variant} {...props}>
      {children}
    </Typography>
  ));

export const H1 = typographyAlias('h1');
export const H2 = typographyAlias('h2');
export const H3 = typographyAlias('h3');
export const H4 = typographyAlias('h4');
export const H5 = typographyAlias('h5');
export const H6 = typographyAlias('h6');
export const Body1 = typographyAlias('body1');
export const Body2 = typographyAlias('body2');
export const Button = typographyAlias('button');
export const Caption = typographyAlias('caption');
export const Overline = typographyAlias('overline');
export const Subtitle1 = typographyAlias('subtitle1');
export const Subtitle2 = typographyAlias('subtitle2');
