module Types exposing (..)

import Time exposing (Time)
import City exposing (..)


type Msg
    = Interact String
    | Loaded
    | Delay Time Msg
    | ToggleMap
    | BoardTrain ( City.Line, City.Station )
    | ExitTrain
    | ArriveAtPlatform City.Station
    | SafeToExit
    | LeavePlatform
    | RemoveTitleCard
    | Continue


type TrainStatus
    = Stopped
    | Moving
    | OutOfService


type Location
    = OnPlatform
    | OnTrain ( City.Line, City.Station ) TrainStatus
    | InStation
