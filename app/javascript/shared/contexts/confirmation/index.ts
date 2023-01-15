/* eslint-disable import/prefer-default-export */
// TODO: implement a confirm context

export const useConfirm = () => async (message: string) =>
  // eslint-disable-next-line no-alert
  Promise.resolve(window.confirm(message));
