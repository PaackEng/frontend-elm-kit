module Effects.Local exposing
    ( LocalEffect(..)
    , mapLocalEffect
    )

import Paack.Auth.Main as Auth


type LocalEffect msg
    = AuthEffect Auth.Effect


mapLocalEffect : (a -> b) -> LocalEffect a -> LocalEffect b
mapLocalEffect _ effect =
    case effect of
        AuthEffect subEffect ->
            AuthEffect subEffect
