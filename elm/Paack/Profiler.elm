module Paack.Profiler exposing (Program, browserApplication)

import Browser exposing (UrlRequest)
import Html exposing (Html, canvas, div)
import Html.Attributes exposing (attribute, id)
import Html.Lazy exposing (lazy)
import Main.Model exposing (Flags, Model)
import Main.Msg exposing (Msg)
import Main.Pages exposing (PageModel)
import Paack.Effects.MainHelper exposing (PerformerModel, performedInit, performedUpdate)
import UI.Document as UI exposing (Document)
import UI.RenderConfig exposing (RenderConfig)
import Url exposing (Url)


type alias Program =
    Platform.Program Flags ( Int, PerformerModel ) Msg


type alias ProgramData =
    { view : Model -> Document PageModel Msg
    , subscriptions : Model -> Sub Msg
    , onUrlRequest : UrlRequest -> Msg
    , onUrlChange : Url -> Msg
    , getRenderConfig : Model -> RenderConfig
    , getPage : Model -> PageModel
    }


start : String
start =
    "profile://start/"


end : String
end =
    "profile://end/"


browserApplication : ProgramData -> Program
browserApplication data =
    Browser.application
        { init =
            \flags url key ->
                let
                    startTag =
                        start ++ "code/0"

                    endTag =
                        end ++ "code/0"
                in
                key
                    |> escape startTag ()
                    |> performedInit flags url
                    |> escape endTag flags
                    |> Tuple.mapFirst (Tuple.pair 0)
        , view =
            \( counter, { appModel } ) ->
                let
                    counterStr =
                        String.fromInt counter

                    startTag =
                        start ++ "view/" ++ counterStr

                    endTag =
                        end ++ "view/" ++ counterStr
                in
                appModel
                    |> escape startTag ()
                    |> data.view
                    |> UI.withExtraHtml charts
                    |> UI.toBrowserDocument
                        (data.getRenderConfig appModel)
                        (data.getPage appModel)
                    |> escape endTag ()
        , update =
            \msg ( counter, model ) ->
                let
                    nextCounter =
                        counter + 1

                    counterStr =
                        String.fromInt nextCounter

                    startTag =
                        start ++ "code/" ++ counterStr

                    endTag =
                        end ++ "code/" ++ counterStr
                in
                model
                    |> escape startTag ()
                    |> performedUpdate msg
                    |> escape endTag msg
                    |> Tuple.mapFirst (Tuple.pair nextCounter)
        , onUrlRequest = data.onUrlRequest
        , onUrlChange = data.onUrlChange
        , subscriptions = Tuple.second >> .appModel >> data.subscriptions
        }


escape : String -> a -> b -> b
escape tag data return =
    let
        _ =
            Debug.log tag data
    in
    return


immortal : ()
immortal =
    ()


charts : List (Html msg)
charts =
    [ lazy
        (\_ ->
            div [ attribute "style" "position: fixed; opacity: 0.9; top: 50vh; width: 20vw; left: 0; right: auto; z-index: 99999;" ]
                [ canvas [ id "code-chart" ]
                    []
                ]
        )
        immortal
    , lazy
        (\_ ->
            div [ attribute "style" "position: fixed; opacity: 0.9; top: 50vh; width: 20vw; left: auto; right: 0; z-index: 99999;" ]
                [ canvas [ id "view-chart" ]
                    []
                ]
        )
        immortal
    ]
