module Page.Index exposing (Data, Model, Msg, page)

import ContentfulPosts
import DataSource exposing (DataSource)
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Html
import Html.Attributes as Attr
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Route
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.map2 Data
        (Glob.succeed
            identity
            |> Glob.match (Glob.literal "posts/")
            |> Glob.capture Glob.wildcard
            |> Glob.match (Glob.literal ".md")
            |> Glob.toDataSource
        )
        ContentfulPosts.data


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "https://unsplash.com/photos/cckf4TsHAuw/download?ixid=MnwxMjA3fDB8MXxhbGx8fHx8fHx8fHwxNjM4Mzc2NzUw&force=true&w=320"
            , alt = "Blog"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "A blog about building my blog."
        , locale = Nothing
        , title = "Blog Squared"
        }
        |> Seo.website


type alias Data =
    { slugs : List String
    , posts : List ContentfulPosts.Post
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Well... this is my blog."
    , body =
        [ Html.div
            [ Attr.style "display" "flex"
            , Attr.style "flex-direction" "column"
            , Attr.style "align-items" "center"
            ]
            [--Html.img
             --    --[ Attr.src "https://lukaszadam.com/assets/downloads/desk-illustration-2.svg"
             --    [ Attr.src "https://lukaszadam.com/assets/downloads/desk-illustration-2.svg"
             --
             --    --, Attr.style "max-width" "300px"
             --    , Attr.style "width" "220px"
             --
             --    --, Attr.style "height" "200px"
             --    --[ Attr.src "https://lukaszadam.com/assets/downloads/hero-illustration.svg"
             --    ]
             --    []
            ]
        , Html.p
            [ Attr.style "text-align" "center"
            , Attr.style "color" "var(--primary)"
            , Attr.style "font-size" "20px"
            ]
            [ Html.text "A "
            , Html.span [ Attr.style "font-weight" "bold" ] [ Html.text "blog " ]
            , Html.text "about building my "
            , Html.span [ Attr.style "font-weight" "bold" ] [ Html.text "blog." ]
            ]
        , Html.div [ Attr.class "blog-index" ]
            (static.data.posts
                |> List.map
                    (\post ->
                        Html.article []
                            [ Route.link (Route.Post_ { post = post.slug })
                                []
                                [ Html.div [ Attr.class "info" ]
                                    [ Html.div []
                                        [ Html.h2 []
                                            [ Html.text post.title
                                            ]
                                        ]
                                    , Html.div [] [ Html.text post.description ]
                                    , Html.div [ Attr.class "published" ] [ Html.text "December 28, 2021" ]
                                    ]
                                , Html.div []
                                    [ Html.img [ Attr.src (post.imageUrl ++ "?w=500&h=320&q=80&fit=fill") ] []
                                    ]
                                ]
                            ]
                    )
            )
        ]
    }
