module Main exposing (..)

import Browser
import Html exposing (Html, br, div, h1, img, text)
import Html.Lazy
import Html.Attributes exposing (class, src)
import Material
import Material.Icon as Icon
import Material.Fab as Fab
import Utils.Icons as Icons
import Utils.IconList exposing(..)
import Html.Attributes exposing (style)

---- MODEL ----


type alias Model =
    { icons : List IconInfo,  mdc : Material.Model Msg }


init : ( Model, Cmd Msg)
init =
    ( { icons = iconList, mdc = Material.defaultModel }, Cmd.none )


---- UPDATE ----


type Msg
    = Mdc (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "gridcontainer" ]
        (List.map (viewIcon model) model.icons)


viewIcon: Model -> IconInfo -> Html Msg
viewIcon model icon =
    div [ class "iconview" ]
        [ fab icon model []
        , Html.b [] [ text icon.name ]
        , Html.i [] [ text icon.category ]
        ]

fab : IconInfo -> Model -> List (Fab.Property Msg) -> Html Msg
fab icon model options =
    Fab.view Mdc icon.name model.mdc (Fab.mini :: Fab.ripple :: Fab.icon icon.name :: options) []
---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
