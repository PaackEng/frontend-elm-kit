module Paack.Rollbar.Effect exposing (Effect(..), Payload, RollbarResult)

{-| Perform the error effect
-}

import Dict exposing (Dict)
import Http as ElmHttp
import Json.Encode exposing (Value)
import Rollbar


type Effect
    = Send Payload


{-|

  - title:
    Usually `(parent ++ "/" ++ description)`
  - body:
    In rollbar as "body"."message"
  - level:
    As seen in rollbar dashboard

-}
type alias Payload =
    { title : String
    , body : Dict String Value
    , level : Rollbar.Level
    }


type alias RollbarResult =
    Result ElmHttp.Error ()
