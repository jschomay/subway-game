module Rules.Helpers exposing (TextRule, rule, rulesForScene)

import Constants exposing (..)
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


rulesForScene : Int -> List ( String, TextRule ) -> List ( String, TextRule )
rulesForScene scene rules_ =
    rules_
        |> List.map
            (\( id, { conditions } as r ) ->
                ( id, { r | conditions = ("PLAYER.chapter=" ++ String.fromInt scene) :: conditions } )
            )
