import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import Environment from 'vite-plugin-environment';
import FullReload from 'vite-plugin-full-reload';
import Gzip from 'rollup-plugin-gzip';
import { preact } from '@preact/preset-vite';
import { resolve } from 'path';
import postcssImport from 'postcss-import';
import nested from 'postcss-nested';
import variables from 'postcss-variables';
import mixins from 'postcss-mixins';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    preact(),
    RubyPlugin(),
    Environment(['NODE_ENV', 'RAILS_ENV']),
    FullReload(
      ['config/routes.rb', 'app/views/**/*', '~app/views/**/*.jbuilder'],
      { delay: 200 },
    ),
  ],
  build: {
    rollupOptions: {
      plugins: [
        visualizer({
          filename: resolve(__dirname, 'stats.html'),
          gzipSize: true,
        }),
        Gzip(),
      ],
    },
  },
  resolve: {
    alias: {
      'react/jsx-runtime': 'preact/jsx-runtime',

      '~routes': resolve(__dirname, 'app/javascript/routes'),
      '~shared': resolve(__dirname, 'app/javascript/shared'),
      '~helpers': resolve(__dirname, 'app/javascript/helpers'),
    },
  },
  css: {
    postcss: {
      plugins: [nested(), postcssImport(), variables(), mixins()],
    },
  },
});
