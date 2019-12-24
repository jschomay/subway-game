module Rules.Helpers exposing (TextRule, rule)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import NarrativeEngine.Core.Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Utils.NarrativeParser exposing (..)
import Subway exposing (Station)


type alias TextRule =
    { trigger : String
    , conditions : List String
    , changes : List String
    }


rule : RuleID -> TextRule -> ( RuleID, TextRule )
rule =
    Tuple.pair
