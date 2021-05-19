import { Auth0Client } from '@auth0/auth0-spa-js';
import * as auth from './auth';
import { AuthPorts, Config } from './types';

export function connectAppToAuth(
  app: ElmApp<AuthPorts>,
  authClient: Promise<Auth0Client>,
  config: Config = { checkSessionOnStart: true, loginOnNoSession: false },
): void {
  /* The following function handles notifying Elm's app about possible failures and or success.
    It does not returns a feedback only when the user is redirected to the login page.
  */
  const withFeedback =
    (
      applier: (
        client: Auth0Client,
        autoLogin: boolean,
      ) => Promise<auth.AuthSuccess | 'NO_FEEDBACK'>,
    ) =>
    async (): Promise<void> => {
      try {
        const result = await applier(await authClient, config.loginOnNoSession);
        if (result !== 'NO_FEEDBACK') app.ports.authResult.send(result);
      } catch (err: unknown) {
        if (err instanceof auth.ElmTreatableError)
          app.ports.authResult.send(err.toJSON());
        else throw err;
      }
    };

  app.ports.logout.subscribe(async () => auth.logout(await authClient));
  app.ports.login.subscribe(async () => auth.login(await authClient));
  app.ports.checkSession.subscribe(withFeedback(auth.checkSession));

  if (config.checkSessionOnStart) withFeedback(auth.checkSession)();
}
