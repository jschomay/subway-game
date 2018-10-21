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
    , storyLine : Maybe String
    , narrativeContent : Dict String (Zipper String)
    , map : Subway.Map City.Station City.Line
    , mapImage : String
    , location : Location
    , showStory : Bool
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
      , storyLine = Nothing
      , narrativeContent = Dict.map (\a b -> getNarrative ( a, b )) Rules.rules
      , map = City.fullMap
      , mapImage = City.mapImage City.RedYellowGreenMap
      , location = OnTrain { line = Red, status = InTransit, desiredStop = TwinBrooks }
      , showStory = False
      , showMap = False
      }
        |> updateStory "intro"
    , delay introDelay (ShowStory True)
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


findEntity : String -> Entity
findEntity id =
    (Manifest.items ++ Manifest.locations ++ Manifest.characters)
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (entity id)


updateStory : String -> Model -> Model
updateStory interactableId model =
    let
        ( newEngineModel, maybeMatchedRuleId ) =
            Engine.update interactableId model.engineModel

        narrativeForThisInteraction =
            maybeMatchedRuleId
                |> Maybe.andThen (\id -> Dict.get id model.narrativeContent)
                |> Maybe.map Zipper.current

        updateNarrativeContent : Maybe (Zipper String) -> Maybe (Zipper String)
        updateNarrativeContent =
            Maybe.andThen (\narrative -> Zipper.next narrative)

        updatedContent =
            maybeMatchedRuleId
                |> Maybe.map (\id -> Dict.update id updateNarrativeContent model.narrativeContent)
                |> Maybe.withDefault model.narrativeContent
    in
    { model
        | engineModel = newEngineModel
        , storyLine = narrativeForThisInteraction
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
                    , showStory = False
                  }
                    |> updateStory "train"
                , delay departingDelay (ShowStory True)
                )

            ShowStory yesNo ->
                ( { model | showStory = yesNo }
                , Cmd.none
                )

            Continue ->
                -- note, use scriptedEvents to respond special to Continue's
                case model.location of
                    InStation _ ->
                        ( { model | showStory = False }, Cmd.none )

                    OnTrain ({ desiredStop } as train) ->
                        ( { model
                            | location = OnTrain <| changeTrainStatus Arriving train
                            , showStory = False
                          }
                        , delay arrivingDelay <| Disembark desiredStop
                        )

            Disembark station ->
                ( { model
                    | location = InStation Lobby
                    , showStory = False
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
    -- let
    --     showTheMap =
    --         Debug.log (Subway.graphViz (stationInfo >> .name) (lineInfo >> .name) City.fullMap ++ "\n") "Copy and paste in http://viz-js.com/"
    -- in
    div [ class "game" ]
        [ gameView model
        ]


gameView : Model -> Html Msg
gameView model =
    let
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
    div []
        [ case model.location of
            InStation Lobby ->
                Lobby.view currentStation

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
        , if model.showStory then
            Maybe.map storyView model.storyLine
                |> Maybe.withDefault (text "... no story for this state ...")

          else
            text ""
        ]


storyView : String -> Html Msg
storyView storyLine =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( storyLine
          , div [ class "StoryLine__content" ]
                [ Markdown.toHtml [] storyLine
                , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
                ]
          )
        ]


mapView : String -> Html Msg
mapView mapImage =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ mapImage ] []
        ]
