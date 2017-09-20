module Rules exposing (..)

import Engine exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import Narrative


{-| This specifies the initial story world model.  At a minimum, you need to set a starting location with the `moveTo` command.  You may also want to place various items and characters in different locations.  You can also specify a starting scene if required.
-}
startingState : List Engine.ChangeWorldCommand
startingState =
    [ moveTo "platform"
    , loadScene "meetSteve"
    ]


{-| A simple helper for making rules, since I want all of my rules to include RuleData and Narrative components.
-}
rule : String -> Engine.Rule -> List String -> Entity
rule id ruleData narrative =
    entity id
        |> addRuleData ruleData
        |> addNarrative narrative


{-| All of the rules that govern your story.  The first parameter to `rule` is an id for that rule.  It must be unique, but generally isn't used directly anywhere else (though it gets returned from `Engine.update`, so you could do some special behavior if a specific rule matches).  I like to write a short summary of what the rule is for as the id to help me easily identify them.
Also, order does not matter, but I like to organize the rules by the story objects they are triggered by.  This makes it easier to ensure I have set up the correct criteria so the right rule will match at the right time.
Note that the ids used in the rules must match the ids set in `Manifest.elm`.
-}
rules : Dict String Components
rules =
    Dict.fromList <|
        []
            ++ -- train
               [ rule "meet steve (train)"
                    { interaction = with "train"
                    , conditions =
                        [ currentSceneIs "meetSteve"
                        ]
                    , changes =
                        []
                    }
                    Narrative.meetSteveTrain
               ]
            ++ -- platform
               [ rule "meet steve (platform)"
                    { interaction = with "platform"
                    , conditions =
                        [ currentSceneIs "meetSteve"
                        ]
                    , changes =
                        []
                    }
                    Narrative.meetStevePlatform
               ]
