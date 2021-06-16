module Paack.Effects exposing
    ( Effects, fromLocal
    , none, batch, map
    , cmd, loopMsg
    , pushUrl, replaceUrl, timeHere, domGetElement, domSetViewportOf
    , uuidGenerator, httpRequest, paackUI
    , graphqlQuery, graphqlMutation
    , Effect(..), apply
    )

{-|


# Effects type

@docs Effects, fromLocal


# Command-like

@docs none, batch, map


# Common Effectss

@docs cmd, loopMsg
@docs pushUrl, replaceUrl, timeHere, domGetElement, domSetViewportOf
@docs uuidGenerator, httpRequest, paackUI
@docs graphqlQuery, graphqlMutation


# For applying-only

@docs Effect, apply

-}

import Browser.Dom as Dom
import Effects.Local as Local exposing (LocalEffect, mapLocalEffect)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import Http as ElmHttp
import Json.Decode exposing (Decoder)
import Paack.Effects.Common as Common exposing (CommonEffect, mapCommonEffect)
import Remote.Response exposing (GraphqlHttpResponse)
import Time
import UI.Analytics as UI
import UI.Effect as UI
import UUID exposing (UUID)


type alias Effects msg =
    List (Effect msg)


type Effect msg
    = LocalEffect (Local.LocalEffect msg)
    | CommonEffect (Common.CommonEffect msg)


fromLocal : LocalEffect msg -> Effects msg
fromLocal =
    LocalEffect >> List.singleton


fromCommon : CommonEffect msg -> Effects msg
fromCommon =
    CommonEffect >> List.singleton


none : Effects msg
none =
    []


batch : List (Effects msg) -> Effects msg
batch =
    List.concat


map : (a -> b) -> Effects a -> Effects b
map =
    mapEffects >> List.map


apply : (Effect msg -> value -> value) -> value -> Effects msg -> value
apply =
    List.foldl


mapEffects : (a -> b) -> Effect a -> Effect b
mapEffects applier sideEffects =
    case sideEffects of
        LocalEffect effect ->
            LocalEffect <| mapLocalEffect applier effect

        CommonEffect effect ->
            CommonEffect <| mapCommonEffect applier effect



-- Common side effects


cmd : Cmd msg -> Effects msg
cmd =
    Common.cmd >> fromCommon


pushUrl : String -> Effects msg
pushUrl =
    Common.pushUrl >> fromCommon


replaceUrl : String -> Effects msg
replaceUrl =
    Common.replaceUrl >> fromCommon


loopMsg : msg -> Effects msg
loopMsg =
    Common.loopMsg >> fromCommon


uuidGenerator : (UUID -> msg) -> Effects msg
uuidGenerator =
    Common.uuidGenerator >> fromCommon


timeHere : (Time.Zone -> msg) -> Effects msg
timeHere =
    Common.timeHere >> fromCommon


domSetViewportOf : (Result Dom.Error () -> msg) -> String -> Float -> Float -> Effects msg
domSetViewportOf toMsg parent x y =
    Common.domSetViewportOf toMsg parent x y |> fromCommon


domGetElement : (Result Dom.Error Dom.Element -> msg) -> String -> Effects msg
domGetElement toMsg idAttribute =
    Common.domGetElement toMsg idAttribute |> fromCommon


domFocus : (Result Dom.Error Dom.Element -> msg) -> String -> Effects msg
domFocus toMsg idAttribute =
    Common.domFocus toMsg idAttribute |> fromCommon


httpRequest :
    { method : String
    , headers : List ElmHttp.Header
    , url : String
    , body : ElmHttp.Body
    , decoder : Decoder a
    , expect : Result ElmHttp.Error a -> msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Effects msg
httpRequest =
    Common.httpRequest >> fromCommon


graphqlQuery :
    { url : String
    , extraHeaders : List ( String, String )
    , toMsgFn : GraphqlHttpResponse customError decodesTo -> msg
    }
    -> SelectionSet (Result customError decodesTo) RootQuery
    -> Effects msg
graphqlQuery config selection =
    fromCommon <| Common.graphqlQuery config selection


graphqlMutation :
    { url : String
    , extraHeaders : List ( String, String )
    , toMsgFn : GraphqlHttpResponse customError decodesTo -> msg
    }
    -> SelectionSet (Result customError decodesTo) RootMutation
    -> Effects msg
graphqlMutation config selection =
    fromCommon <| Common.graphqlMutation config selection


paackUI : (UI.Analytics -> Effects msg) -> UI.Effect msg -> Effects msg
paackUI applier =
    let
        handler effect =
            case effect of
                UI.MsgToCmd msg ->
                    loopMsg msg

                UI.DomFocus msg id ->
                    domFocus msg id

                UI.Analytics analytics ->
                    applier analytics
    in
    List.map handler >> List.concat
