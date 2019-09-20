module Rules.Intro exposing (rules)

import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    rulesForScene scenes.intro <|
        []
            ++ [ rule "intro"
                    { trigger = Match "player" []
                    , conditions = []
                    , changes = [ Update "cellPhone" [ AddTag "ringing" ] ]
                    , narrative = intro
                    }
               ]
            -- map
            ++ [ rule "wrong phone"
                    { trigger = Match "deskPhone" []
                    , conditions = [ Match "cellPhone" [ HasTag "ringing" ] ]
                    , changes = []
                    , narrative = """
You pick up your desk phone.  "Hello?"

Silence on the other line.

The ringing continues.  Wrong phone!"""
                    }
               ]
            ++ [ rule "anything other than the phone"
                    { trigger = MatchAny []
                    , conditions = [ Match "cellPhone" [ HasTag "ringing" ] ]
                    , changes = []
                    , narrative = "The ringing is giving you a headache, you have to stop it first."
                    }
               ]
            ++ [ rule "answer phone"
                    { trigger = Match "cellPhone" [ HasTag "ringing" ]
                    , conditions = []
                    , changes = [ Update "cellPhone" [ RemoveTag "ringing" ] ]
                    , narrative = whereAreYou
                    }
               ]
            ++ [ rule "pack briefcase"
                    { trigger = Match "briefcase" [ Not <| HasLink "location" (Match "player" []) ]
                    , conditions = [ Match "cellPhone" [ Not <| HasTag "ringing" ] ]
                    , changes = [ Update "$" [ SetLink "location" "player" ] ]
                    , narrative = "You grab your trusty briefcase.  Its contents are a jumble now, but you'll organize it later when then presentation is over."
                    }
               ]
            ++ [ rule "pack cell phone"
                    { trigger = Match "cellPhone" [ Not <| HasLink "location" (Match "player" []) ]
                    , conditions = [ Match "cellPhone" [ Not <| HasTag "ringing" ] ]
                    , changes = [ Update "$" [ SetLink "location" "player" ] ]
                    , narrative = """Luckily you remembered to charge it and the battery is at full.

There's one new email that came in -- a job offer from a very persistent recruiter.  You don't have time to even look at it right now, so you put it in your coat pocket.

Besides, you've built up five years of loyalty at your current job, and you wouldn't want to lose that.  Even if your boss is a jerk."""
                    }
               ]
            ++ [ rule "pack presentation"
                    { trigger = Match "presentation" [ Not <| HasLink "location" (Match "briefcase" []) ]
                    , conditions = [ Match "cellPhone" [ Not <| HasTag "ringing" ] ]
                    , changes = [ Update "$" [ SetLink "location" "briefcase" ] ]
                    , narrative = """
Your presentation is scattered all over your desk.  It's covered in scribbles and sticky notes.  Some pages are wrinkled and a little smudged from when you fell asleep on them. 

You put them back in order and carefully stack them, then slip them into your briefcase. Hopefully it's all worth it.
            """
                    }
               ]
            ++ [ rule "pack metro pass"
                    { trigger = Match "redLinePass" [ Not <| HasLink "location" (Match "player" []) ]
                    , conditions = [ Match "cellPhone" [ Not <| HasTag "ringing" ] ]
                    , changes = [ Update "$" [ SetLink "location" "player" ] ]
                    , narrative = "You ride the metro to work every day.  You had to buy the pass yourself, but it's cheaper than paying each way.  You throw it in your pocket."
                    }
               ]
            ++ [ rule "fall asleep"
                    { trigger = Match "TwinBrooks" []
                    , conditions = [ Match "player" [ Not <| HasTag "late" ] ]
                    , changes = [ Update "player" [ AddTag "late" ] ]
                    , narrative = fallAsleep
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = Match "mapPoster" []
                    , conditions = [ Match "map" [ Not <| HasLink "location" <| Match "player" [] ] ]
                    , changes = [ Update "map" [ SetLink "location" "player" ] ]
                    , narrative = getBack
                    }
               ]
            ++ -- stations
               [ rule "delayAhead"
                    { trigger = Match "MetroCenter" []
                    , conditions = []
                    , changes = []
                    , narrative = delayAhead
                    }
               , rule "missedStopAgain"
                    { trigger = MatchAny [ HasTag "station", Not (HasTag "stevesWork") ]
                    , conditions = []
                    , changes = []
                    , narrative = missedStopAgain
                    }
               ]
            ++ [ rule "inquireHowToGetBack"
                    { trigger = Match "maintenanceMan" []
                    , conditions = []
                    , changes = []
                    , narrative = inquireHowToGetBack
                    }
               ]
            ++ -- largeCrowd
               [ rule "exitClosedBriefcaseStolen"
                    { trigger = Match "largeCrowd" []
                    , conditions = []
                    , changes =
                        [ Update "player" [ IncStat "mainPlot" 1 ]
                        , Update "briefcase" [ SetLink "location" "thief" ]
                        , Update "thief" [ SetLink "location" "WestMulberry" ]
                        , Update "ChurchStreet" [ AddTag "possibleThiefLocation" ]
                        , Update "EastMulberry" [ AddTag "possibleThiefLocation" ]
                        , Update "WestMulberry" [ AddTag "possibleThiefLocation" ]
                        ]
                    , narrative = exitClosedBriefcaseStolen
                    }
               ]
            ++ -- securityOfficers
               [ rule "askAboutDelay"
                    { trigger = Match "securityOfficers" []
                    , conditions = []
                    , changes = []
                    , narrative = askAboutDelay
                    }
               ]


