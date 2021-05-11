module Paack.Rollbar.Performer exposing (performEffect, performEffectWithModel)

{-| Perform the error effect
-}

import Data.Environment as Environment exposing (Environment)
import Main.Model as Main
import Paack.Rollbar
import Paack.Rollbar.Effect exposing (Effect(..), RollbarResult)
import Rollbar
import Task
import Url exposing (Url)


performEffect :
    (RollbarResult -> msg)
    -> Environment
    -> String
    -> Rollbar.Token
    -> Url
    -> Effect
    -> Cmd msg
performEffect feedbackMsg environment codeVersion token url (Send { title, body, level }) =
    case environment of
        Environment.Development ->
            Cmd.none

        _ ->
            Rollbar.send token
                (Rollbar.codeVersion codeVersion)
                -- This (scope) is seen in Rollbar as "body"."context":
                (Rollbar.scope url.path)
                (Rollbar.environment <| Environment.toString environment)
                -- This (max retries) is the value NoRedInk adopted for `defaultMaxAttempts`:
                60
                level
                title
                body
                |> Task.map (always ())
                |> Task.attempt feedbackMsg


performEffectWithModel :
    (RollbarResult -> msg)
    ->
        { a
            | appConfig : { b | environment : Environment }
            , url : Url
            , rollbarToken : Rollbar.Token
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
