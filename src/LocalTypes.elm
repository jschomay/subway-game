module LocalTypes exposing (Location(..), Msg(..), StationArea(..), TrainProps, TrainStatus(..))

import City exposing (..)


type Msg
    = NoOp
    | Interact String
    | Loaded
    | Delay Float Msg
    | ToggleMap
    | Go StationArea
    | BoardTrain Line Station
    | Disembark Station
    | Continue


type StationArea
    = Platform Line
    | Hall
    | Lobby


type TrainStatus
    = InTransit
    | Arriving


type alias TrainProps =
    { line : Line
    , status : TrainStatus
    , desiredStop : Station
    }


type Location
    = OnTrain TrainProps
    | InStation StationArea
