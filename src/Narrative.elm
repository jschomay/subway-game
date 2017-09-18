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
Monday, 6:03AM

West Mulberry metro station
"""
    , """
A crowd of people wait on the platform for the 6:05 Red Line to arrive, heading into town.
"""
    , """
One man in the crowd wears a rumpled business suit.  He paces anxiously up and down the platform.  His face is ashen, his hair thinning, even though he is only in his early 30's.

This is Steve.
"""
    , "(click on the Red Line towards Twin Brooks)"
    ]


onATrain : List String
onATrain =
    [ """
Steve takes the train every day to get to work.
"""
    , """
He works at a top notch financial institution downtown.  His boss, Jason, works him hard.  He keeps promising Steve a promotion if he does a good job.

Steve does his best to please Jason, working over-time and even giving up some weekends.
"""
    , """
It's been 3 years now, and Steve still hasn't gotten a promotion.
"""
    ]



{-

   Tuesday, 6:02AM

   Steve is here, just like yesterday.



   Steve's mind runs in circles, worrying about his boss and his career.

-}
