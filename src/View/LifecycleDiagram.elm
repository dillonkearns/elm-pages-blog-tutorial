module View.LifecycleDiagram exposing
    ( Display(..)
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr


type Display
    = Show
    | Hide


view : Display -> Html msg
view display =
    Html.div []
        [ Html.img
            [ Attr.src "1.svg"
            , Attr.style "width" "1200px"
            , Attr.style "margin-left" "-300px"
            , Attr.style "position" "absolute"
            ]
            []
        , Html.img
            [ Attr.src "2.svg"
            , Attr.style "width" "1200px"
            , Attr.style "margin-left" "-300px"
            , Attr.style "position" "absolute"
            , Attr.style "opacity"
                (case display of
                    Show ->
                        "1"

                    Hide ->
                        "0"
                )
            , Attr.style "transition" "opacity 1s ease-in-out"
            ]
            []
        ]
