module Paack.Rollbar.Performer exposing (performEffect, performEffectWithModel)

{-| Perform the error effect
-}

import Data.Environment as Environment exposing (Environment)
import Paack.Rollbar exposing (MaybeToken(..))
import Paack.Rollbar.Effect exposing (Effect(..), RollbarResult)
import Rollbar
import Task
import Url exposing (Url)


performEffect :
    (RollbarResult -> msg)
    -> Environment
    -> String
    -> MaybeToken
    -> Url
    -> Effect
    -> Cmd msg
performEffect feedbackMsg environment codeVersion maybeToken url (Send { title, body, level }) =
    case maybeToken of
        JustToken token ->
            Rollbar.send token
                (Rollbar.codeVersion codeVersion)
                -- This (scope) is seen in Rollbar as "body"."context":
                (Rollbar.scope url.path)
                (Rollbar.environment <| Environment.toString environment)
                defaultMaxAttempts
                level
                title
                body
                |> Task.map (always ())
                |> Task.attempt feedbackMsg

        DisabledForDevelopment ->
            Cmd.none


performEffectWithModel :
    (RollbarResult -> msg)
    ->
        { a
            | appConfig : { b | environment : Environment }
            , url : Url
            , rollbarToken : MaybeToken
            , codeVersion : String
        }
    -> Effect
    -> Cmd msg
performEffectWithModel feedbackMsg { appConfig, codeVersion, rollbarToken, url } effect =
    performEffect feedbackMsg
        appConfig.environment
        codeVersion
        rollbarToken
        url
        effect


defaultMaxAttempts : Int
defaultMaxAttempts =
    60
