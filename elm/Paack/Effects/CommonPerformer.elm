module Paack.Effects.CommonPerformer exposing (effectPerform)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Graphql.Http as Graphql
import Graphql.Operation exposing (RootMutation, RootQuery)
import Http as ElmHttp
import Paack.Effects.Common exposing (CommonEffect(..), GraphqlRequestEffect, HttpRequestEffect)
import Task
import Time
import UUID exposing (Seeds, UUID)


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

        PushUrl url ->
            ( seeds
            , Nav.pushUrl key url
            )

        ReplaceUrl url ->
            ( seeds
            , Nav.replaceUrl key url
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

        DomFocus toMsg idAttribute ->
            ( seeds
            , Task.attempt toMsg <| Dom.focus idAttribute
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
