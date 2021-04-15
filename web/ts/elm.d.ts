declare module '*/Main.elm' {
  import { ElmInstance } from 'elm';
  import { AuthPorts } from '../../auth0/ts/elm';

  const Elm: ElmInstance<AuthPorts>;
}
