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
        -- ++ [ rule "pickingThingsUp"
        --         { trigger = MatchAny [ HasTag "item", Not <| HasTag "fixed", Not <| HasLink "location" (Match "player" []) ]
        --         , conditions = []
        --         , changes = [ Update "$" [ SetLink "location" "player" ] ]
        --         , narrative =  [ "You take it." ]
        --         }
        ++ [ rule "ridingTheTrain"
                { trigger = MatchAny [ HasTag "station" ]
                , conditions = []
                , changes = []
                , narrative = ridingTheTrain
                }
           , rule "goToLinePlatform"
                { trigger = MatchAny [ HasTag "line" ]
                , conditions =
                    [ MatchAny
                        [ HasLink "validOn" (Match "$" [])
                        , HasLink "location" (Match "player" [])
                        ]
                    ]
                , changes = [ Update "player" [ SetLink "line" "$" ] ]
                , narrative = []
                }
           , rule "jumpTurnstileFail"
                { trigger = MatchAny [ HasTag "line" ]
                , conditions = []
                , changes = []
                , narrative = jumpTurnstileFail
                }
           , rule "getMap"
                { trigger = Match "mapPoster" []
                , conditions = [ Match "map" [ Not <| HasLink "location" <| Match "player" [] ] ]
                , changes = [ Update "map" [ SetLink "location" "player" ] ]
                , narrative = getMap
                }
           , rule "checkMap"
                { trigger = Match "mapPoster" []
                , conditions = []
                , changes = []
                , narrative = []
                }
           ]


jumpToLostBriefcase : Narrative
jumpToLostBriefcase =
    [ """
After missing your stop, you go back, only to find the exits sealed.  During the confusion, someone steals your briefcase!  You notice the thief disappear down the tunnel for the Red line trains towards West Mulberry...
  """ ]


ridingTheTrain : Narrative
ridingTheTrain =
    [ """
The train hurtles through the dark tunnel towards the next stop.
"""
    , """
You stare at the floor, avoiding the gaze of the other passengers, waiting for your next stop.
    """
    ]


jumpTurnstileFail =
    [ "You've never jumped a turnstile in your life, and you're not about to start now. "
    , "Better to stick to the lines you have passes for."
    , "You're too afraid you'll get caught."
    ]


getMap : Narrative
getMap =
    [ """
You pick up a subway map.

(It is now in your inventory and you can view it at any time by clicking on it or pressing 'M')
"""
    ]
