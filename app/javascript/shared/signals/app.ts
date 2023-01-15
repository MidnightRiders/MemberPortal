import { signal } from '@preact/signals';

import { Match } from '~helpers/matches';

export const pageTitle = signal('');

export const nextRevsMatch = signal<Match | null>(null);
