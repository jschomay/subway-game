module LocalTypes exposing (Model, Msg(..), NoteBookPage(..), Rule, Rules, Scene(..), TrainProps, TrainStatus(..))

import Dict exposing (Dict)
import Manifest
import NarrativeEngine.Core.Rules as Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Debug as Debug
import NarrativeEngine.Syntax.NarrativeParser exposing (..)
import Subway exposing (..)


type alias Model =
    { worldModel : Manifest.WorldModel
    , loaded : Bool
    , story : List String
    , scene : Scene
    , ruleMatchCounts : Dict RuleID Int
    , showMap : Bool
    , showNotebook : Bool
    , noteBookPage : NoteBookPage
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
    | ToggleMap
    | ToggleNotebook
    | Go Scene
    | BoardTrain Line Station
    | Disembark
    | DisembarkStory
    | Continue
    | Achievement String
    | ToggleTranscript
    | ToggleNotebookPage
    | DebugSeachWorldModel String


type alias Rule =
    Rules.Rule {}


type alias Rules =
    Dict String Rule


type TrainStatus
    = InTransit
    | Arriving


type NoteBookPage
    = Goals
    | Distractions


type alias TrainProps =
    { line : Line
    , status : TrainStatus
    }


type Scene
    = Title String
    | MainTitle
    | Lobby
    | Turnstile Line
    | Platform Line
    | Train TrainProps
    | Passageway
    | CentralGuardOffice
