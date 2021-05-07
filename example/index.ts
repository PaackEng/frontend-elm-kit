import { Elm } from "./src/Main.elm";
import { connectAppToAuth } from "../auth0/connect";

const seeds = Array.from(crypto.getRandomValues(new Uint32Array(4)));
const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: {
    randomSeed1: seeds[0],
    randomSeed2: seeds[1],
    randomSeed3: seeds[2],
    randomSeed4: seeds[3],
  },
});
const clientId = process.env.AUTH0_CLIENT_ID;
const domain = process.env.AUTH0_DOMAIN;
const audience = process.env.AUTH0_AUDIENCE;

(async () => {
  const authClient = await createAuth0Client({
    domain,
    client_id: clientId,
    audience,
  });

  connectAppToAuth(app, authClient, true);
})();
