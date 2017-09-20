module Narrative exposing (..)

{-| The text that will show when the story first starts, before the player interacts with anythin.
-}

{- Here is where you can write all of your story text, which keeps the Rules.elm file a little cleaner.
   The narrative that you add to a rule will be shown when that rule matches.  If you give a list of strings, each time the rule matches, it will show the next narrative in the list, which is nice for adding variety and texture to your story.
   I sometimes like to write all my narrative content first, then create the rules they correspond to.
   Note that you can use **markdown** in your text!
-}


meetStevePlatform : List String
meetStevePlatform =
    [ """
Monday, 6:03 AM - East Mulberry metro station

A crowd of people wait on the platform for the 6:05 Red Line to arrive, heading into town.

One man in the crowd wears a rumpled business suit.  He paces anxiously up and down the platform.  His face is ashen, his hair thinning, even though he is only in his early 30's.

This is Steve.

Steve works downtown at the Federal Triangle stop.

<span style="font-style: italic; font-size: 0.7em;">
(click on the Map below to see a map of the Red Line stops)
</span>

<span style="font-style: italic; font-size: 0.7em;">
(click on one of the Red Line directions to the right to take the train)
</span>
"""
    , """
Tuesday, 6:02 AM

Down in the metro each day looks like every other.  The same crowds, the same sounds, the same artificial lights.

The only difference is that Steve has a different color tie today.
"""
    , """
Wed ... Steve seems more anxious than usual...
"""
    , """
Thur ... looks like Steve has been up all night
"""
    , """
Friday ... Steve looks like shit
"""
    ]


meetSteveTrain : List String
meetSteveTrain =
    [ """
Steve takes this train every day to get to work.

He works at a top financial institution downtown.  Jason, his boss, works him hard.  He keeps promising Steve a promotion if he does a good job.

Steve does his best to please Jason, working over-time and even giving up some weekends.

It's been 3 years now, and Steve still hasn't gotten a promotion.  He keeps telling himself he just has to work harder.

<span style="font-style: italic; font-size: 0.7em;">
(click on the Exit button when stopped at the Federal Triangle station to leave the train)
</span>
"""
    , """
Although the train car is full of other commuters, Steve is lost in his own mind.

He worries constantly about work.  His mother left another voicemail this morning, nagging him to make plans to visit over Thanksgiving, but there just isn't enough time in the day to make plans.  He promises himself to call her tonight though he doesn't know what he will say.  Besides, he isn't sure yet if Jason will need him to put in some hours over the holiday.
"""
    , """
Wed ... assignment - presentation on Friday before vips leave town, not enought time, but this could be the opportunity to show Jason his value
"""
    , """
Thur ... progress, tired
"""
    , """
Friday ... so tired...
"""
    ]
