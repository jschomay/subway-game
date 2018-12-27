module Rules.General exposing (rules)

import City exposing (Station(..))
import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    []
        ++ [ rule "endOfDemo"
                { trigger = MatchAny [ HasTag "station" ]
                , conditions = [ plot "mainPlot" scenes.wildGooseChase ]
                , changes =
                    [ IncStat "player" "mainPlot" 1
                    , IncStat "player" "mapLevel" 1
                    ]
                , narrative = endOfDemo
                }
           , rule "ridingTheTrain"
                { trigger = MatchAny [ HasTag "station" ]
                , conditions = []
                , changes = []
                , narrative = ridingTheTrain
                }
           ]
        ++ -- cellPHone
           [ rule "tryCellPhone"
                { trigger = Match "cellPHone" []
                , conditions = []
                , changes = []
                , narrative = tryCellPhone
                }
           ]


jumpToLostBriefcase : Narrative
jumpToLostBriefcase =
    inOrder [ """
  After missing your stop, you go back, only to find the exits sealed.  During the confusion, someone steals your briefcase!  You notice the thief disappear down the tunnel for the Red line trains towards West Mulberry...
  """ ]


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


endOfDemo : Narrative
endOfDemo =
    inOrder [ """
    This is the end of the demo.  Thank you for playing!

    The Green Line has been unlocked for you (press "m" to see it), so feel free to have fun riding the rails.
  """ ]
