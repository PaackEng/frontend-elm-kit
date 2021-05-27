module Paack.Return exposing
    ( Return
    , singleton, map, flipMap
    , withEffect, withEffects
    , withGlobalEffect, withGlobalEffects
    , andThen
    )

{-|

@docs Return


# Model-related

@docs singleton, map, flipMap


# Effect-related

@docs withEffect, withEffects


# GlobalEffect-related

@docs withGlobalEffect, withGlobalEffects


# Combine

@docs andThen

-}

import Global.Effect as Effect exposing (Effect)
import Global.Msg as Global


type alias Return msg model =
    ( model, Effect msg, Effect Global.Msg )


map : (a -> b) -> Return msg a -> Return msg b
map f ( model, effect, globalEffect ) =
    ( f model, effect, globalEffect )


flipMap : (a -> b -> c) -> b -> Return msg a -> Return msg c
flipMap f oldModel ( subModel, effect, globalEffect ) =
    ( f subModel oldModel, effect, globalEffect )


andThen : (a -> Return msg b) -> Return msg a -> Return msg b
andThen f ( model, effect, globalEffect ) =
    let
        ( model_, effect_, globalEffect_ ) =
            f model
    in
    ( model_
    , Effect.batch [ effect, effect_ ]
    , Effect.batch [ globalEffect, globalEffect_ ]
    )


singleton : model -> Return msg model
singleton a =
    ( a, Effect.none, Effect.none )


withEffect : Effect msg -> Return msg a -> Return msg a
withEffect effect_ ( model, effect, globalEffect ) =
    ( model, Effect.batch [ effect, effect_ ], globalEffect )


withEffects : List (Effect msg) -> Return msg a -> Return msg a
withEffects effect_ ( model, effect, globalEffect ) =
    ( model, Effect.batch (effect :: effect_), globalEffect )


withGlobalEffect : Effect Global.Msg -> Return msg a -> Return msg a
withGlobalEffect globalEffect_ ( model, effect, globalEffect ) =
    ( model, effect, Effect.batch [ globalEffect, globalEffect_ ] )


withGlobalEffects : List (Effect Global.Msg) -> Return msg a -> Return msg a
withGlobalEffects globalEffect_ ( model, effect, globalEffect ) =
    ( model, effect, Effect.batch (globalEffect :: globalEffect_) )
