import type { VNode } from 'preact';
import Paths from './paths';

export interface Route {
  <P>(props: P): VNode<unknown>;
  path: string;
  displayName?: string;
}

type Component<P> = (props: P) => VNode<unknown>;

interface MakeRoute {
  <P>(path: Paths, component: Component<P>): Route;
  <P>(path: Paths, displayName: string, component: Component<P>): Route;
  <P>(path: Paths, authed: false, component: Component<P>): Route;
  <P>(
    path: Paths,
    displayName: string,
    authed: false,
    component: Component<P>,
  ): Route;
}

const makeRoute: MakeRoute = <P>(
  path: Paths,
  ...args:
    | [Component<P>]
    | [string, Component<P>]
    | [false, Component<P>]
    | [string, false, Component<P>]
): Route => {
  let authed = true;
  let component: Route;
  if (typeof args[0] === 'function') {
    component = args[0] as Route;
  } else if (typeof args[1] === 'function') {
    component = args[1] as Route;
    if (typeof args[0] === 'string') component.displayName = args[0];
  } else {
    component = args[2] as Route;
    component.displayName = args[0];
    authed = args[1];
  }
  (component as Route).path = path;
  return component as Route;
};

export default makeRoute;
