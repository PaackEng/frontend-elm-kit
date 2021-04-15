import { Elm } from '../../src/Main.elm';
import 'regenerator-runtime/runtime';
import * as auth from '../../auth0/ts/auth';
import 'paack-ui-assets/js/paackSvgIconSprite.js';
import 'paack-ui-assets/js/ellipsizableText.js';
import { connectAppToAuth } from './auth';
import '@webcomponents/webcomponentsjs/custom-elements-es5-adapter';
import '@google-web-components/google-map';

if (!process.env.PROJ_AUTH0_CLIENT_ID || !process.env.PROJ_GOOGLE_MAPS_KEY) {
  const message =
    'The developer forgot to set either:\n' +
    '* the Auth0 client id;\n' +
    '* the Google Maps key in the environment\n' +
    'in the environment.';
  alert(message);
  throw new Error(message);
}

const environment = process.env.PROJ_ENV || 'development';
const language: string | null =
  window.navigator.userLanguage || window.navigator.language || null;

const googleMapsKey = process.env.PROJ_GOOGLE_MAPS_KEY;

const authClientId = process.env.PROJ_AUTH0_CLIENT_ID;
const authDomain =
  process.env.PROJ_AUTH0_DOMAIN || 'paack-hq-sandbox.eu.auth0.com';
const authAudience = process.env.PROJ_AUTH0_AUDIENCE || '';

const mainNode = document.getElementById('main');
if (!(mainNode instanceof Node)) {
  const message = 'Invalid HTML page.';
  alert(message);
  throw new Error(message);
}

const app = Elm.Main.init({
  node: mainNode,
  flags: {
    environment,
    language,
    googleMapsKey,
    innerWidth: window.innerWidth,
    innerHeight: window.innerHeight,
  },
});

const authClient = auth.getAuth0Client(authClientId, authDomain, authAudience);
connectAppToAuth(app, authClient, true);
