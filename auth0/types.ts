import { User } from '@auth0/auth0-spa-js';

export type AuthPorts = {
  checkSession: PortFromElm<void>;
  login: PortFromElm<void>;
  logout: PortFromElm<void>;
  authResult: PortToElm<AuthResult>;
};

export type Config = {
  checkSessionOnStart: boolean;
  whenNotAuthenticated: 'FORCE_LOGIN' | 'RETURN_ERROR';
};

export type AuthError = { error: string; errorDescription: string };
export type AuthSuccess = { token: string; userData: User | undefined };
export type AuthResult = AuthError | AuthSuccess;
