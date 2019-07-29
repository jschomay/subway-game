module Rules.Intro exposing (rules)

import City exposing (Station(..))
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
            ++ [ rule "intro, deadline, miss stop"
                    { trigger = Match "player" []
                    , conditions = []
                    , changes = []
                    , narrative = intro
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = Match "mapPoster" []
                    , conditions = [ Match "map" [ Not <| HasLink "location" <| Match "player" [] ] ]
                    , changes = [ Update "map" [ SetLink "location" "player" ] ]
                    , narrative = missedStop
                    }
               ]
            ++ -- stations
               [ rule "delayAhead"
                    { trigger = Match (station MetroCenter) []
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
                        , Update "thief" [ SetLink "location" (station WestMulberry) ]
                        , Update (station ChurchStreet) [ AddTag "possibleThiefLocation" ]
                        , Update (station EastMulberry) [ AddTag "possibleThiefLocation" ]
                        , Update (station WestMulberry) [ AddTag "possibleThiefLocation" ]
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


intro : Narrative
intro =
    inOrder [ """
Friday, 6:15AM

It's been a hell of a week.
---
You've been pulling all-nighters to finish up an important presentation your boss dumped on you lap four days ago.  He's passed you up for promotion three times in a row now, but if this presentation goes well, this could be it.

If only you weren't so damned tired.  You need to be fresh to give the presentation at 9:00.  You work near the Metro Center subway station.  That's in 4 stops.  Enough time for a power nap.

You'll just close your eyes for a few moments...
---
You awake to a security guard shaking your arm.  "Wake up buddy, we're pulling in to the last station.  It's the end of the line, you've got to get off."

Oh shit.  You missed your stop.  It's 6:39.  You have to get back to the Metro Center station.

(Tip: You can press the space bar to continue instead of clicking.)
 """ ]


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

You pick up a subway map and try to figure out how to get back to the Metro Center.

(It is now in your inventory and you can view it at any time by clicking on it or pressing 'M')
"""
        ]


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


inquireHowToGetBack : Narrative
inquireHowToGetBack =
    inOrder
        [ """
You see a maintenance man at the end of the platform, working on some broken panel.  He looks very focused, but he is the only other person on this platform.

You have to get back to your stop as soon as possible, so you ask him, "Excuse me?  Do you know the quickest way to get back to Metro Center?"

He looks up from his work, obviously annoyed.  "No clue, I don't run the trains.  Check the map."  He goes back to his work, totally ignoring you.
"""
        , """
You look in his direction again, but you know better than to bother him.  You should be on your way too, you need to get back to your stop.
  """
        ]


exitClosedBriefcaseStolen : Narrative
exitClosedBriefcaseStolen =
    inOrder [ """
From the angry shouting, you gather that station's exits are locked.  But that doesn't make sense, why would they lock the exits during the morning commute?

You feel a shot of panic as you realize you can't get out.  And then you feel a tug at your arm and look down, and see someone run off with your briefcase!

Your presentation is in that briefcase.  You need it!  "Stop, thief!"

The thief runs down the tunnel for the Red line heading towards West Mulberry.  The security officers don't seem to notice a crime has occurred.

You need that briefcase back.
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
