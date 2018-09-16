module Types exposing (Location(..), Msg(..), Train, TrainStatus(..))

import City exposing (..)
import Time exposing (Time)


type alias Train =
    -- line and direction
    ( Line, Station )


type Msg
    = Interact String
    | Loaded
    | Delay Time Msg
    | ToggleMap
    | PassTurnStyle
    | BoardTrain Train
    | ExitTrain
    | ArriveAtStation Station
    | LeaveStation
    | RemoveTitleCard
    | Continue


type TrainStatus
    = Stopped
    | Moving
    | OutOfService


type Location
    = OnTrain Train TrainStatus
    | InStation
    | InConnectingHalls
