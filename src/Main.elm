module Main exposing (..)

import Browser
import Html exposing (Html, br, div, h1, img, text)
import Html.Attributes exposing (class, src, style)
import Html.Lazy
import InfiniteScroll exposing (Direction(..), infiniteScroll)
import Material
import Material.Fab as Fab
import Material.Icon as Icon
import Material.Options as Options exposing (cs, css, styled)
import Material.TextField as TextField
import Material.TopAppBar as TopAppBar
import Task
import Utils.IconList exposing (..)
import Utils.Icons as Icons



---- MODEL ----


type alias Model =
    { icons : List IconInfo
    , count : Int
    , filter: String
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
    ( { icons = iconList
      , count = stepCount
      , filter = ""
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
    | FilterChanged String


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
                , infiniteScroll = infiniteScroll
              }
            , Cmd.none
            )
        
        FilterChanged filter ->
            ( { model | filter = filter }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ topAppBar model
        , gridContainer model
        ]


gridContainer : Model -> Html Msg
gridContainer model =
    let
        contains = String.contains (String.toUpper model.filter)
    in
    div
        [ class "gridcontainer"
        , InfiniteScroll.infiniteScroll InfiniteScrollMsg
        ]
        (model.icons
            |> List.filter (\icon -> contains (String.toUpper icon.name))
            |> List.take model.count
            |> List.map (viewIcon model))


viewIcon : Model -> IconInfo -> Html Msg
viewIcon model icon =
    styled div
        [ cs "iconview" ]
        [ iconitem icon
        , Html.span [ style "font-size" "small" ] [ text icon.name ]
        , Html.b [ style "font-size" "small" ] [ text icon.function ]
        , Html.i [] [ text icon.category ]
        ]


iconitem : IconInfo -> Html msg
iconitem icon =
    div [ class "iconitem" ] [ Icon.view [ Icon.size24 ] icon.name ]


topAppBar : Model -> Html Msg
topAppBar model =
    let
        index =
            "top-app-bar"
    in
    TopAppBar.view Mdc
        index
        model.mdc
        []
        [ TopAppBar.section
            [ TopAppBar.alignStart
            ]
            [ TopAppBar.navigationIcon Mdc (index ++ "-menu") model.mdc [] Icons.image_search
            , TopAppBar.title [] [ text "Material Icon View" ]
            ]
        , TopAppBar.section
            [ TopAppBar.alignEnd
            ]
            [ TextField.view Mdc
                (index ++ "-search")
                model.mdc
                (TextField.label "Search" :: Options.onInput FilterChanged :: TextField.trailingIcon Icons.search :: [])
                []
            ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
