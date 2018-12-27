module Rules.LostBriefcase exposing (rules)

import City exposing (Station(..))
import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    rulesForScene scenes.lostBriefcase <|
        []
            ++ -- securityOfficers
               [ rule "reportStolenBriefcase"
                    { trigger = Match "securityOfficers" []
                    , conditions = []
                    , changes = []
                    , narrative = reportStolenBriefcase
                    }
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { trigger = Match "policeOffice" []
                    , conditions = []
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , IncStat "player" "mapLevel" 1
                        ]
                    , narrative = redirectedToLostAndFound
                    }
               ]


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
