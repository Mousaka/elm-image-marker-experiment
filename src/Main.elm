port module Main exposing (main)

import Browser
import File
import File.Download
import File.Select as Select
import Html exposing (Html, button, div, text)
import Html.Attributes
import Html.Events exposing (onClick)
import Html.Events.Extra.Mouse as Mouse
import Svg
import Svg.Attributes
import Task


port ourPort : () -> Cmd msg


port newImage : (String -> a) -> Sub a


type alias Model =
    { count : Int
    , file : Maybe File.File
    , url : String
    , circles : List ( Float, Float )
    }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { count = 0, file = Nothing, url = "", circles = [ ( 50, 60 ) ] }, Cmd.none )


type Msg
    = UploadFile
    | FileLoaded File.File
    | GotPreview String
    | AddCircle Mouse.Event
    | Save
    | GotMessage String


relativePos : Mouse.Event -> ( Float, Float )
relativePos mouseEvent =
    mouseEvent.offsetPos


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UploadFile ->
            ( model, Select.file [] FileLoaded )

        FileLoaded file ->
            ( { model | file = Just file }, Task.perform GotPreview (File.toUrl file) )

        GotPreview url ->
            ( { model | url = url }, Cmd.none )

        AddCircle event ->
            ( { model | circles = relativePos event :: model.circles }, Cmd.none )

        Save ->
            ( model, ourPort () )

        GotMessage url ->
            ( model, File.Download.url url )


view : Model -> Html Msg
view model =
    case model.file of
        Nothing ->
            div []
                [ button [ onClick UploadFile, Html.Attributes.style "font-size" "12rem" ] [ text "Upload" ] ]

        Just _ ->
            div []
                [ Svg.svg
                    [ Svg.Attributes.overflow "visible"
                    , Svg.Attributes.viewBox "0 0 800 600"
                    , Mouse.onDown AddCircle
                    ]
                    ([ Svg.image [ Svg.Attributes.xlinkHref model.url ] [] ]
                        ++ List.map
                            (\( x, y ) ->
                                Svg.circle
                                    [ Svg.Attributes.cx (String.fromFloat x)
                                    , Svg.Attributes.cy (String.fromFloat y)
                                    , Svg.Attributes.fill "none"
                                    , Svg.Attributes.stroke "hotpink"
                                    , Svg.Attributes.strokeWidth "5"
                                    , Svg.Attributes.r "50"
                                    ]
                                    []
                            )
                            model.circles
                    )
                , button [ onClick Save ] [ text "Download" ]
                , Html.canvas [] []
                ]


main : Program () Model Msg
main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    newImage GotMessage
