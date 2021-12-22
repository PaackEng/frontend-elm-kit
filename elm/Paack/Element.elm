module Paack.Element exposing (..)

import Element exposing (Attribute, Element)
import Html
import Html.Attributes as HtmlAttrs


renderIf : Bool -> Element msg -> Element msg
renderIf shouldRender view =
    if shouldRender then
        view

    else
        Element.none


overflowVisible : Attribute msg
overflowVisible =
    Element.htmlAttribute <| HtmlAttrs.style "overflow" "visible"


wordWrap : Attribute msg
wordWrap =
    Element.htmlAttribute <| HtmlAttrs.style "word-wrap" "break-word"


failureIndicatorHtml : Html.Attribute msg
failureIndicatorHtml =
    HtmlAttrs.attribute "data-has-error" "1"


failureIndicator : Attribute msg
failureIndicator =
    Element.htmlAttribute <| failureIndicatorHtml


id : String -> Attribute msg
id value =
    value
        |> HtmlAttrs.id
        |> Element.htmlAttribute
