module Paack.Program exposing (Program, browserApplication)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Effects.LocalPerformer as LocalPerformer
import Html exposing (Html, canvas, div)
import Html.Attributes exposing (attribute, id)
import Html.Lazy as Lazy exposing (lazy)
import Main.Model as Model exposing (Flags, Model)
import Main.Msg exposing (Msg)
import Main.Pages exposing (PageModel)
import Main.Update exposing (update)
import Paack.Effects as Effects
import Paack.Effects.CommonPerformer as CommonPerformer
import Paack.Effects.MainHelper exposing (PerformerModel, performedInit, performedUpdate)
import Random
import UI.Document as UI exposing (Document)
import UI.RenderConfig exposing (RenderConfig)
import UUID exposing (Seeds)
import Url exposing (Url)


type alias Program =
    Platform.Program Flags PerformerModel Msg


type alias ProgramData =
    { view : Model -> Document PageModel Msg
    , subscriptions : Model -> Sub Msg
    , onUrlRequest : UrlRequest -> Msg
    , onUrlChange : Url -> Msg
    , getRenderConfig : Model -> RenderConfig
    , getPage : Model -> PageModel
    }


browserApplication : ProgramData -> Program
browserApplication data =
    Browser.application
        { init = performedInit
        , view =
            \{ appModel } ->
                data.view appModel
                    |> UI.toBrowserDocument
                        (data.getRenderConfig appModel)
                        (data.getPage appModel)
        , update = performedUpdate
        , onUrlRequest = data.onUrlRequest
        , onUrlChange = data.onUrlChange
        , subscriptions = .appModel >> data.subscriptions
        }
