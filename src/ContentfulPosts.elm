module ContentfulPosts exposing (..)

import Contentful.InputObject
import Contentful.Object.Asset
import Contentful.Object.BlogPost
import Contentful.Object.BlogPostCollection
import Contentful.Query
import Contentful.Scalar
import DataSource exposing (DataSource)
import DataSource.Http
import Graphql.Document
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet
import Json.Encode as Encode
import Pages.Secrets


data : DataSource (List Post)
data =
    request selection


bySlug :
    String
    -> DataSource Post
bySlug slug =
    Contentful.Query.blogPostCollection
        (\optionals ->
            { optionals
                | where_ =
                    Present
                        (Contentful.InputObject.buildBlogPostFilter
                            (\filters -> { filters | slug = Present slug })
                        )
            }
        )
        (Contentful.Object.BlogPostCollection.items
            postSelection
            |> SelectionSet.nonNullElementsOrFail
        )
        |> SelectionSet.nonNullOrFail
        |> request
        |> DataSource.andThen
            (\results ->
                case results of
                    [ result ] ->
                        DataSource.succeed result

                    [] ->
                        DataSource.fail "No posts found with that slug."

                    _ ->
                        DataSource.fail ""
            )



--|> request


byId : String -> DataSource Post
byId id =
    Contentful.Query.blogPost identity
        { id = id }
        postSelection
        |> SelectionSet.nonNullOrFail
        |> request


request : SelectionSet.SelectionSet decodesTo RootQuery -> DataSource decodesTo
request selectionSet =
    DataSource.Http.unoptimizedRequest
        (Pages.Secrets.succeed
            { url =
                "https://graphql.contentful.com/content/v1/spaces/3tn06npq9loc/environments/master?access_token=N7ofu_SaAWSIqo2b-I2PMrDJAmwoaOPk3Vz76r5d188"
            , method = "POST"
            , headers =
                [ ( "accept", "application/json" )
                ]
            , body =
                DataSource.Http.jsonBody
                    (Encode.object
                        [ ( "query"
                          , selectionSet
                                |> Graphql.Document.serializeQuery
                                |> Encode.string
                          )
                        ]
                    )
            }
        )
        (DataSource.Http.expectUnoptimizedJson (Graphql.Document.decoder selectionSet))


type alias Post =
    { title : String
    , description : String
    , body : String
    , slug : String
    , imageUrl : String
    }


selection : SelectionSet.SelectionSet (List Post) RootQuery
selection =
    Contentful.Query.blogPostCollection identity
        (Contentful.Object.BlogPostCollection.items
            postSelection
            |> SelectionSet.nonNullElementsOrFail
        )
        |> SelectionSet.nonNullOrFail


postSelection =
    SelectionSet.map5 Post
        (Contentful.Object.BlogPost.title identity |> SelectionSet.nonNullOrFail)
        (Contentful.Object.BlogPost.description identity |> SelectionSet.nonNullOrFail)
        (Contentful.Object.BlogPost.body identity |> SelectionSet.nonNullOrFail)
        (Contentful.Object.BlogPost.slug identity |> SelectionSet.nonNullOrFail)
        (Contentful.Object.BlogPost.heroImage identity
            (Contentful.Object.Asset.url identity
                |> SelectionSet.nonNullOrFail
            )
            |> SelectionSet.nonNullOrFail
        )
