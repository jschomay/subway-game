port module Main exposing (main)

import Browser
import City exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import List.Extra
import List.Zipper as Zipper exposing (Zipper)
import LocalTypes exposing (..)
import Manifest
import Markdown
import Process
import Rules
import Subway
import Task
import Tuple
import Views.Station.Hall as Hall
import Views.Station.Lobby as Lobby
import Views.Station.Platform as Platform
import Views.Train



{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


type alias Flags =
    {}


main : Program Flags Model Msg
main =
    Browser.document
        { init = always init
        , view = \model -> { title = "Subway!", body = [ view model ] }
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , story : Maybe String
    , narrativeContent : Dict String (Zipper String)
    , map : Subway.Map City.Station City.Line
    , mapImage : String
    , location : Location
    , showMap : Bool
    }


init : ( Model, Cmd Msg )
init =
    let
        engineModel =
            Engine.init
                { items = List.map Tuple.first Manifest.items
                , locations = List.map Tuple.first Manifest.locations
                , characters = List.map Tuple.first Manifest.characters
                }
                (Dict.map (\a b -> getRuleData ( a, b )) Rules.rules)
                |> Engine.changeWorld Rules.startingState
    in
    ( { engineModel = engineModel
      , loaded = False
      , story = Nothing
      , narrativeContent = Dict.map (\a b -> getNarrative ( a, b )) Rules.rules
      , map = City.fullMap
      , mapImage = City.mapImage City.RedYellowGreenMap
      , location = OnTrain { line = Red, status = InTransit, desiredStop = TwinBrooks }
      , showMap = False
      }
    , delay introDelay (Interact "intro")
    )


introDelay : Float
introDelay =
    3 * 1000


departingDelay : Float
departingDelay =
    2 * 1000


arrivingDelay : Float
arrivingDelay =
    1.5 * 1000


{-| "Ticks" the narrative engine, and displays the story content
-}
updateStory : String -> Model -> Model
updateStory interactableId model =
    let
        ( newEngineModel, maybeMatchedRuleId ) =
            Engine.update interactableId model.engineModel

        ( narrativeForThisInteraction, updatedContent ) =
            Maybe.andThen
                (\matchedRuleId ->
                    Maybe.map
                        (\definedNarrative ->
                            ( Zipper.current definedNarrative
                            , Dict.update matchedRuleId updateNarrativeContent model.narrativeContent
                            )
                        )
                        (Dict.get matchedRuleId model.narrativeContent)
                )
                maybeMatchedRuleId
                |> Maybe.withDefault
                    ( .description <| Components.getDisplayInfo <| Manifest.findEntity <| interactableId
                    , model.narrativeContent
                    )

        updateNarrativeContent : Maybe (Zipper String) -> Maybe (Zipper String)
        updateNarrativeContent maybeZipper =
            -- Note, sets the narrative content to `Nothing` if at the "end" of the zipper
            Maybe.andThen Zipper.next maybeZipper
    in
    { model
        | engineModel = newEngineModel
        , story = Just <| narrativeForThisInteraction
        , narrativeContent = updatedContent
    }


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


changeTrainStatus : TrainStatus -> TrainProps -> TrainProps
changeTrainStatus newStatus { line, desiredStop } =
    { line = line, status = newStatus, desiredStop = desiredStop }


{-| Use when you need to manually change the Model outside of the normal subway mechanics.

Tip: use the event name as a discrete string for updateStory, then you can set the scene, location, etc of the EngineModel via the usual Engine rules instead of with Engine.changeWorld

\*\* Don't forget to call `updateStory` to get the right narrative based on your changes, but be careful not to call it twice (if it was already called in `update`)

\*\* Dont' forget to pass through or batch in the cmd if unless you know you want to cancel it

-}
scriptedEvents : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
scriptedEvents msg ( model, cmd ) =
    case ( Engine.getCurrentScene model.engineModel, msg ) of
        _ ->
            ( model, cmd )


getCurrentStation : Model -> Station
getCurrentStation model =
    Engine.getCurrentLocation model.engineModel
        |> String.toInt
        |> Maybe.andThen (Subway.getStation model.map)
        |> Maybe.withDefault WestMulberry


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    update_ msg model



-- TODO put back after adjusting train mechanics if needed
-- |> scriptedEvents msg


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
    if Engine.getEnding model.engineModel /= Nothing then
        -- no-op if story has ended
        noop model

    else
        case msg of
            Interact interactableId ->
                ( updateStory interactableId model
                , Cmd.none
                )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            Delay duration delayedMsg ->
                ( model
                , Task.perform (always delayedMsg) <| Process.sleep duration
                )

            ToggleMap ->
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            Go area ->
                ( { model | location = InStation area }, Cmd.none )

            BoardTrain line desiredStop ->
                ( { model
                    | location = OnTrain { line = line, status = InTransit, desiredStop = desiredStop }
                  }
                , delay departingDelay (Interact "train")
                )

            Continue ->
                -- note, use scriptedEvents to respond special to Continue's
                case model.location of
                    InStation _ ->
                        ( { model | story = Nothing }, Cmd.none )

                    OnTrain ({ desiredStop } as train) ->
                        ( { model
                            | location = OnTrain <| changeTrainStatus Arriving train
                            , story = Nothing
                          }
                        , delay arrivingDelay <| Disembark desiredStop
                        )

            Disembark station ->
                ( { model
                    | location = InStation Lobby
                    , story = Nothing
                    , engineModel =
                        -- this is the only place there should be an Engine.changeWorld call to set the location
                        Engine.changeWorld
                            [ Engine.moveTo (station |> stationInfo |> .id |> String.fromInt) ]
                            model.engineModel
                  }
                , Cmd.none
                )


delay : Float -> Msg -> Cmd Msg
delay duration msg =
    Task.perform (always msg) <| Process.sleep duration


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
        ]


view : Model -> Html Msg
view model =
    let
        --     showTheMap =
        --         Debug.log (Subway.graphViz (stationInfo >> .name) (lineInfo >> .name) City.fullMap ++ "\n") "Copy and paste in http://viz-js.com/"
        currentStation =
            getCurrentStation model

        stationToId station =
            stationInfo station |> .id

        lineToId line =
            lineInfo line |> .number

        config =
            { stationToId = stationToId
            , lineToId = lineToId
            }
    in
    if not model.loaded then
        div [ class "Loading" ] [ text "Loading..." ]

    else
        div [ class "game" ]
            [ case model.location of
                InStation Lobby ->
                    Lobby.view model.engineModel currentStation

                InStation Hall ->
                    Hall.view model.map currentStation

                InStation (Platform line) ->
                    Platform.view model.map currentStation line

                OnTrain { line, status, desiredStop } ->
                    Views.Train.view
                        { line = line
                        , arrivingAtStation =
                            if status == Arriving then
                                Just desiredStop

                            else
                                Nothing
                        }
            , if model.showMap then
                mapView model.mapImage

              else
                case model.location of
                    InStation _ ->
                        div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]

                    _ ->
                        text ""
            , model.story
                |> Maybe.map storyView
                |> Maybe.withDefault (text "")
            ]


storyView : String -> Html Msg
storyView story =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( story
          , div [ class "StoryLine__content" ]
                [ Markdown.toHtml [] story
                , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
                ]
          )
        ]


mapView : String -> Html Msg
mapView mapImage =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ mapImage ] []
        ]
