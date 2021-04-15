# Paack's Auth0 Elm Library

## Why is this separated?

Because in the future we want to re-use it across projects.

## Tips

- You must always implement `Auth.Main.update` otherwise elm-compiler's dead-code elimination will strip the ports away.
