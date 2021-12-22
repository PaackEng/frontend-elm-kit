module Paack.Effects.CommonSimulator exposing (effectPerform)

import Graphql.Http as Graphql
import Graphql.Operation exposing (RootMutation, RootQuery)
import Http
import Json.Decode as Decode
import Paack.Effects.Common exposing (CommonEffect(..), GraphqlRequestEffect, HttpRequestEffect)
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd
import SimulatedEffect.Http as ElmHttp
import SimulatedEffect.Navigation as Nav
import SimulatedEffect.Task as SimulatedTask
import Time


effectPerform : Int -> CommonEffect msg -> SimulatedEffect msg
effectPerform index effect =
    case effect of
        LoopMsg msg ->
            loop msg

        LoadUrl url ->
            Nav.load url

        PushUrl url ->
            Nav.pushUrl url

        ReplaceUrl url ->
            Nav.replaceUrl url

        TimeHere toMsg ->
            loop <| toMsg Time.utc

        UUIDGenerator _ ->
            SimulatedCmd.none

        DomGetElement _ _ ->
            SimulatedCmd.none

        DomSetViewportOf _ _ _ _ ->
            SimulatedCmd.none

        DomFocus _ _ ->
            SimulatedCmd.none

        HttpRequest data ->
            httpRequest index data

        GraphqlHttpQuery data ->
            graphqlHttpQuery index data

        GraphqlHttpMutation data ->
            graphqlHttpMutation index data


loop : msg -> SimulatedEffect msg
loop msg =
    SimulatedTask.perform identity <| SimulatedTask.succeed msg


httpRequest : Int -> HttpRequestEffect msg -> SimulatedEffect msg
httpRequest index data =
    ElmHttp.request
        { method = data.method
        , headers = []
        , url = data.url ++ "#i" ++ String.fromInt index
        , body = ElmHttp.emptyBody
        , timeout = data.timeout
        , tracker = data.tracker
        , expect = ElmHttp.expectString data.expect
        }


graphqlHttpQuery : Int -> GraphqlRequestEffect RootQuery msg -> SimulatedEffect msg
graphqlHttpQuery index data =
    ElmHttp.post
        { url = data.url ++ "#q" ++ String.fromInt index
        , body = ElmHttp.emptyBody
        , expect = graphqlExpect data
        }


graphqlHttpMutation : Int -> GraphqlRequestEffect RootMutation msg -> SimulatedEffect msg
graphqlHttpMutation index data =
    ElmHttp.post
        { url = data.url ++ "#m" ++ String.fromInt index
        , body = ElmHttp.emptyBody
        , expect = graphqlExpect data
        }


graphqlExpect : GraphqlRequestEffect selection msg -> ElmHttp.Expect msg
graphqlExpect data =
    ElmHttp.expectStringResponse data.toMsgFn <|
        \response ->
            case response of
                Http.BadUrl_ u ->
                    Err <| Graphql.HttpError <| Graphql.BadUrl u

                Http.Timeout_ ->
                    Err <| Graphql.HttpError <| Graphql.Timeout

                Http.NetworkError_ ->
                    Err <| Graphql.HttpError <| Graphql.NetworkError

                Http.BadStatus_ metadata body ->
                    Err <| Graphql.HttpError <| Graphql.BadStatus metadata body

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString (Decode.field "data" Decode.value) body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err <| Graphql.HttpError <| Graphql.BadPayload err
