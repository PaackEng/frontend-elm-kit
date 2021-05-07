# frontend-elm-kit

A set of tools and integrations used by our Elm applications.

## Installing

Adding to a new project? Create a `.npmrc` file in its root with the following content:

```
@PaackEng:registry=https://npm.pkg.github.com
```

First time installing a private npm package from Paack's Github? [Setup your token](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#authenticating-with-a-personal-access-token).

Once the above is done, just install it:

```bash
$ yarn add @PaackEng/frontend-elm-kit
```

Add it as a source directory in the `elm.json`:

```diff
"type": "application",
"source-directories": [
  "src",
+ "node_modules/@PaackEng/frontend-elm-kit/elm"
],
```

## Integrating

In order to integrate this package into your project there are some extra changes that need to be made:

- Install all the [required packages](https://github.com/PaackEng/frontend-elm-kit/blob/main/example/elm.json) with exception of `elm/html`
- Make sure that the modules `Main.Model`, `Main.Msg`, `Main.Update`, `Effects.Local` and `Effects.Performer` all exist. Look at the example folder for a minimal setup
- Ensure that the ports `checkSession`, `login` and `logout` are all present
- Provide all the four seeds (`randomSeed1`, 2, 3 and 4) in the app's `Flags`
- Install the [Auth0 SPA SDK](https://github.com/auth0/auth0-spa-js)
- If your application isn't using `Effect` yet you can use `Auth.performEffects` to convert them on the fly

## Running the example

Navigate to the example folder, then create a `.env` file and fill in the values (you can copy them from any project where Auth0 is configured). After that you can run it with `yarn start`.