intro =
    """
6:23AM.  Friday.  Your apartment.

You are sleeping at your desk, snoring and drooling, face down in a pile of papers and other work littered across the desk.

A phone rings, startling you awake.
"""


whereAreYou =
    """
"Where the hell are you?"

It's your boss.

The only thought in your mind is, "It's six twenty-five in the morning."
---
"This presentation is important, I don't want to screw it up.  I want to run through it before the clients arrive, so get your ass down here."

The presentation.  You've been killing yourself all week trying to get it done. But you're sure the hard work you put in will finally land you the promotion you've been promised for over a year now.
---
He seems to notice your pause.  "Steve... it's done, right?"

"Of course," you blurt out.  "I'm on my way."

You hang up and get ready as quick as you can.

(Tip: You can press "space key" to continue)
"""


fallAsleep =
    """
You board the red line train and find a seat.  You have to get off at the "Metro Center Station" stop.  You have about twenty minutes before you'll get there.
---
The train rushes through the dark underground tunnels.  Your boss is probably right, preparing before the clients get in is a good idea.  You're just so damned tired!
---
If all goes well, you should get the promotion you've been promised for so long.

You yawn, and decide to go over the presentation in your head.
---
Your eyes start to droop, but you force them open and focus on how you are going to present.  Hopefully you can follow all of your scribbles.

You're so tired...
---
...
---
Someone is shaking your arm.

"Hey, buddy, wake up.  We're pulling in to the last stop, everyone has to get up."
---
Oh shit!!

You fell asleep!
---
You missed your stop!
---
You're going to be late!
---
Ok, don't panic.  There's still plenty of time.  You just have to get back to Metro Center Station as quick as you can.
    """


missedStopAgain =
    """
Wait, what are you doing?  You need to get off at the Metro Center station to get to work.  What is wrong with you today!?
    """


getBack =
    """
You pick up a subway map and try to figure out how to get back to the Metro Center.

(It is now in your inventory and you can view it at any time by clicking on it or pressing 'M')
"""


delayAhead =
    """ {
You're back on track now.  Hopefully your boss won't even notice.

Your thoughts are interrupted by a crackle over the loudspeaker.  You realize the conductor is making an announcement, but it's so garbled that you only catch part of it.
---
Something about a delay... That doesn't sound good.  Some kind of problem at one of the stations... You just hope it won't make you any later.
|
As the train pulls in to the station, you can see that the exists are still closed.
} """


inquireHowToGetBack =
    """{
You see a maintenance man at the end of the platform, working on some broken panel.  He looks very focused, but he is the only other person on this platform.

You have to get back to your stop as soon as possible, so you ask him, "Excuse me?  Do you know the quickest way to get back to Metro Center?"

He looks up from his work, obviously annoyed.  "No clue, I don't run the trains.  Check the map."  He goes back to his work, totally ignoring you.
|
You look in his direction again, but you know better than to bother him.  You should be on your way too, you need to get back to your stop.
}  """


exitClosedBriefcaseStolen =
    """
From the angry shouting, you gather that station's exits are locked.  But that doesn't make sense, why would they lock the exits during the morning commute?

You feel a shot of panic as you realize you can't get out.  And then you feel a tug at your arm and look down, and see someone run off with your briefcase!

Your presentation is in that briefcase.  You need it!  "Stop, thief!"
---
The thief runs down the tunnel for the Red line heading towards West Mulberry.  The security officers don't seem to notice a crime has occurred.

You need that briefcase back.
  """


askAboutDelay =
    """
"Excuse me, can you tell me what's going on here?"

The officers are preoccupied trying to keep everyone calm.  "Nothing to worry about, please try a different station."
"But this is my stop."
"We're asking people to use a different station."

They brush past you.  This is ridiculous.  Maybe one of the people in the crowd knows what's going on.
  """
