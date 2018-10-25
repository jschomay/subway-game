module Rules exposing (rule, rules, startingState, station)

import City exposing (Station(..), stationInfo)
import Components exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)
import Narrative


{-| This specifies the initial story world model. At a minimum, you need to set a starting location with the `moveTo` command. You may also want to place various items and characters in different locations. You can also specify a starting scene if required.
-}
startingState : List Engine.ChangeWorldCommand
startingState =
    [ loadScene "deadline"

    -- inventory
    , moveItemToInventory "briefcase"
    , moveItemToInventory "redLinePass"
    , moveItemToInventory "cellPhone"

    -- characters
    , moveCharacterToLocation "securityGuard" (station TwinBrooks)
    , moveCharacterToLocation "largeCrowd" (station MetroCenter)

    -- items
    , moveItemToLocationFixed "safteyWarningPoster" (station TwinBrooks)
    , moveItemToLocationFixed "mapPoster" (station TwinBrooks)
    ]


{-| A simple helper for making rules, since I want all of my rules to include RuleData and Narrative components.
-}
rule : String -> Engine.Rule -> List String -> Entity
rule id ruleData narrative =
    entity id
        |> addRuleData ruleData
        |> addNarrative narrative


station : Station -> String
station station_ =
    station_ |> stationInfo |> .id |> String.fromInt


{-| All of the rules that govern your story. The first parameter to `rule` is an id for that rule. It must be unique, but generally isn't used directly anywhere else (though it gets returned from `Engine.update`, so you could do some special behavior if a specific rule matches). I like to write a short summary of what the rule is for as the id to help me easily identify them.
Also, order does not matter, but I like to organize the rules by the story objects they are triggered by. This makes it easier to ensure I have set up the correct criteria so the right rule will match at the right time.
Note that the ids used in the rules must match the ids set in `Manifest.elm`.

"intro" and "train" are two special programatic triggers.

-}
rules : Dict String Components
rules =
    Dict.fromList <|
        []
            -- story events - intro
            ++ [ rule "intro, deadline, miss stop"
                    { interaction = with "intro"
                    , conditions =
                        [ currentSceneIs "deadline"
                        ]
                    , changes =
                        [ moveTo <| station TwinBrooks ]
                    }
                    Narrative.intro
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { interaction = with "mapPoster"
                    , conditions =
                        [ currentSceneIs "deadline"
                        , currentLocationIs <| station TwinBrooks
                        ]
                    , changes = []
                    }
                    Narrative.missedStop
               ]
            ++ -- train
               [ rule "missedStopAgain"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "deadline"
                        , currentLocationIsNot <| station MetroCenter
                        ]
                    , changes = []
                    }
                    Narrative.missedStopAgain
               , rule "delayAhead"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "deadline"
                        , currentLocationIs <| station MetroCenter
                        ]
                    , changes = [ moveCharacterToLocation "securityOfficers" <| station MetroCenter ]
                    }
                    Narrative.delayAhead
               , rule "endOfDemo"
                    { interaction = with "train"
                    , conditions = [ currentSceneIs "wildGooseChase" ]
                    , changes = [ loadScene "endOfDemo" ]
                    }
                    Narrative.endOfDemo
               , rule "riding the train"
                    { interaction = with "train"
                    , conditions = []
                    , changes = []
                    }
                    Narrative.ridingTheTrain
               ]
            ++ [ rule ""
                    { interaction = with "securityGuard"
                    , conditions =
                        [ currentSceneIs "deadline" ]
                    , changes = []
                    }
                    Narrative.inquireHowToGetBack
               ]
            ++ -- cellPHone
               [ rule "tryCellPhone"
                    { interaction = with "cellPHone"
                    , conditions = []
                    , changes = []
                    }
                    Narrative.tryCellPhone
               ]
            ++ -- largeCrowd
               [ rule "exitClosedBriefcaseStolen"
                    { interaction = with "largeCrowd"
                    , conditions =
                        [ currentSceneIs "deadline"
                        , currentLocationIs <| station MetroCenter
                        , itemIsInInventory "briefcase"
                        ]
                    , changes =
                        [ loadScene "lostBriefcase"
                        , moveItemOffScreen "briefcase"
                        ]
                    }
                    Narrative.exitClosedBriefcaseStolen
               ]
            ++ -- securityOfficers
               [ rule "askAboutDelay"
                    { interaction = with "securityOfficers"
                    , conditions =
                        [ currentSceneIs "deadline"
                        , characterIsInLocation "largeCrowd" <| station MetroCenter
                        , itemIsInInventory "briefcase"
                        ]
                    , changes = []
                    }
                    Narrative.askAboutDelay
               , rule "reportStolenBriefcase"
                    { interaction = with "securityOfficers"
                    , conditions =
                        [ currentSceneIs "lostBriefcase"
                        , characterIsInLocation "largeCrowd" <| station MetroCenter
                        , itemIsNotInInventory "briefcase"
                        ]
                    , changes =
                        [ moveItemToLocationFixed "policeOffice" <| station FederalTriangle
                        , moveItemToLocationFixed "ticketMachine" <| station FederalTriangle
                        ]
                    }
                    Narrative.reportStolenBriefcase
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { interaction = with "policeOffice"
                    , conditions = [ currentSceneIs "lostBriefcase" ]
                    , changes =
                        [ loadScene "wildGooseChase"
                        , moveCharacterOffScreen "securityOfficers"
                        , moveCharacterOffScreen "largeCrowd"
                        ]
                    }
                    Narrative.redirectedToLostAndFound
               ]
