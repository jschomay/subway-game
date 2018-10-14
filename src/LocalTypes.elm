module LocalTypes exposing
    ( Location(..)
    , Msg(..)
    , StationArea(..)
    , Train
    , TrainStatus(..)
    )

import City exposing (..)


type alias Train =
    -- line and direction
    ( Line, Station )


type Msg
    = Interact String
    | Loaded
    | Delay Float Msg
    | ToggleMap
    | Go Location
      -- TODO remove all the movement msg and use Go location
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


type StationArea
    = Platform Line
    | Hall
    | Lobby


type Location
    = OnTrain Train TrainStatus
    | InStation StationArea
