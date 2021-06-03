# Paack's Firebase Elm Library

## Remote Config

Remote Config is a parameter storage that is used by some apps to toggle features and make visual changes without needing to deploy updates.

The suggested use is to send the parameters using ports and store them into `AppConfig`.

Example usage:

```ts
import firebase from 'firebase/app';
import { getConfigValue } from '@PaackEng/frontend-elm-kit/firebase/remoteConfig';

async function sendConfigs(elmApp, firebaseAppConfig) {
  const firebaseApp = firebase.initializeApp(firebaseAppConfig);
  const remoteConfig = firebaseApp.remoteConfig();

  await remoteConfig.fetchAndActivate();

  // read "exampleConfig" parameter as a json object
  const exampleConfig = await getConfigValue(
    remoteConfig,
    'exampleConfig',
    'object',
  );

  elmApp.ports.fromHostToElm.send({
    tag: 'RemoteConfig',
    data: { exampleConfig },
  });
}
```
