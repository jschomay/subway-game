module LocalTypes exposing (Model, Msg(..), Rule, Rules, Scene(..), TrainProps, TrainStatus(..))

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
    , scene : Scene
    , ruleMatchCounts : Dict RuleID Int
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
    | Go Scene
    | BoardTrain Line Station
    | Disembark
    | Continue


type alias Rule =
    Rules.Rule
        { narrative : Narrative
        }


type alias Rules =
    Dict String Rule


type TrainStatus
    = InTransit
    | Arriving


type alias TrainProps =
    { line : Line
    , status : TrainStatus
    }


type Scene
    = Home
    | Lobby
    | Turnstile Line
    | Platform Line
    | Train TrainProps
    | CentralGuardOffice