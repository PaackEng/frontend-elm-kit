module Paack.Return exposing
    ( Return
    , singleton, map, flipMap
    , withEffect, withEffects
    , andThen
    )

{-|

@docs Return


# Model-related

@docs singleton, map, flipMap


# Effect-related

@docs withEffect, withEffects


# Combine

@docs andThen

-}

import Paack.Effects as Effects exposing (Effects)


type alias Return msg model =
    ( model, Effects msg )


map : (a -> b) -> Return msg a -> Return msg b
map f ( model, effect ) =
    ( f model, effect )


flipMap : (a -> b -> c) -> b -> Return msg a -> Return msg c
flipMap f oldModel ( subModel, effect ) =
    ( f subModel oldModel, effect )


andThen : (a -> Return msg b) -> Return msg a -> Return msg b
andThen f ( model, effect ) =
    let
        ( model_, effect_ ) =
            f model
    in
    ( model_
    , Effects.batch [ effect, effect_ ]
    )


singleton : model -> Return msg model
singleton a =
    ( a, Effects.none )


withEffect : Effects msg -> Return msg a -> Return msg a
withEffect effect_ ( model, effect ) =
    ( model, Effects.batch [ effect, effect_ ] )


withEffects : List (Effects msg) -> Return msg a -> Return msg a
withEffects effect_ ( model, effect ) =
    ( model, Effects.batch (effect :: effect_) )
