declare module 'postcss-variables' {
  import { Plugin } from 'postcss';
  const variables: (opts?: { globals?: unknown }) => Plugin;
  export default variables;
}
