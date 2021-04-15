import * as auth from '../../auth0/ts/auth';
import { Elm } from '../../src/Main.elm';

function connectAppToAuth(
  app: typeof Elm,
  authClient: Promise<Auth0Client>,
  authAutoLogin: boolean,
): void {
  /* The following function handles notifying Elm's app about possible failures and or success.
    It does not returns a feedback only when the user is redirected to the login page.
  */
  const callback = (
    lambda: (
      client: Auth0Client,
      autoLogin: boolean,
    ) => Promise<auth.AuthSuccess | 'NO_FEEDBACK'>,
  ) => async (): Promise<void> => {
    try {
      const result = await lambda(await authClient, authAutoLogin);
      if (result !== 'NO_FEEDBACK') app.ports.authResult.send(result);
    } catch (err: unknown) {
      if (err instanceof auth.ElmTreatableError)
        app.ports.authResult.send(err.toJSON());
      else throw err;
    }
  };

  app.ports.logout.subscribe(async () => auth.logout(await authClient));
  app.ports.login.subscribe(async () => auth.login(await authClient));
  app.ports.checkSession.subscribe(callback(auth.checkSession));

  callback(auth.checkRedirect)();
}

export { connectAppToAuth };
