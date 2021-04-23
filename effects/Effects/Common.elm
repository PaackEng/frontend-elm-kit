module Effects.Common exposing
    ( CommonEffect(..), mapCommonEffect
    , cmd, loopMsg
    , pushUrl, replaceUrl, timeHere, domGetElement, domSetViewportOf
    , uuidGenerator, httpRequest, paackUI
    , GraphqlRequestEffect, HttpRequestEffect, graphqlQuery, graphqlMutation
    )

{-|


# Types

@docs CommonEffect, mapCommonEffect


# Common Effectss

@docs cmd, loopMsg
@docs pushUrl, replaceUrl, timeHere, domGetElement, domSetViewportOf
@docs uuidGenerator, httpRequest, paackUI
@docs GraphqlRequestEffect, HttpRequestEffect, graphqlQuery, graphqlMutation

-}

import Browser.Dom as Dom
import Graphql.Http as Graphql
import Graphql.Http.GraphqlError as GraphqlError
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet(..))
import Http as ElmHttp
import Json.Decode as Decode exposing (Decoder, Value)
import Remote.Response as Response exposing (GraphqlHttpResponse)
import Time
import UI.Analytics as UI
import UI.Effect as UI
import UUID exposing (UUID, decoder)


type CommonEffect msg
    = Command (Cmd msg)
    | LoopMsg msg
    | PushUrl String
    | ReplaceUrl String
    | TimeHere (Time.Zone -> msg)
    | UUIDGenerator (UUID -> msg)
    | DomGetElement (Result Dom.Error Dom.Element -> msg) String
    | DomSetViewportOf (Result Dom.Error () -> msg) String Float Float
    | HttpRequest (HttpRequestEffect msg)
    | GraphqlHttpQuery (GraphqlRequestEffect RootQuery msg)
    | GraphqlHttpMutation (GraphqlRequestEffect RootMutation msg)


type alias HttpRequestEffect msg =
    { method : String
    , headers : List ElmHttp.Header
    , url : String
    , body : ElmHttp.Body
    , timeout : Maybe Float
    , tracker : Maybe String
    , expect : Result ElmHttp.Error String -> msg
    }


type alias GraphqlRequestEffect operation msg =
    { toMsgFn : Result (Graphql.Error Value) Value -> msg
    , selection : SelectionSet Value operation
    , extraHeaders : List ( String, String )
    , url : String
    }


mapCommonEffect : (a -> b) -> CommonEffect a -> CommonEffect b
mapCommonEffect fn effect =
    case effect of
        Command command ->
            Command <| Cmd.map fn command

        LoopMsg msg ->
            LoopMsg <| fn msg

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        TimeHere toMsg ->
            TimeHere <| toMsg >> fn

        UUIDGenerator toMsg ->
            UUIDGenerator <| toMsg >> fn

        DomGetElement toMsg idAttribute ->
            DomGetElement (toMsg >> fn) idAttribute

        DomSetViewportOf toMsg parent x y ->
            DomSetViewportOf (toMsg >> fn) parent x y

        HttpRequest data ->
            HttpRequest
                { method = data.method
                , headers = data.headers
                , url = data.url
                , body = data.body
                , timeout = data.timeout
                , tracker = data.tracker
                , expect = data.expect >> fn
                }

        GraphqlHttpQuery data ->
            GraphqlHttpQuery
                { url = data.url
                , extraHeaders = data.extraHeaders
                , toMsgFn = data.toMsgFn >> fn
                , selection = data.selection
                }

        GraphqlHttpMutation data ->
            GraphqlHttpMutation
                { url = data.url
                , extraHeaders = data.extraHeaders
                , toMsgFn = data.toMsgFn >> fn
                , selection = data.selection
                }


cmd : Cmd msg -> CommonEffect msg
cmd =
    Command


pushUrl : String -> CommonEffect msg
pushUrl =
    PushUrl


replaceUrl : String -> CommonEffect msg
replaceUrl =
    ReplaceUrl


