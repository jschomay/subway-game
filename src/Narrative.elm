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

At the center of the platform a man with well combed hair and a simple business suit stands just behind the yellow safety line.  While the other people on the platform pace around, this man stands still.  This is Steve.

The train arrives at the station.  It slows down and comes to a stop with the door directly in front of Steve.  It opens and he steps on.

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
Steve seems more anxious today.  Something is bothering him.  His yellow tie is slightly askew.
"""
    , """
Steve looks like he has been up all night working on the presentation.

When the train arrives, Steve notices he has to take two steps to his right to get to the door.
"""
    , """
Steve looks like shit.  He rushes onto the platform just as the train is leaving, missing it.

As it pulls away Steve takes a deep breath and tries to calm down.  He finds his spot behind the yellow line and waits for the next one.  He wishes he had time for another cup of coffee.
"""
    ]


meetSteveTrain : List String
meetSteveTrain =
    [ """
Steve takes this train every day to get to work.  He gets off at the Metro Center stop.

He works at a top financial institution downtown.  Jason, his boss, works him hard.  He keeps promising Steve a promotion if he does a good job.

Steve does his best to please Jason, working over-time and even giving up some weekends.

It's been 3 years now, and Steve still hasn't gotten a promotion.  He keeps telling himself he just has to work harder.

His stop is coming up.
"""
    , """
Steve glares at young teenager seated across from him, scratching his name into the Plexiglas window.

Some people think that Steve is an push-over.  But that's not exactly the case.  He is just a guy who believes in the rules.  He knows the rules were created to keep everything running smoothly.  Steve believes that if he follows the rules, he'll eventually win.

He's seen others pass him up by cheating, but he knows they'll get their due.  If everyone stopped following the rules, the world would be chaos.
"""
    , """
As the train hurtles through the subterranean tunnels Steve replays his conversation with Jason the day before.

Jason told him that some important investors are arriving on Friday, and he wants Steve to give them a presentation.  Of course, Steve said yes.  The investors are important people.  It will be a great opportunity to impress Jason.  He might even get that promotion.  It won't be easy though, under normal circumstances he would ask for a week to prepare.  Jason only gave him two days.
"""
    , """
Steve's mind races over his progress.  He got a lot done, but there's so much more to do before tomorrow.  He doesn't even notice the ticket inspector coming down the train.

"Tickets please."

Maybe Jason will let him leave early to finish it up.  But if he asks, Jason might think --

"Tickets!"

The inspector startles Steve from his thoughts.  Steve shows his commuter pass for the Red Line and the inspector grumbles and moves on.
"""
    , """
Steve plops into his seat.  The lack of sleep is catching up to him.  He is so tired.

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
