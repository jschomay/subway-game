module LocalTypes exposing (Model, Msg(..), NoteBookPage(..), PersistAction(..), Rule, Rules, Scene(..), TrainProps, TrainStatus(..))

import Dict exposing (Dict)
import Manifest
import NarrativeEngine.Core.Rules as Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Debug as Debug
import NarrativeEngine.Syntax.NarrativeParser exposing (..)
import Subway exposing (..)


type alias Model =
    { worldModel : Manifest.WorldModel
    , assetsLoaded : Bool
    , loadingScene : Bool
    , persistKey : String
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
    , currentTrack : String
    , playDramaTrack : Bool
    }


type Msg
    = NoOp
    | LoadScene (List String)
    | Interact String
    | AssetsLoaded
    | ToggleMap
    | ToggleNotebook
    | BoardTrain Line Station
    | Disembark
    | DisembarkStory
    | Continue
    | Achievement String
    | ToggleTranscript
    | ToggleNotebookPage NoteBookPage
    | DebugSeachWorldModel String
    | Persist PersistAction
    | SubwaySounds
    | PlaySound String
    | StopSound String
    | AddDrama
    | RemoveDrama
    | QueueLoop String


type PersistAction
    = ListSaves
    | Save String (List String)
    | Load String
    | Delete String
    | ExistingSaves ( String, List String )
    | PersistKeyUpdate String


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
    | SavedGames (List String)


type alias TrainProps =
    { line : Line
    , status : TrainStatus
    }


type Scene
    = Title String
    | MainTitle
    | Splash
    | End
    | Lobby
    | Turnstile Line
    | Platform Line
    | Train TrainProps
    | Passageway
    | CentralGuardOffice
