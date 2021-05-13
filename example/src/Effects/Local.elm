module Effects.Local exposing
    ( LocalEffect(..)
    , mapLocalEffect
    )

import Paack.Auth.Main as Auth
import Paack.Rollbar.Effect as Rollbar


type LocalEffect msg
    = AuthEffect Auth.Effect
    | RollbarEffect Rollbar.Effect


mapLocalEffect : (a -> b) -> LocalEffect a -> LocalEffect b
mapLocalEffect _ effect =
    case effect of
        AuthEffect subEffect ->
            AuthEffect subEffect

        RollbarEffect subEffect ->
            RollbarEffect subEffect
