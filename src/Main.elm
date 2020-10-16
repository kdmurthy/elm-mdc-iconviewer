module Main exposing (..)

import Browser
import Html exposing (Html, br, div, h1, img, text)
import Html.Attributes exposing (class, src, style)
import Html.Lazy
import InfiniteScroll exposing (infiniteScroll)
import Material
import Material.Fab as Fab
import Material.Icon as Icon
import Material.Options exposing (css)
import Task
import Utils.IconList exposing (..)
import Utils.Icons as Icons
import InfiniteScroll exposing (Direction(..))



---- MODEL ----


type alias Model =
    { icons : List IconInfo
    , count : Int
    , mdc : Material.Model Msg
    , infiniteScroll : InfiniteScroll.Model Msg
    }


stepCount : Int
stepCount =
    150


loadMore : InfiniteScroll.Direction -> Cmd Msg
loadMore direction =
    case direction of
        Top ->
            Cmd.none
        Bottom ->
            Task.succeed LoadMore
                |> Task.perform identity


init : ( Model, Cmd Msg )
init =
    ( { icons = List.take stepCount iconList
      , count = stepCount
      , mdc = Material.defaultModel
      , infiniteScroll = InfiniteScroll.init loadMore
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = Mdc (Material.Msg Msg)
    | InfiniteScrollMsg InfiniteScroll.Msg
    | LoadMore


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InfiniteScrollMsg msg_ ->
            let
                ( infiniteScroll, cmd ) =
                    InfiniteScroll.update InfiniteScrollMsg msg_ model.infiniteScroll
            in
            ( { model | infiniteScroll = infiniteScroll }, cmd )

        Mdc msg_ ->
            Material.update Mdc msg_ model

        LoadMore ->
            let
                count =
                    min (model.count + stepCount) (List.length iconList)

                infiniteScroll =
                    InfiniteScroll.stopLoading model.infiniteScroll
            in
            ( { model
                | count = count
                , icons = List.take count iconList
                , infiniteScroll = infiniteScroll
              }
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div
        [ class "gridcontainer"
        , style "height" "900px"
        , style "overflow-x" "auto"
        , style "overflow-y" "scroll"
        , style "margin" "auto"
        , InfiniteScroll.infiniteScroll InfiniteScrollMsg
        ]
        (List.map (viewIcon model) model.icons)


viewIcon : Model -> IconInfo -> Html Msg
viewIcon model icon =
    div [ class "iconview" ]
        [ iconitem icon
        , Html.span [ style "font-size" "small" ] [ text icon.name ]
        , Html.b [ style "font-size" "small" ] [ text icon.function ]
        , Html.i [] [ text icon.category ]
        ]


iconitem : IconInfo -> Html msg
iconitem icon =
    div [ class "iconitem" ] [ Icon.view [ Icon.size24 ] icon.name ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
