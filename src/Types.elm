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
    | LeavePlatform
    | RemoveTitleCard


type TrainStatus
    = Stopped
    | Moving


type Location
    = OnPlatform City.Station
    | OnTrain ( City.Line, City.Station ) City.Station TrainStatus
    | InStation City.Station
