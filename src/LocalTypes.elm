module LocalTypes exposing (Location(..), Msg(..), Rule, Rules, StationArea(..), TrainProps, TrainStatus(..))

import City exposing (..)
import Dict exposing (Dict)
import Narrative exposing (..)
import Narrative.Rules as Rules exposing (..)
import Narrative.WorldModel exposing (..)


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


type alias Rule =
    Rules.Rule
        { changes : List ChangeWorld
        , narrative : Narrative
        }


type alias Rules =
    Dict String Rule


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
