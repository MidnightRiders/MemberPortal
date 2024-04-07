import { signal } from '@preact/signals';

import type { Match } from '~helpers/matches';

export const pageTitle = signal('');

export const nextRevsMatch = signal<Match | null>(null);
