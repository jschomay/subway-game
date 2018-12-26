module LocalTypes exposing (Location(..), Msg(..), StationArea(..), TrainProps, TrainStatus(..))

import City exposing (..)


type Msg
    = NoOp
    | LoadScene (List String)
    | Interact String
    | Loaded
    | Delay Float Msg
    | ToggleMap
    | Go StationArea
    | BoardTrain Line Station
    | Disembark
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
    }


type Location
    = OnTrain TrainProps
    | InStation StationArea
