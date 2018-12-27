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
                    , conditions = []
                    , changes = []
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
                    { trigger = Match "securityGuard" []
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
                        [ IncStat "player" "mainPlot" 1
                        , SetLink "briefcase" "location" "thief"
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

You've been pulling all-nighters to finish up an important presentation your boss dumped on you lap four days ago.  He's passed you up for promotion three times in a row now, but if this presentation goes well, this could be it.

If only you weren't so damned tired.  You need to be fresh to give the presentation at 9:00.  You work near the Metro Center subway station.  That's in 4 stops.  Enough time for a power nap.

You'll just close your eyes for a few moments...

...

You awake to a security guard shaking your arm.  "Wake up buddy, we're pulling in to the last station.  It's the end of the line, you've got to get off."

Oh shit.  You missed your stop.  It's 6:39.  You have to get back to the Metro Center station.
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

    There's no time to lament, you need to get back to the Metro Center station as fast as possible.  It looks like you can just take the train back in the other direction.  If you ever get lost, you have a map with you (press 'm').
  """
        , "If you hurry up and get on the train, you still probably have time to get back without your boss even noticing."
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
    The security guard got off the train with you, and is the only other person at this station.
    
    You have to get back to your stop as soon as possible, so you ask him, "Hey, when's the next train that stops at Metro Center?"

    He answers, "No clue kid, I don't run the trains.  Check the map.."
  """
        , """
    You look in his direction again, but you know better than to bother him.  He meets your gaze, then walks to the far end of the platform.

    You should be on your way too, you need to get back to your stop.
  """
        ]


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
