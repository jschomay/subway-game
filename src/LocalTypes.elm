module LocalTypes exposing (Location(..), Model, Msg(..), Rule, Rules, StationArea(..), TrainProps, TrainStatus(..))

import City exposing (..)
import Dict exposing (Dict)
import Manifest
import Narrative exposing (..)
import Narrative.Rules as Rules exposing (..)
import Narrative.WorldModel exposing (..)


type alias Model =
    { worldModel : Manifest.WorldModel
    , loaded : Bool
    , story : List String
    , rules : Rules
    , location : Location
    , showMap : Bool
    , gameOver : Bool
    , selectScene : Bool
    , history : List String
    , pendingChanges : Maybe ( Narrative.WorldModel.ID, List ChangeWorld )
    }


type Msg
    = NoOp
    | LoadScene ( Model, List String )
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
        { narrative : Narrative
        }


type alias Rules =
    Dict String Rule


type StationArea
    = Platform Line
    | Turnstile Line
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
    | CentralGuardOffice
