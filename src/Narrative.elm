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
A crowd of people wait at the West Mulberry metro station for the 6:05 Red Line to Twin Brooks to arrive.

One man in the crowd wears a rumpled business suit.  He paces anxiously up and down the platform.  His face is ashen, his hair thinning, even though he is only in his early 30's.

This is Steve.

<span style="font-style: italic; font-size: 0.7em;">
(click on the Map below to see a map of the Red Line stops)
</span>

<span style="font-style: italic; font-size: 0.7em;">
(click on the Red Line towards Spring Hill to take the train)
</span>
"""
    , """
Down in the metro each day looks like every other.  The same crowds, the same sounds, the same artificial lights.

The only difference is that Steve has a different color tie today.
"""
    , """
Steve seems more anxious today.  Something is bothering him.  More than usual.
"""
    , """
Steve looks like he has been up all night working on the presentation.
"""
    , """
Steve looks like shit.  He rushes onto the platform just as the train is leaving.

As it pulls away he curses out loud.  Other commuters look at him and move away.  He waits impatiently for the next train to arrive.
"""
    ]


meetSteveTrain : List String
meetSteveTrain =
    [ """
Steve takes this train every day to get to work.

He works at a top financial institution downtown.  Jason, his boss, works him hard.  He keeps promising Steve a promotion if he does a good job.

Steve does his best to please Jason, working over-time and even giving up some weekends.

It's been 3 years now, and Steve still hasn't gotten a promotion.  He keeps telling himself he just has to work harder.
"""
    , """
Although the train car is full of other commuters, Steve is lost in his own mind.

He worries constantly about work.  His mother left another voicemail this morning, nagging him to make plans to visit over Thanksgiving, but there just isn't enough time in the day to make plans.  He promises himself to call her tonight though he doesn't know what he will say.

Besides, he isn't sure yet if Jason will need him to put in some hours over the holiday.
"""
    , """
As the train hurtles through the subterranean tunnels Steve replays his conversation with Jason the day before.

Jason told him that some important investors are arriving on Friday, and he wants Steve to give them a presentation.  Of course, Steve said yes.  It will be a great opportunity to impress Jason.  He might even get that promotion.  It won't be easy though, under normal circumstances he would ask for a week to prepare.  Jason only gave him two days notice.
"""
    , """
Steve's mind races over his progress.  He got a lot done, but there's so much more to do before tomorrow.  He doesn't even notice the ticket inspector coming down the train.

"Tickets please."

Maybe Jason will let him leave early to finish it up.  But if he asks, Jason might think --

"Tickets!"

The inspector glares at Steve, startling him from his thoughts.  He shows his commuter pass for the Red Line and the inspector grumbles and moves on.
"""
    , """
Steve plops into his seat, sweating.  He didn't sleep a wink.  He is so tired.

He didn't finish gathering all of the numbers.  He'll have to wing that part.  Hopefully they won't notice.

So tired...

How can he possibly make a good impression being so tired...

He'll just have to...  He'll just...
"""
    ]


gotToGetBackTrain : List String
gotToGetBackTrain =
    [ """
You find yourself slouched over in an empty train car.

A man in train operator overalls shakes your shoulder, "Hey Buddy.  It's the end of the line, you've got to get off."

End of the line?  Oh no, you fell asleep!  You missed your stop!  Your presentation!
"""
    , """
Three stops.  There's still time to get in before Jason finds out you're late.
"""
    ]


gotToGetBackPlatform : List String
gotToGetBackPlatform =
    [ """
How could you have let yourself fall asleep?!  Today of all days.  Jason will kill you.

Ok, don't panic.  You just have to get back to the Metro Center stop.  Then you can give your presentation and everything will be fine.
""" ]
