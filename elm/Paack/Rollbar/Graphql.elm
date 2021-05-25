module Paack.Rollbar.Graphql exposing (fromGraphqlError)

{-| Composes the error effect
-}

import Dict
import Graphql.Http as GraphqlHttp
import Graphql.Http.GraphqlError as GraphqlError
import Json.Decode as Decode
import Json.Encode as Encode
import Paack.Rollbar as Rollbar exposing (RollbarPayload(..))
import Remote.Errors as RemoteErrors exposing (GraphqlHttpError)


fromGraphqlError : String -> (error -> RollbarPayload) -> GraphqlHttpError error -> RollbarPayload
fromGraphqlError parent customErrorPayload error =
    Rollbar.prependDescription parent <|
        case error of
            RemoteErrors.Custom customError ->
                customErrorPayload customError

            RemoteErrors.Transport transportError ->
                fromGraphqlRawError transportError


fromGraphqlRawError : GraphqlHttp.RawError () GraphqlHttp.HttpError -> RollbarPayload
fromGraphqlRawError error =
    case error of
        GraphqlHttp.HttpError httpError ->
            fromGraphqlHttpError httpError

        GraphqlHttp.GraphqlError _ gqlErrors ->
            RollError
                { description = "GraphqlHttp.GraphqlError"
                , details =
                    Dict.insert "graphql-errors"
                        (Encode.list graphqlErrorEncode gqlErrors)
                        Dict.empty
                }


graphqlErrorEncode : GraphqlError.GraphqlError -> Encode.Value
graphqlErrorEncode { details, message, locations } =
    Encode.object
        [ ( "details"
          , Encode.dict identity identity details
          )
        , ( "message"
          , Encode.string message
          )
        , ( "location"
          , locations
                |> Maybe.map (Encode.list graphqlLocationEncode)
                |> Maybe.withDefault Encode.null
          )
        ]


fromGraphqlHttpError : GraphqlHttp.HttpError -> RollbarPayload
fromGraphqlHttpError httpError =
    case httpError of
        GraphqlHttp.BadUrl url ->
            RollError
                { description = "GraphqlError.BadUrl"
                , details =
                    Dict.insert "invalid-url"
                        (Encode.string url)
                        Dict.empty
                }

        GraphqlHttp.Timeout ->
            NotToRoll

        GraphqlHttp.NetworkError ->
            NotToRoll

        GraphqlHttp.BadStatus metadata body ->
            RollError
                { description = "GraphqlError.BadStatus"
                , details =
                    Dict.empty
                        |> Dict.insert "metadata-code"
                            (Encode.int metadata.statusCode)
                        |> Dict.insert "response-body"
                            (Encode.string body)
                }

        GraphqlHttp.BadPayload jsonError ->
            RollError
                { description = "GraphqlError.BadPayload"
                , details =
                    Dict.insert "payload"
                        (Encode.string <| Decode.errorToString jsonError)
                        Dict.empty
                }


graphqlLocationEncode : GraphqlError.Location -> Encode.Value
graphqlLocationEncode { line, column } =
    Encode.object
        [ ( "line", Encode.int line )
        , ( "column", Encode.int column )
        ]
