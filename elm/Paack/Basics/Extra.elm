module Paack.Basics.Extra exposing (flip)

import Paack.Basics

flip : (a -> b -> c) -> b -> a -> c
flip =
    Paack.Basics.flip
