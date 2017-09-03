port module Main exposing (..)

import Engine exposing (..)
import Manifest
import Rules
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tuple


-- import Theme.Layout

import ClientTypes exposing (..)
import Narrative
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Subway
import Color


{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


main : Program Never Model ClientTypes.Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , storyLine : List StorySnippet
    , narrativeContent : Dict String (Zipper String)
    , location : Location
    , showMap : Bool
    }


type Location
    = OnPlatform Subway.Station
    | OnTrain Subway.Train Subway.Station
    | InStation Subway.Station


init : ( Model, Cmd ClientTypes.Msg )
init =
    let
        engineModel =
            Engine.init
                { items = List.map Tuple.first Manifest.items
                , locations = List.map Tuple.first Manifest.locations
                , characters = List.map Tuple.first Manifest.characters
                }
                (Dict.map (curry getRuleData) Rules.rules)
                |> Engine.changeWorld Rules.startingState
    in
        ( { engineModel = engineModel
          , loaded = False
          , storyLine = [ Narrative.startingNarrative ]
          , narrativeContent = Dict.map (curry getNarrative) Rules.rules
          , location = OnTrain (Subway.Train Subway.Red Subway.OutGoing) Subway.Market
          , showMap = False
          }
        , Cmd.none
        )


findEntity : String -> Entity
findEntity id =
    (Manifest.items ++ Manifest.locations ++ Manifest.characters)
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (entity id)


update :
    ClientTypes.Msg
    -> Model
    -> ( Model, Cmd ClientTypes.Msg )
update msg model =
    if Engine.getEnding model.engineModel /= Nothing then
        -- no-op if story has ended
        ( model, Cmd.none )
    else
        case msg of
            Interact interactableId ->
                let
                    ( newEngineModel, maybeMatchedRuleId ) =
                        Engine.update interactableId model.engineModel

                    {- If the engine found a matching rule, look up the narrative content component for that rule if possible.  The description from the display info component for the entity that was interacted with is used as a default. -}
                    narrativeForThisInteraction =
                        { interactableName = findEntity interactableId |> getDisplayInfo |> .name
                        , interactableCssSelector = findEntity interactableId |> getClassName
                        , narrative =
                            maybeMatchedRuleId
                                |> Maybe.andThen (\id -> Dict.get id model.narrativeContent)
                                |> Maybe.map Zipper.current
                                |> Maybe.withDefault (findEntity interactableId |> getDisplayInfo |> .description)
                        }

                    {- If a rule matched, attempt to move to the next associated narrative content for next time. -}
                    updateNarrativeContent : Maybe (Zipper String) -> Maybe (Zipper String)
                    updateNarrativeContent =
                        Maybe.map (\narrative -> Zipper.next narrative |> Maybe.withDefault narrative)

                    updatedContent =
                        maybeMatchedRuleId
                            |> Maybe.map (\id -> Dict.update id updateNarrativeContent model.narrativeContent)
                            |> Maybe.withDefault model.narrativeContent
                in
                    ( { model
                        | engineModel = newEngineModel
                        , storyLine = narrativeForThisInteraction :: model.storyLine
                        , narrativeContent = updatedContent
                      }
                    , Cmd.none
                    )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            ToggleMap ->
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            BoardTrain train ->
                let
                    leavingStation =
                        case model.location of
                            OnTrain train station ->
                                station

                            OnPlatform station ->
                                station

                            InStation station ->
                                station
                in
                    ( { model | location = OnTrain train leavingStation }
                    , Cmd.none
                    )

            ExitTrain ->
                let
                    station =
                        case model.location of
                            OnTrain train station ->
                                station

                            OnPlatform station ->
                                station

                            InStation station ->
                                station
                in
                    ( { model | location = OnPlatform station }
                    , Cmd.none
                    )

            ArriveAtStation ->
                let
                    location =
                        case model.location of
                            OnTrain train previousStation ->
                                Subway.nextStop Subway.fullMap train previousStation
                                    |> Maybe.withDefault previousStation
                                    |> OnTrain train

                            x ->
                                x
                in
                    ( { model | location = location }
                    , Cmd.none
                    )


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    loaded <| always Loaded


view :
    Model
    -> Html ClientTypes.Msg
view model =
    let
        currentLocation =
            Engine.getCurrentLocation model.engineModel |> findEntity

        displayState =
            { currentLocation = currentLocation
            , itemsInCurrentLocation =
                Engine.getItemsInCurrentLocation model.engineModel
                    |> List.map findEntity
            , charactersInCurrentLocation =
                Engine.getCharactersInCurrentLocation model.engineModel
                    |> List.map findEntity
            , exits =
                getExits currentLocation
                    |> List.map
                        (\( direction, id ) ->
                            ( direction, findEntity id )
                        )
            , itemsInInventory =
                Engine.getItemsInInventory model.engineModel
                    |> List.map findEntity
            , ending =
                Engine.getEnding model.engineModel
            , storyLine =
                model.storyLine
            }

        graphViz =
            textarea [] [ text <| Subway.draw ]
    in
        div [ class "game" ]
            [ gameView model
            , if model.showMap then
                mapView
              else
                div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]
            ]


gameView : Model -> Html Msg
gameView model =
    case model.location of
        InStation station ->
            text "In the station..."

        OnPlatform station ->
            platformView <| Subway.stationInfo station

        OnTrain train station ->
            trainView
                { nextStop = Subway.nextStop Subway.fullMap train station
                , trainInfo = Subway.trainInfo train
                }


