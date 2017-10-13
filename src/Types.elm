module Types exposing (..)

import Time exposing (Time)
import City exposing (..)


type alias Train =
    -- line and direction
    ( City.Line, City.Station )


type Msg
    = Interact String
    | Loaded
    | Delay Time Msg
    | ToggleMap
    | BoardTrain
    | EnterPlatform Train
    | ExitPlatform
    | ExitTrain
    | ArriveAtStation City.Station
    | SafeToExit
    | LeaveStation
    | RemoveTitleCard
    | Continue


type TrainStatus
    = Stopped
    | Moving
    | OutOfService


type Location
    = OnPlatform Train
    | OnTrain Train TrainStatus
    | InStation
    | InConnectingHalls
