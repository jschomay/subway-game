module Narrative exposing (Narrative(..), askAboutDelay, delayAhead, endOfDemo, exitClosedBriefcaseStolen, inOrder, inquireHowToGetBack, intro, jumpToLostBriefcase, missedStop, missedStopAgain, redirectedToLostAndFound, reportStolenBriefcase, ridingTheTrain, tryCellPhone, update)

import List.Zipper as Zipper exposing (Zipper)


type Narrative
    = InOrder (Zipper String)


inOrder : List String -> Narrative
inOrder l =
    InOrder <| Zipper.withDefault "..." <| Zipper.fromList l


update : Narrative -> ( String, Narrative )
update narrative =
    case narrative of
        InOrder zipper ->
            ( Zipper.current zipper, InOrder (Zipper.next zipper |> Maybe.withDefault zipper) )


jumpToLostBriefcase : Narrative
jumpToLostBriefcase =
    inOrder [ """
  After missing your stop, you go back, only to find the exits sealed.  During the confusion, someone steals your briefcase!  You notice the thief disappear down the tunnel for the Red line trains towards West Mulberry...
  """ ]


inquireHowToGetBack : Narrative
inquireHowToGetBack =
    inOrder
        [ """
    The security guard got off the train with you, and is the only other person at this station.
    
    You have to get back to your stop as soon as possible, so you ask him, "Hey, when's the next train that stops at Metro Center?"

    He answers, "No clue kid, I don't run the trains.  Check the map.."
  """
        , """
    You look in his direction again, but you know better than to bother him.  He meets your gaze, then walks to the far end of the platform.

    You should be on your way too, you need to get back to your stop.
  """
        ]


missedStopAgain : Narrative
missedStopAgain =
    inOrder [ """
    Wait, what are you doing?  You need to get off at the Metro Center station to get to work.  What is wrong with you today!?
    """ ]


missedStop : Narrative
missedStop =
    inOrder
        [ """
    You can't believe you missed your stop.  You've never done that before, and today of all days.

    There's no time to lament, you need to get back to the Metro Center station as fast as possible.  It looks like you can just take the train back in the other direction.  If you ever get lost, you have a map with you (press 'm').
  """
        , "If you hurry up and get on the train, you still probably have time to get back without your boss even noticing."
        ]


intro : Narrative
intro =
    inOrder [ """
Friday, 6:15AM

It's been a hell of a week.

You've been pulling all-nighters to finish up an important presentation your boss dumped on you lap four days ago.  He's passed you up for promotion three times in a row now, but if this presentation goes well, this could be it.

If only you weren't so damned tired.  You need to be fresh to give the presentation at 9:00.  You work near the Metro Center subway station.  That's in 4 stops.  Enough time for a power nap.

You'll just close your eyes for a few moments...

...

You awake to a security guard shaking your arm.  "Wake up buddy, we're pulling in to the last station.  It's the end of the line, you've got to get off."

Oh shit.  You missed your stop.  It's 6:39.  You have to get back to the Metro Center station.
  """ ]


delayAhead : Narrative
delayAhead =
    inOrder
        [ """
  You're wide awake now.  There's still time to get to work and do one more run through of the presentation.  This is what you've been working so hard for.  You deserve a promotion.  This time, you'll get it.

  Your thoughts are interrupted by a crackle over the loudspeaker.  You realize the conductor is making an announcement, but it's so garbled that you only catch part of it.  Something about a delay... That doesn't sound good.  Some kind of problem at one of the stations... You just hope it won't effect your plans.
  """
        , """
  As the train pulls in to the station, you can see that the exists are still closed.
  """
        ]


ridingTheTrain : Narrative
ridingTheTrain =
    inOrder
        [ """
    The train hurtles through the dark tunnel towards the next stop.
    """
        , """
    You stare at the floor, avoiding the gaze of the other passengers, waiting for your next stop.
    """
        ]


tryCellPhone : Narrative
tryCellPhone =
    inOrder [ """
  You think about giving your boss a call to let him know you'll be late.  There's just one problem - you don't get any service down here.
  """ ]


exitClosedBriefcaseStolen : Narrative
exitClosedBriefcaseStolen =
    inOrder [ """
    There's a large crowd gathering around.  Some people seem angry, others are asking questions.  You turn to a young woman with glasses.

    "Hey, what's going on?"
    "The exits are locked!  We can't get out."
    "Why would they lock the exits?  That doesn't make sense, they wouldn't do that during the weekday morning rush hour."

    She throws her hands in the air walks off.  You try to get more information from a teenage in a dirty hoody.
    "There's some problem, but they won't say what, something about security."

    This is no good.  You have to get to work.  Maybe you could take the train to the next stop and walk--

    Someone knocks into you, hard.  You feel a tug at your arm, and realize someone has grabbed your briefcase and ran.

    "Stop!  Thief!  Someone... help!"

    The thief disappears into a door marked "Employees only."  It's gone.  Your presentation was in there.  You need to get it back.
  """ ]


askAboutDelay : Narrative
askAboutDelay =
    inOrder [ """
    "Excuse me, can you tell me what's going on here?"

    The officers are preoccupied trying to keep everyone calm.  "Nothing to worry about, please try a different station."
    "But this is my stop."
    "We're asking people to use a different station."

    They brush past you.  This is ridiculous.  Maybe one of the people in the crowd knows what's going on.
  """ ]


reportStolenBriefcase : Narrative
reportStolenBriefcase =
    inOrder
        [ """
    "Hey, didn't you see that?  That guy stole my briefcase!  He went in there, stop him."

    The officers try to brush you off, "We need everyone to clear this station, please go to another station."
    "Wait a minute!  That guy stole my suitcase.  Aren't you going to help me?"
    "There's nothing we can do.  You can report it at the police station in the Federal Triangle station.  Maybe they can help you.  Now we need you to leave."

    You can't believe it.  This is the worst thing that could happen.  You always do everything right. Why can't something just work out for you for once.

    You can't give the presentation without getting it back first.  There's not much else you can do than try to report it.  You better head towards Federal Triangle.
  """
        , """
    "You need to clear this station.  That way please."
    "Where did you say the police office was?"
    "Federal Triangle.  Good bye."

    Those are the most unhelpful security officers you've ever seen.
 """
        ]


redirectedToLostAndFound : Narrative
redirectedToLostAndFound =
    inOrder [ """
    You found the police office.  But the door is closed, no one is in there.  You see a note on the door:

    "CLOSED.  We are busy attending to other issues at the moment.  Please come back later.  You can also try the Lost and Found at the MacArthur's Park station."

    Well that's not very helpful.  You don't even know where the MacArthur's Park station is.  It's not on your map.  Oh, there it is.  It's on the Yellow line (Yellow Line added to your map!  Press 'm' to see it).

    There's just one problem.  You don't have a ticket to ride on the Yellow line.
  """ ]


endOfDemo : Narrative
endOfDemo =
    inOrder [ """
    This is the end of the demo.  Thank you for playing!

    The Green Line has been unlocked for you (press "m" to see it), so feel free to have fun riding the rails.
  """ ]
