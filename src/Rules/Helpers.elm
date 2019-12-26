module Rules.Helpers exposing (StringRule, rule)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import NarrativeEngine.Core.Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Utils.NarrativeParser exposing (..)
import Subway exposing (Station)


type alias StringRule =
    { trigger : String
    , conditions : List String
    , changes : List String
    }


rule : RuleID -> StringRule -> ( RuleID, StringRule )
rule =
    Tuple.pair
