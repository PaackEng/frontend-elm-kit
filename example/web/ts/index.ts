import { Elm } from '../../src/Main.elm';
import * as auth from '@PaackEng/frontend-elm-kit/auth0/auth';
import { connectAppToAuth } from '@PaackEng/frontend-elm-kit/auth0/connect';
import * as env from 'env';

const rollbarToken = env.ROLLBAR_TOKEN;
const seeds = Array.from(crypto.getRandomValues(new Uint32Array(4)));
const app = Elm.Main.init({
  node: document.getElementById('main'),
  flags: {
    randomSeed1: seeds[0],
    randomSeed2: seeds[1],
    randomSeed3: seeds[2],
    randomSeed4: seeds[3],
    rollbarToken,
    mixpanelToken: '',
    mixpanelAnonId: null,
  },
});
const clientId = env.AUTH0_CLIENT_ID;
const domain = env.AUTH0_DOMAIN;
const audience = env.AUTH0_AUDIENCE;

const authClient = auth.getAuth0Client(clientId, domain, audience);
connectAppToAuth(app, authClient);
