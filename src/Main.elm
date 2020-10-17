module Main exposing (main)

import Array
import Browser
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import InfiniteScroll exposing (Direction(..), infiniteScroll)
import Material
import Material.Drawer.Permanent as Drawer
import Material.Icon as Icon
import Material.List as Lists
import Material.Options as Options exposing (cs, styled)
import Material.TextField as TextField
import Material.TopAppBar as TopAppBar
import Task
import Utils.IconList exposing (IconInfo, iconCategories, iconList)
import Utils.Icons as Icons



-- CONSTANTS --


stepCount : Int
stepCount =
    150


allCategories : String
allCategories =
    "All"



-- MESSAGE --


type Msg
    = Mdc (Material.Msg Msg)
    | InfiniteScrollMsg InfiniteScroll.Msg
    | LoadMore
    | FilterChanged String
    | CategorySelected Int



---- MODEL ----


type alias Model =
    { icons : List IconInfo
    , count : Int
    , filter : String
    , selectedCategory : String
    , mdc : Material.Model Msg
    , infiniteScroll : InfiniteScroll.Model Msg
    }


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
      , selectedCategory = allCategories
      , mdc = Material.defaultModel
      , infiniteScroll = InfiniteScroll.init loadMore
      }
    , Cmd.none
    )



---- UPDATE ----


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

        CategorySelected index ->
            let
                selected : ( String, String )
                selected =
                    Maybe.withDefault ( allCategories, "category" ) <| Array.get index (Array.fromList iconCategories)
            in
            ( { model | selectedCategory = Tuple.first selected }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ topAppBar model
        , div [ class "content" ] [ categoryListView model, iconListView model ]
        ]


iconListView : Model -> Html Msg
iconListView model =
    let
        iconListFilter : List IconInfo -> List IconInfo
        iconListFilter =
            let
                contains =
                    String.contains (String.toUpper model.filter)

                ofCategory icon =
                    model.selectedCategory == allCategories || model.selectedCategory == icon.category
            in
            List.filter (\icon -> contains (String.toUpper icon.name) && ofCategory icon)
    in
    div
        [ class "icon-list"
        , InfiniteScroll.infiniteScroll InfiniteScrollMsg
        ]
        (model.icons
            |> iconListFilter
            |> List.take model.count
            |> List.map iconView
        )


iconView : IconInfo -> Html Msg
iconView icon =
    styled div
        [ cs "icon-view" ]
        [ div [ class "icon-item" ] [ Icon.view [ Icon.size24 ] icon.name ]
        , Html.span [ style "font-size" "small" ] [ text icon.name ]
        , Html.b [ style "font-size" "small" ] [ text icon.function ]
        , Html.i [] [ text icon.category ]
        ]


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
            , TopAppBar.title [] [ text "Material Icon Viewer" ]
            ]
        , TopAppBar.section
            [ TopAppBar.alignEnd
            ]
            [ TextField.view Mdc
                (index ++ "-search")
                model.mdc
                [ TextField.label "Search"
                , Options.onInput FilterChanged
                , TextField.trailingIcon Icons.search
                ]
                []
            ]
        ]


categoryListView : Model -> Html Msg
categoryListView model =
    Drawer.view Mdc
        "category-list-view"
        model.mdc
        []
        [ Drawer.header
            []
            [ styled Html.h3
                [ Drawer.title ]
                [ text "Categories" ]
            ]
        , Drawer.content [ cs "category-list" ]
            [ Lists.ul Mdc
                "permanent-drawer-drawer-list"
                model.mdc
                [ Lists.singleSelection
                , Lists.useActivated
                , Lists.onSelectListItem CategorySelected
                ]
                (List.map categoryItemView iconCategories)
            ]
        ]


categoryItemView : ( String, String ) -> Lists.ListItem Msg
categoryItemView ( category, icon ) =
    Lists.li
        []
        [ Lists.graphicIcon [] icon
        , text category
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
