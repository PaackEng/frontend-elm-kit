import { User } from '@auth0/auth0-spa-js';

type AuthPorts = {
  checkSession: PortFromElm<void>;
  login: PortFromElm<void>;
  logout: PortFromElm<void>;
  authResult: PortToElm<
    | { token: string; userData: User }
    | { error: string; errorDescription: string }
  >;
};

export { AuthPorts };
