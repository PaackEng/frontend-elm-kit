module Effects.CommonPerformer exposing (effectPerform)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Effects.Common exposing (CommonEffect(..), GraphqlRequestEffect, HttpRequestEffect)
import Graphql.Http as Graphql
import Graphql.Http.GraphqlError as GraphqlError
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet(..))
import Http as ElmHttp exposing (Header)
import Json.Decode as Decode exposing (Decoder, Value)
import Remote.Response as Response exposing (GraphqlHttpResponse)
import Task exposing (Task)
import Time
import UI.Analytics as UI
import UI.Effect as UI
import UUID exposing (Seeds, UUID, decoder)


effectPerform : Nav.Key -> Seeds -> CommonEffect msg -> ( Seeds, Cmd msg )
effectPerform key seeds effect =
    case effect of
        Command command ->
            ( seeds
            , command
            )

        LoopMsg msg ->
            ( seeds
            , Task.perform identity <| Task.succeed msg
            )

        PushUrl str ->
            ( seeds
            , Nav.pushUrl key str
            )

        ReplaceUrl str ->
            ( seeds
            , Nav.replaceUrl key str
            )

        TimeHere toMsg ->
            ( seeds
            , Task.perform toMsg Time.here
            )

        UUIDGenerator toMsg ->
            uuidGenerator toMsg seeds

        DomGetElement toMsg idAttribute ->
            ( seeds
            , Task.attempt toMsg <| Dom.getElement idAttribute
            )

        DomSetViewportOf toMsg parent x y ->
            ( seeds
            , Task.attempt toMsg <| Dom.setViewportOf parent x y
            )

        HttpRequest data ->
            ( seeds
            , httpRequest data
            )

        GraphqlHttpQuery data ->
            ( seeds
            , graphqlHttpQuery data
            )

        GraphqlHttpMutation data ->
            ( seeds
            , graphqlHttpMutation data
            )


uuidGenerator : (UUID -> msg) -> Seeds -> ( Seeds, Cmd msg )
uuidGenerator toMsg seeds =
    let
        ( uuid, seeds_ ) =
            UUID.step seeds
    in
    ( seeds_
    , Task.perform identity <| Task.succeed (toMsg uuid)
    )


httpRequest : HttpRequestEffect msg -> Cmd msg
httpRequest data =
    ElmHttp.request
        { method = data.method
        , headers = data.headers
        , url = data.url
        , body = data.body
        , timeout = data.timeout
        , tracker = data.tracker
        , expect = ElmHttp.expectString data.expect
        }


graphqlHttpQuery : GraphqlRequestEffect RootQuery msg -> Cmd msg
graphqlHttpQuery data =
    List.foldl
        (\( key, value ) accu -> Graphql.withHeader key value accu)
        (Graphql.queryRequest data.url data.selection)
        data.extraHeaders
        |> Graphql.send data.toMsgFn


graphqlHttpMutation : GraphqlRequestEffect RootMutation msg -> Cmd msg
graphqlHttpMutation data =
    List.foldl
        (\( key, value ) accu -> Graphql.withHeader key value accu)
        (Graphql.mutationRequest data.url data.selection)
        data.extraHeaders
        |> Graphql.send data.toMsgFn
