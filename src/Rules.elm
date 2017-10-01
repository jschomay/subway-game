module Rules exposing (..)

import Engine exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import Narrative
import City exposing (Station(..), stationInfo)


{-| This specifies the initial story world model.  At a minimum, you need to set a starting location with the `moveTo` command.  You may also want to place various items and characters in different locations.  You can also specify a starting scene if required.
-}
startingState : List Engine.ChangeWorldCommand
startingState =
    [ loadScene "meetSteve" ]


{-| A simple helper for making rules, since I want all of my rules to include RuleData and Narrative components.
-}
rule : String -> Engine.Rule -> List String -> Entity
rule id ruleData narrative =
    entity id
        |> addRuleData ruleData
        |> addNarrative narrative


station : Station -> String
station station =
    station |> stationInfo |> .id |> toString


{-| All of the rules that govern your story.  The first parameter to `rule` is an id for that rule.  It must be unique, but generally isn't used directly anywhere else (though it gets returned from `Engine.update`, so you could do some special behavior if a specific rule matches).  I like to write a short summary of what the rule is for as the id to help me easily identify them.
Also, order does not matter, but I like to organize the rules by the story objects they are triggered by.  This makes it easier to ensure I have set up the correct criteria so the right rule will match at the right time.
Note that the ids used in the rules must match the ids set in `Manifest.elm`.
-}
rules : Dict String Components
rules =
    Dict.fromList <|
        []
            -- story events
            ++
                [ rule "meeting steve (platform)"
                    { interaction = with "nextDay"
                    , conditions =
                        [ currentSceneIs "meetSteve"
                        ]
                    , changes =
                        [ moveTo <| station WestMulberry ]
                    }
                    Narrative.introPlatform
                , rule "fall asleep and miss your stop"
                    { interaction = with "fallAsleep"
                    , conditions =
                        [ currentSceneIs "meetSteve"
                        ]
                    , changes =
                        [ loadScene "overslept"
                        , moveTo <| station TwinBrooks
                        ]
                    }
                    Narrative.fellAsleep
                , rule "stopped at Federal Triangle"
                    { interaction = with "outOfService"
                    , conditions =
                        [ currentSceneIs "overslept"
                        ]
                    , changes =
                        [ loadScene "detour" ]
                    }
                    Narrative.outOfService
                ]
            ++ -- train
               [ rule "meeting steve (train)"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "meetSteve"
                        ]
                    , changes =
                        []
                    }
                    Narrative.introTrain
               , rule "got to get back (train)"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "overslept"
                        ]
                    , changes =
                        []
                    }
                    Narrative.gotToGetBackTrain
               , rule "detour (train)"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "detour"
                        ]
                    , changes =
                        []
                    }
                    Narrative.findANewWayTrain
               ]
            -- platform
            ++
                [ rule "got to get back (platform)"
                    { interaction = with "platform"
                    , conditions =
                        [ currentSceneIs "overslept"
                        ]
                    , changes =
                        []
                    }
                    Narrative.gotToGetBackPlatform
                , rule "detour (platform)"
                    { interaction = with "platform"
                    , conditions =
                        [ currentSceneIs "detour"
                        ]
                    , changes =
                        []
                    }
                    Narrative.findANewWayPlatform
                ]
