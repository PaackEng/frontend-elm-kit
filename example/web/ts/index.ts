import 'regenerator-runtime/runtime';
import { Elm } from './src/Main.elm';
import * as auth from '../auth0/auth';
import { connectAppToAuth } from '../auth0/connect';

const rollbarToken = process.env.ROLLBAR_TOKEN;
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
const clientId = process.env.AUTH0_CLIENT_ID;
const domain = process.env.AUTH0_DOMAIN;
const audience = process.env.AUTH0_AUDIENCE;

const authClient = auth.getAuth0Client(clientId, domain, audience);
connectAppToAuth(app, authClient);
