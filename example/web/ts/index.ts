import { Elm } from '../../src/Main.elm';
import * as auth from '@PaackEng/frontend-elm-kit/auth0/auth';
import { connectAppToAuth } from '@PaackEng/frontend-elm-kit/auth0/connect';

const gitDescribe = env_GIT_DESCRIBE;
const rollbarToken = env_ROLLBAR_TOKEN;
const seeds = Array.from(crypto.getRandomValues(new Uint32Array(4)));
const app = Elm.Main.init({
  node: document.getElementById('main'),
  flags: {
    gitDescribe,
    randomSeed1: seeds[0],
    randomSeed2: seeds[1],
    randomSeed3: seeds[2],
    randomSeed4: seeds[3],
    rollbarToken,
    mixpanelToken: '',
    mixpanelAnonId: null,
  },
});
const clientId = env_AUTH0_CLIENT_ID;
const domain = env_AUTH0_DOMAIN;
const audience = env_AUTH0_AUDIENCE;

const authClient = auth.getAuth0Client(clientId, domain, audience);
connectAppToAuth(app, authClient);
