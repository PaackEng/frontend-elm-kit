import { PortFromElm, PortToElm } from 'elm';

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