platformView : Subway.StationInfo Msg -> Html Msg
platformView { name, connections } =
    let
        connectionView connection =
            li [ class "connection", onClick <| connection.msg BoardTrain ]
                [ div
                    [ class "connection__number"
                    , style [ ( "color", toColor connection.color ), ( "borderColor", toColor connection.color ) ]
                    ]
                    [ text <| toString connection.number ]
                , div [ class "connection__direction" ] [ text (Subway.stationInfo connection.direction |> .name) ]
                ]

        connectionsView connections =
            ul [ class "platform_info__connections" ]
                (connections
                    |> List.sortBy .number
                    |> List.map connectionView
                )
    in
        div [ class "platform" ]
            [ div [ class "platform__story" ] [ storyView ]
            , div [ class "platform__platform_info" ]
                [ div [ class "platform_info" ]
                    [ h2 [ class "platform_info__name" ] [ text name ]
                    , connectionsView connections
                    ]
                ]
            ]


storyView : Html Msg
storyView =
    ul [ class "story" ]
        [ li [] [ text """
        The hydraulic sounds of the clunky engine dissipates slowly, and all that remains to be heard is the quiet humming and flickering of the fluorescent lights above.
        """ ]
        , li [] [ text """
        Steve exits the subway car frantically, searching for a subway engineer or an overhead map back to his stop, Imperial Ave. He searches for any workers on the platform, shouting for help. Steve realizes that he is alone in the dimly lit ghost station. He searches for a way out, but to no avail, he finds no escalator or stairs. He wanders down the end of the tracks and finally finds an old map behind a shattered laminated case. Etched in the plastic case is an inscription with
        """ ]
        , li [] [ text """
        sharp angular letters that read: "UR STUCK". Steve looks at the inscription with one raised eyebrow, and as if in agreement, nods and says to himself with a wry chuckle, "in more ways than one."
        """ ]
        , li [] [ text """
        As he waits, he thinks that he hears faint sounds of jeering laughter in the dark distant tunnels, as if a television or radio was left on in the dark expanse of the tunnels. The pitter patter of tiny feet lull Steve into an even deeper state of dread. "It's just mice," he tells himself. A bead of sweat perspires from his neck, rolling all the way down his collar onto his scuffed up black wing tips. As Steve looks down at the droplet, he is startled by the sound of the oncoming Y line, rushing past his nose without any warning. Time seemed to slow down and speed up at that instant. Steve shrugs, and thinks aloud: "God damn, I need another coffee. I am seriously out of the loop today." He looks around in his subway car, and notices it is empty. Hopping on reluctantly, he sits on a seat nearest to the door, setting down his briefcase with a sigh of brief relief. As the doors close and the subway car begins to move into the tunnels,
        Steve briefly glimpses a yellow shape dart out from the opposite tunnel tracks.
        """ ]
        , li [] [ text """
        "I'm really losin' it," he says as he laughs nervously to himself. As the car moves into the dark depths of the tunnel, he closes his eyes, shakes his head, and clenches his fists. "Just a few stops left..." he says three times to himself, recalling an image of Dorothy from his favorite childhood film, 'The Wizard of Oz.'

        """ ]
        , li [] [ text """
        As the first stop approaches, Steve squints, unable to recognize the platform. The automated subway speakers click loudly, attempting to name the stop. All Steve hears is a garbled collection of robotic syllables and a few missed words, as if listening to a scratched CD or busted tape cassette.

        """ ]
        , li [] [ text """
        There are no signs hanging above the platform. There is no graffiti or advertisements on the white dusty walls, nor are there any people on the platform. Steve feels another pang of dread jab him in the gut. "Where the hell am I going?" he shouts aloud. He waits again for the next stop. As the subway slows, Steve's lurking horrors manifest themselves on the platform: staring out the window, Steve sees nothing but a replica of the last stop. Bewildered, he sits quietly. His
        mind races: fight or flight instincts kick in. As the doors close shut, Steve feels the walls of the station close in on him; his palms are clammy and he feels faint. "Calm down! It's only your imagination, Horowitz," he shouts at his reflection in the gritty glass window. "I really hope this is a shitty stress dream." Two more stops go by: all Steve sees before him are copies of copies of copies of the same ghost platform. "Fuuuuck."
        """ ]
        ]


trainView : { trainInfo : Subway.TrainInfo Msg, nextStop : Maybe Subway.Station } -> Html Msg
trainView { trainInfo, nextStop } =
    let
        display =
            nextStop
                |> Maybe.map (Subway.stationInfo >> .name >> (++) " - next stop ")
                |> Maybe.withDefault " - end of the line"
    in
        div [ class "train" ] <|
            [ div [ class "train__story" ] [ storyView ]
            , h3 [ class "train__ticker" ] [ text <| trainInfo.name ++ display ]
            , div [ class "train__train_info" ]
                [ div [ class "train_info" ]
                    [ button [ class "train_info__exit_button", onClick <| ExitTrain ] [ text "Exit train" ]
                    , button [ onClick <| ArriveAtStation ] [ text "Continue" ]
                    ]
                ]
            ]


mapView : Html Msg
mapView =
    div [ onClick ToggleMap, class "map" ]
        [ pre [ class "map__image", style [ ( "fontFamily", "monospace" ) ] ] [ text """
                                         red line
                         / ----------------------------- o EastEnd
                       / / --------------------------- / |
                     / /           yellow line           |
                   / /                                   |
            Market o                                     |
                   | \\                   / ------------- /
                   |   \\               /    green line
        red line   |     \\           /
         ---------/        \\       /
       /                     \\ --- o Central
       |                           |
       |                           |
       |                           |
       |         green line        |
       o ------------------------- /
    WestEnd


   red line - WestEnd, Market, EastEnd
   green line - WestEnd, Central, EastEnd
   yellow line - Central, Market, EastEnd
""" ]
        ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> \{ red, green, blue } -> "rgb(" ++ toString red ++ "," ++ toString green ++ "," ++ toString blue ++ ")"
