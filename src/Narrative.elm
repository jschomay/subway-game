module Narrative exposing (..)

{-| The text that will show when the story first starts, before the player interacts with anythin.
-}

{- Here is where you can write all of your story text, which keeps the Rules.elm file a little cleaner.
   The narrative that you add to a rule will be shown when that rule matches.  If you give a list of strings, each time the rule matches, it will show the next narrative in the list, which is nice for adding variety and texture to your story.
   I sometimes like to write all my narrative content first, then create the rules they correspond to.
   Note that you can use **markdown** in your text!
-}


meetSteve : List String
meetSteve =
    [ """
This is steve...
"""
    , """
Steve is not in control of his life.
"""
    , """
He needs a shock to the system...
"""
    , """
He needs to take the train to work now.
"""
    ]


onATrain : List String
onATrain =
    [ """
When he rides the train his mind races.
"""
    , """
He worries non-stop.
"""
    , """
But he can't forget to get off at the right stop
"""
    ]
