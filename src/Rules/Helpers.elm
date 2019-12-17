module Rules.Helpers exposing (TextRule, rule)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Subway exposing (Station)


type alias TextRule =
    { trigger : String
    , conditions : List String
    , changes : List String
    }


rule : RuleID -> TextRule -> ( RuleID, TextRule )
rule =
    Tuple.pair
