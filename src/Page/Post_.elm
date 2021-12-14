module Page.Post_ exposing (Data, Model, Msg, page)

import ContentfulPosts
import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Markdown.Parser
import Markdown.Renderer
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    Never


type alias RouteParams =
    { post : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , pages = pages
        , data = data
        }
        |> Page.buildNoState { view = view }


pages : DataSource (List RouteParams)
pages =
    DataSource.succeed
        [ { post = "automate-with-webhooks" }
        , { post = "hello-world" }
        ]


data : RouteParams -> DataSource Data
data routeParams =
    DataSource.map2 Data
        --DataSource.File.rawFile
        --    "posts/post.md"
        (ContentfulPosts.bySlug routeParams.post
            |> DataSource.andThen
                (\contents ->
                    renderMarkdown contents.body
                        |> DataSource.fromResult
                )
        )
        (ContentfulPosts.bySlug routeParams.post)


renderMarkdown : String -> Result String (List (Html msg))
renderMarkdown markdownString =
    markdownString
        |> Markdown.Parser.parse
        |> Result.mapError (\error -> error |> Debug.toString)
        |> Result.andThen (Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external static.data.post.imageUrl
            , alt = "Blog post hero image"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = static.data.post.description
        , locale = Nothing
        , title = static.data.post.title
        }
        |> Seo.website


type alias Data =
    { markdown : List (Html Never)
    , post : ContentfulPosts.Post
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Well... this is my blog"
    , body =
        [ Html.div [ Attr.class "markdown-body" ]
            static.data.markdown
        ]
    }
