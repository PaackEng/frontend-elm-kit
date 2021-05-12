module Paack.Rollbar.Http exposing (errorToRollbar)

import Dict
import Http as ElmHttp
import Json.Encode as Encode
import Paack.Rollbar exposing (RollbarPayload(..))


errorToRollbar : ElmHttp.HttpError -> RollbarPayload
errorToRollbar httpError =
    case httpError of
        ElmHttp.BadUrl url ->
            RollError
                { description = "ElmHttp.BadUrl"
                , details =
                    Dict.insert "invalid-url"
                        (Encode.string url)
                        Dict.empty
                }

        ElmHttp.Timeout ->
            NotToRoll

        ElmHttp.NetworkError ->
            NotToRoll

        ElmHttp.BadStatus code ->
            RollError
                { description = "ElmHttp.BadStatus"
                , details =
                    Dict.insert "response-code"
                        (Encode.int code)
                        Dict.empty
                }

        ElmHttp.BadBody explanation ->
            RollError
                { description = "ElmHttp.BadBody"
                , details =
                    Dict.insert "debug-message"
                        (Encode.string explanation)
                        Dict.empty
                }