loopMsg : msg -> CommonEffect msg
loopMsg =
    LoopMsg


uuidGenerator : (UUID -> msg) -> CommonEffect msg
uuidGenerator =
    UUIDGenerator


timeHere : (Time.Zone -> msg) -> CommonEffect msg
timeHere =
    TimeHere


domSetViewportOf : (Result Dom.Error () -> msg) -> String -> Float -> Float -> CommonEffect msg
domSetViewportOf =
    DomSetViewportOf


domGetElement : (Result Dom.Error Dom.Element -> msg) -> String -> CommonEffect msg
domGetElement =
    DomGetElement


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
    -> CommonEffect msg
httpRequest ({ expect, decoder } as data) =
    let
        decode =
            Decode.decodeString decoder
                >> Result.mapError (Decode.errorToString >> ElmHttp.BadBody)
    in
    HttpRequest
        { method = data.method
        , headers = data.headers
        , url = data.url
        , body = data.body
        , timeout = data.timeout
        , tracker = data.tracker
        , expect = Result.andThen decode >> expect
        }


graphqlQuery :
    { url : String
    , extraHeaders : List ( String, String )
    , toMsgFn : GraphqlHttpResponse customError decodesTo -> msg
    }
    -> SelectionSet (Result customError decodesTo) RootQuery
    -> CommonEffect msg
graphqlQuery config (SelectionSet selector decoder) =
    GraphqlHttpQuery
        { toMsgFn =
            Result.mapError (graphqlFailure decoder)
                >> Result.andThen (graphqlDecode decoder)
                >> Response.graphqlHttpToMsg config.toMsgFn
        , selection =
            SelectionSet selector Decode.value
        , extraHeaders = config.extraHeaders
        , url = config.url
        }


graphqlMutation :
    { url : String
    , extraHeaders : List ( String, String )
    , toMsgFn : GraphqlHttpResponse customError decodesTo -> msg
    }
    -> SelectionSet (Result customError decodesTo) RootMutation
    -> CommonEffect msg
graphqlMutation config (SelectionSet selector decoder) =
    GraphqlHttpMutation
        { toMsgFn =
            Result.mapError (graphqlFailure decoder)
                >> Result.andThen (graphqlDecode decoder)
                >> Response.graphqlHttpToMsg config.toMsgFn
        , selection =
            SelectionSet selector Decode.value
        , extraHeaders = config.extraHeaders
        , url = config.url
        }


paackUI : (UI.Analytics -> ()) -> UI.Effect msg -> List (CommonEffect msg)
paackUI _ =
    let
        handler effect =
            case effect of
                UI.MsgToCmd msg ->
                    List.singleton <| loopMsg msg

                UI.Analytics _ ->
                    -- mixpanelEnqueue <| analyticsToEffect analytics
                    []
    in
    List.map handler >> List.concat


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b



-- We need to decode it locally, so we have "Value" in LocalEffects


graphqlDecode :
    Decoder (Result error value)
    -> Value
    -> Result (Graphql.RawError parsed Graphql.HttpError) (Result error value)
graphqlDecode decoder value =
    value
        |> Decode.decodeValue decoder
        |> Result.mapError (Graphql.BadPayload >> Graphql.HttpError)


graphqlFailure :
    Decoder (Result error value)
    -> Graphql.RawError Value httpErr
    -> Graphql.RawError (Result error value) httpErr
graphqlFailure decoder error =
    case error of
        Graphql.GraphqlError (GraphqlError.ParsedData value) list ->
            graphqlDecode decoder value
                |> Result.map GraphqlError.ParsedData
                |> Result.withDefault (GraphqlError.UnparsedData value)
                |> flip Graphql.GraphqlError list

        Graphql.GraphqlError (GraphqlError.UnparsedData raw) list ->
            Graphql.GraphqlError (GraphqlError.UnparsedData raw) list

        Graphql.HttpError err ->
            Graphql.HttpError err
