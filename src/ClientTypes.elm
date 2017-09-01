module ClientTypes exposing (..)

import Subway


type Msg
    = Interact String
    | Loaded
    | BoardTrain Subway.Train
    | ArriveAtStation
    | ExitTrain


type alias StorySnippet =
    { interactableName : String
    , interactableCssSelector : String
    , narrative : String
    }