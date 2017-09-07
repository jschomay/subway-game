module ClientTypes exposing (..)

import Subway
import Time exposing (Time)


type Msg
    = Interact String
    | Loaded
    | Delay Time Msg
    | ToggleMap
    | BoardTrain Subway.Train
    | ExitTrain
    | ArriveAtPlatform Subway.Station
    | LeavePlatform


type alias StorySnippet =
    { interactableName : String
    , interactableCssSelector : String
    , narrative : String
    }
