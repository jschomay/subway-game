module Constants exposing (characterStats, distractions, goals, scenes)

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


goals =
    [ { id = "mainPlot"
      , name = "Main"
      , chapters =
            Array.fromList
                [ "Overslept!  Get back to your stop."
                , "Thief!  Retrieve your briefcase."
                , "Caught!"
                ]
      }
    ]


distractions =
    [ { id = "downTheRabbitHole"
      , name = "Down the rabbit hole"
      , chapters =
            Array.fromList
                [ "The girl in the yellow dress."
                ]
      }
    ]
