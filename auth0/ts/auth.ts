type AuthError = { error: string; errorDescription: string };
type AuthSuccess = { token: string; userData: User | undefined };

function isSuccessUrl(searchParams: URLSearchParams): boolean {
  return searchParams.has('code') && searchParams.has('state');
}

function isFailureUrl(searchParams: URLSearchParams): boolean {
  return searchParams.has('error') && searchParams.has('error_description');
}

class ElmTreatableError extends Error {
  private tag: string;

  constructor(tag: string, message: string) {
    super(message);
    this.tag = tag;
  }

  public toJSON(): AuthError {
    return { error: this.tag, errorDescription: this.message };
  }
}

class PaackAuthError extends ElmTreatableError {
  constructor(err: AuthenticationError) {
    super('AUTH_FAILED', err.error_description);
  }
}

class NoSessionError extends ElmTreatableError {
  constructor() {
    super('NO_SESSION', 'User is not authenticated');
  }
}

class InvalidError extends ElmTreatableError {
  constructor(err: Error) {
    super('INVALID', err.message);
  }
}

/* IMMUTABLE FUNCTIONAL SOLUTION */

async function getAuth0Client(
  clientId: string,
  domain: string,
  audience: string,
): Promise<Auth0Client> {
  const ui_locales =
    window.navigator.userLanguage || window.navigator.language || 'es en';
  return createAuth0Client({
    domain,
    client_id: clientId,
    audience,
    useRefreshTokens: true,
    cacheLocation: 'localstorage',
    ui_locales,
  });
}

async function whenSuccess(client: Auth0Client): Promise<AuthSuccess> {
  const token = await client.getTokenSilently();
  const user = await client.getUser();
  return { token, userData: user };
}

async function checkRedirect(
  client: Auth0Client,
  autoLogin: boolean,
): Promise<AuthSuccess | 'NO_FEEDBACK'> {
  const searchParams = new URLSearchParams(window.location.search);
  if (isSuccessUrl(searchParams) || isFailureUrl(searchParams)) {
    try {
      await client.handleRedirectCallback();
      return await whenSuccess(client);
    } catch (err) {
      if (err instanceof AuthenticationError) {
        throw new PaackAuthError(err);
      } else {
        throw new InvalidError(err);
      }
    }
  }

  return checkSession(client, autoLogin);
}

async function checkSession(
  client: Auth0Client,
  autoLogin: boolean,
): Promise<AuthSuccess | 'NO_FEEDBACK'> {
  await client.checkSession();
  const isAuthenticated = await client.isAuthenticated();

  if (isAuthenticated) {
    return whenSuccess(client);
  } else if (autoLogin) {
    login(client);
    return 'NO_FEEDBACK';
  }

  throw new NoSessionError();
}

async function logout(client: Auth0Client): Promise<void> {
  client.logout({
    returnTo: window.location.origin,
  });
}

async function login(client: Auth0Client): Promise<void> {
  client.loginWithRedirect({
    redirect_uri: window.location.origin,
  });
}

export {
  AuthError,
  AuthSuccess,
  ElmTreatableError,
  InvalidError,
  NoSessionError,
  PaackAuthError,
  checkRedirect,
  checkSession,
  getAuth0Client,
  login,
  logout,
};
