module Effects.CommonSimulator exposing (effectPerform)

import Effects.Common exposing (CommonEffect(..), GraphqlRequestEffect, HttpRequestEffect)
import Graphql.Http as Graphql
import Graphql.Operation exposing (RootMutation, RootQuery)
import Http
import Json.Decode as Decode
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd
import SimulatedEffect.Http as ElmHttp
import SimulatedEffect.Navigation as Nav
import SimulatedEffect.Task as SimulatedTask
import Time


effectPerform : CommonEffect msg -> SimulatedEffect msg
effectPerform effect =
    case effect of
        Command _ ->
            SimulatedCmd.none

        LoopMsg msg ->
            loop msg

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

        HttpRequest data ->
            httpRequest data

        GraphqlHttpQuery data ->
            graphqlHttpQuery data

        GraphqlHttpMutation data ->
            graphqlHttpMutation data


loop : msg -> SimulatedEffect msg
loop msg =
    SimulatedTask.perform identity <| SimulatedTask.succeed msg


httpRequest : HttpRequestEffect msg -> SimulatedEffect msg
httpRequest data =
    ElmHttp.request
        { method = data.method
        , headers = []
        , url = data.url
        , body = ElmHttp.emptyBody
        , timeout = data.timeout
        , tracker = data.tracker
        , expect = ElmHttp.expectString data.expect
        }


graphqlHttpQuery : GraphqlRequestEffect RootQuery msg -> SimulatedEffect msg
graphqlHttpQuery data =
    ElmHttp.get { url = data.url, expect = graphqlExpect data }


graphqlHttpMutation : GraphqlRequestEffect RootMutation msg -> SimulatedEffect msg
graphqlHttpMutation data =
    ElmHttp.post
        { url = data.url
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
