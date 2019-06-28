module Constants exposing (chapters, characterStats, distractions, scenes)

import Array


{-| Constants for the entities, stats, scenes, etc used in the manifest and rules. Created as a record to get some compiletime type checking on the otherwise string/int ids/values.
-}
scenes =
    { intro = 1
    , lostBriefcase = 2
    , wildGooseChase = 3
    , endOfDemo = 4
    }


characterStats =
    [ { id = "bravery", name = "Bravery", starting = 0 }
    , { id = "ruleBreaker", name = "Rule breaker", starting = 0 }
    ]



-- TODO list goals as entities (tags active/completed) with descriptions
-- add goals via rules rather than per chapter here


{-| Named chapters for main plot, displayed in UI
-}
chapters =
    Array.fromList
        [ ( "Deadline", [ "Give your 9AM presentation" ] )
        , ( "Stop, Thief!", [ "Retrieve your briefcase", "Get to work in time to present" ] )
        , ( "Stuck underground", [ "Track the thief", "END OF DEMO!", "THANK YOU FOR PLAYING!" ] )
        ]



-- TODO distractions should be the same as goals, but with (sidequest tag)
-- which means we don't need to track these separately
-- These will have one name, and the description will change over time based on the level of the plot (using conditional narrative)


distractions =
    [ { id = "downTheRabbitHole"
      , name = "Down the rabbit hole"
      , chapters =
            Array.fromList
                [ "Who was that girl in the yellow dress?"
                ]
      }
    ]
