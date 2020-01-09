module LocalTypes exposing (Model, Msg(..), Rule, Rules, Scene(..), TrainProps, TrainStatus(..))

import Dict exposing (Dict)
import Manifest
import NarrativeEngine.Core.Rules as Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Debug as Debug
import NarrativeEngine.Utils.NarrativeParser exposing (..)
import Subway exposing (..)


type alias Model =
    { worldModel : Manifest.WorldModel
    , loaded : Bool
    , story : List String
    , scene : Scene
    , ruleMatchCounts : Dict RuleID Int
    , showMap : Bool
    , showNotebook : Bool
    , showTranscript : Bool
    , gameOver : Bool
    , debugState : Maybe Debug.State
    , showSelectScene : Bool
    , history : List String
    , transcript : List String
    , pendingChanges : Maybe ( ID, List ChangeWorld, RuleID )
    }


type Msg
    = NoOp
    | LoadScene ( Model, List String )
    | Interact String
    | Loaded
    | Delay Float Msg
    | ToggleMap
    | ToggleNotebook
    | Go Scene
    | BoardTrain Line Station
    | Disembark
    | Continue
    | Achievement String
    | ToggleTranscript
    | DebugSeachWorldModel String


type alias Rule =
    Rules.Rule {}


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
    = Title String
    | Lobby
    | Turnstile Line
    | Platform Line
    | Train TrainProps
    | CentralGuardOffice
