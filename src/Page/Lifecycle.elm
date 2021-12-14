module Page.Lifecycle exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Http
import Head
import Head.Seo as Seo
import Html
import Html.Attributes as Attr
import Http
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets
import Pages.Url
import Path exposing (Path)
import Shared
import View exposing (View)


request : (Result Http.Error { stargazers_count : Int } -> msg) -> Cmd msg
request toMsg =
    Http.get
        { url = "https://api.github.com/repos/dillonkearns/elm-pages"
        , expect = Http.expectJson toMsg decoder
        }


type alias Response =
    { stargazers_count : Int }


decoder : D.Decoder { stargazers_count : Int }
decoder =
    D.succeed
        (\stargazers_count ->
            { stargazers_count = stargazers_count
            }
        )
        |> required "stargazers_count" D.int


type alias Model =
    { response : Maybe (Result Http.Error Response)
    }


type Msg
    = GotHttpResponse (Result Http.Error Response)


type alias RouteParams =
    {}


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithLocalState
            { view = view
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , init =
                \_ _ _ ->
                    ( { response = Nothing
                      }
                    , request GotHttpResponse
                    )
            }


type alias Data =
    Response


data : DataSource Data
data =
    DataSource.Http.unoptimizedRequest
        (Pages.Secrets.succeed
            { url = "https://api.github.com/repos/dillonkearns/elm-pages"
            , method = "GET"
            , headers = []
            , body = DataSource.Http.emptyBody
            }
        )
        (DataSource.Http.expectUnoptimizedJson decoder)


init :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> ( Model, Cmd Msg )
init maybePageUrl sharedModel static =
    ( { response = Nothing
      }
    , request GotHttpResponse
    )


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg )
update pageUrl maybeNavigationKey sharedModel static msg model =
    case msg of
        GotHttpResponse result ->
            ( { model | response = Just result }, Cmd.none )


subscriptions : Maybe PageUrl -> RouteParams -> Path -> templateModel -> Sub templateMsg
subscriptions maybePageUrl routeParams path model =
    Sub.none


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    []


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "Title TODO"
    , body =
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
                (case model.response of
                    Just _ ->
                        "1"

                    Nothing ->
                        "0"
                )
            , Attr.style "transition" "opacity 1s ease-in-out"
            ]
            []
        , Html.pre []
            [ Html.code []
                [ case model.response of
                    Just (Ok { stargazers_count }) ->
                        String.fromInt stargazers_count
                            |> Html.text

                    Just (Err error) ->
                        error
                            |> Debug.toString
                            |> Html.text

                    Nothing ->
                        Html.text "Loading..."
                ]
            ]
        , Html.pre []
            [ Html.code []
                [ static.data.stargazers_count |> String.fromInt |> Html.text
                ]
            ]
        ]
    }
