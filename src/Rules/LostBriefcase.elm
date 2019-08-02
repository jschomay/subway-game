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
            ------- ask for help route
            ++ -- securityOfficers
               [ rule "reportStolenBriefcase"
                    { trigger = Match "securityOfficers" []
                    , conditions = [ plotLine "chaseThief" EQ 0, plotLine "lostAndFound" LT 2 ]
                    , changes =
                        [ Update "player" [ SetStat "lostAndFound" 1 ]
                        ]
                    , narrative = reportStolenBriefcase
                    }
               ]
            ++ [ rule "travelToPoliceOffice"
                    { trigger = Match (station FederalTriangle) []
                    , conditions = [ plotLine "lostAndFound" EQ 1 ]
                    , changes = []
                    , narrative = travelToPoliceOffice
                    }
               ]
            ++ -- policeOffice
               [ rule "findClosedPoliceOffice"
                    { trigger = Match "policeOffice" []
                    , conditions = []
                    , changes = [ Update "player" [ SetStat "lostAndFound" 2 ] ]
                    , narrative = findClosedPoliceOffice
                    }
               ]
            ++ [ rule "tryToBuyTickets"
                    { trigger = Match "ticketMachine" []
                    , conditions = [ Match "briefcase" [ Not <| HasLink "location" <| Match "player" [] ] ]
                    , changes = []
                    , narrative = tryToBuyTickets
                    }
               ]
            ++ [ rule "jumpYellowLineTurnstile"
                    { trigger = Match "yellowLine" []
                    , conditions = [ plotLine "lostAndFound" EQ 2 ]
                    , changes = [ Update "player" [ SetLink "line" "yellowLine" ] ]
                    , narrative = jumpYellowLineTurnstile
                    }
               ]
            ++ [ rule "caughtOnYellowLine"
                    { trigger = MatchAny [ HasTag "station" ]
                    , conditions = [ plotLine "lostAndFound" EQ 2, Match "player" [ HasLink "line" <| Match "yellowLine" [] ] ]
                    , changes =
                        [ Update "player"
                            [ IncStat "ruleBreaker" 1
                            , IncStat "mainPlot" 1
                            , IncStat "lostAndFound" 1
                            , AddTag "caught"
                            ]
                        ]
                    , narrative = caughtOnYellowLine
                    }
               ]
            -------- follow thief route
            ++ [ rule "chaseAfterThief"
                    { trigger = MatchAny [ HasTag "station", HasTag "possibleThiefLocation" ]
                    , conditions = [ plotLine "lostAndFound" EQ 0 ]
                    , changes =
                        [ Update "player" [ SetStat "chaseThief" 1, IncStat "bravery" 1 ]
                        , Update "$" [ RemoveTag "possibleThiefLocation" ]
                        ]
                    , narrative = chaseAfterThief
                    }
               , rule "thiefHasEscaped"
                    { trigger = MatchAny [ HasTag "station", HasTag "possibleThiefLocation" ]
                    , conditions = [ plotLine "lostAndFound" GT 0 ]
                    , changes =
                        [ UpdateAll [ HasTag "possibleThiefLocation" ] [ RemoveTag "possibleThiefLocation" ]
                        , Update "player" [ SetStat "chaseThief" 0 ]
                        ]
                    , narrative = thiefHasEscaped
                    }
               , rule "examinePaperScrap"
                    { trigger = Match "paperScrap" [ Not <| HasLink "location" <| Match "offscreen" [] ]
                    , conditions = [ plotLine "chaseThief" EQ 1, plotLine "lostAndFound" EQ 0 ]
                    , changes = [ Update "paperScrap" [ SetLink "location" "offscreen" ] ]
                    , narrative = examinePaperScrap
                    }
               , rule "askAboutThiefFail"
                    { trigger = Match "commuter1" []
                    , conditions = [ plotLine "chaseThief" EQ 1, plotLine "lostAndFound" EQ 0 ]
                    , changes = []
                    , narrative = askAboutThiefFail
                    }
               , rule "askAboutThiefSucceed"
                    { trigger = Match "commuter2" [ HasLink "location" <| Match (station WestMulberry) [] ]
                    , conditions = [ plotLine "chaseThief" EQ 1, plotLine "lostAndFound" EQ 0 ]
                    , changes =
                        [ Update "player" [ SetStat "chaseThief" 2 ]
                        , Update "commuter2" [ SetLink "location" "offscreen" ]
                        , UpdateAll [ HasTag "possibleThiefLocation" ] [ RemoveTag "possibleThiefLocation" ]
                        ]
                    , narrative = askAboutThiefSucceed
                    }
               , rule "examineMaintenanceDoor"
                    { trigger = Match "maintenanceDoor" []
                    , conditions = [ plotLine "chaseThief" EQ 2 ]
                    , changes = [ Update "player" [ SetStat "chaseThief" 3 ] ]
                    , narrative = examineMaintenanceDoor
                    }
               , rule "reflectOnMaintenanceDoor"
                    { trigger = MatchAny [ HasTag "station" ]
                    , conditions =
                        [ plotLine "chaseThief" EQ 3
                        , Match "player" [ HasStat "downTheRabbitHole" EQ 0 ]
                        ]
                    , changes = [ Update "player" [ SetStat "downTheRabbitHole" 1 ] ]
                    , narrative = reflectOnMaintenanceDoor
                    }
               , rule "stealMaintenanceKeyCard"
                    { trigger = Match "maintenanceMan" []
                    , conditions = [ plotLine "chaseThief" EQ 3 ]
                    , changes =
                        [ Update "player" [ IncStat "ruleBreaker" 2, SetStat "chaseThief" 4 ]
                        , Update "keyCard" [ SetLink "location" "player" ]
                        ]
                    , narrative = stealMaintenanceKeyCard
                    }
               , rule "tauntMaintenanceMan"
                    { trigger = Match "maintenanceMan" []
                    , conditions = [ Match "keyCard" [ HasLink "location" <| Match "player" [] ] ]
                    , changes = []
                    , narrative = tauntMaintenanceMan
                    }
               , rule "reflectOnStolenKeyCard"
                    { trigger = MatchAny [ HasTag "station" ]
                    , conditions = [ Match "keyCard" [ HasLink "location" <| Match "player" [] ] ]
                    , changes = []
                    , narrative = reflectOnStolenKeyCard
                    }
               , rule "openMaintenanceDoor"
                    { trigger = Match "maintenanceDoor" []
                    , conditions = [ Match "keyCard" [ HasLink "location" <| Match "player" [] ] ]
                    , changes =
                        [ Update "keyCard" [ SetLink "location" "offscreen" ]
                        , Update "player"
                            [ AddTag "caught"
                            , IncStat "mainPlot" 1
                            , IncStat "chaseThief" 1
                            ]
                        ]
                    , narrative = openMaintenanceDoor
                    }
               ]


reportStolenBriefcase : Narrative
reportStolenBriefcase =
    [ """
"That guy stole my briefcase!  Help!"

The officers barely take notice.  "We've got our own problems right now."

"But...  He stole my briefcase, aren't you going to do something?"

"You can report it at the police station in the Federal Triangle station if you want.  Now we need everyone to clear this station."
"""
    , """
"Where did you say the police office was?"
"Federal Triangle.  Now get moving."

Those are the most unhelpful security officers you've ever seen.
"""
    ]


travelToPoliceOffice =
    [ """
You can't believe it.  This is the worst thing that could happen.  You always do everything right. Why can't something just work out for you for once.  If you don't get your presentation back you'll be ruined.

Hopefully the police station that the guards told you about can help you.
"""
    , """
You suppose you could try the police station again.
"""
    ]


findClosedPoliceOffice : Narrative
findClosedPoliceOffice =
    [ """
You find a police office.  But the door is closed, no one is in there.  You see a note on the door:

"CLOSED.  We are busy attending to other issues at the moment.  Please come back later.  You can also try the Lost and Found at the MacArthur's Park station."

Well that's not very helpful.  You don't even know where the MacArthur's Park station is.  It's not on your map.  Oh, there it is.  It's on the Yellow line.

The lost and found seems like a long shot.  But you don't know what else to do.

There's just one problem.  You don't have a ticket to ride on the Yellow line.
"""
    , """
They are still closed.  You could try the Lost and Found at MacArthur's Park station.
"""
    ]


tryToBuyTickets =
    [ """
You could buy a ticket here... except your wallet is in your briefcase!
        """
    ]


jumpYellowLineTurnstile =
    [ """
You consider jumping the turnstile.  You don't want to, but this is a special
circumstance.  You need to get your briefcase back, so maybe just this once.

You take a look around and when it looks safe you make your move.

No one seems to have noticed.  In fact, it was pretty easy.
        """
    ]


caughtOnYellowLine =
    [ """
You've never ridden without a ticket before.  You don't like it.  You're sure you'll be caught.

You count the stops to your destination, sinking low in your chair each time.  People get on and off.  You're getting close.

You feel someone staring at you.  You look over.  He grins.  Ticket inspector!  You're caught!.

You try to plead your case, but the inspector escorts you to the place where they take all the people who break the rules.

The Central Guard Station.
"""
    ]


chaseAfterThief =
    [ """
You can't believe you ran after the thief.  That's not like you.  But you do need to get the presentation back.

And what will you do if you find him?  This could be dangerous.  Maybe you should have thought about that before jumping on this train.  Maybe you won't even find him, he could have gotten off at any of these stations. 
"""
    , """
This is crazy.  You're actually hunting him down.  You're out of your mind.
"""
    , """
Did you actually think you would find him?  He had a head start, he could be anywhere by now.  Your briefcase could be anywhere by now.

No, you have to keep trying.  Maybe this he'll be at this station.
"""
    ]


thiefHasEscaped =
    [ """
You saw the thief head in this direction.  Maybe if you went after him right away you could have caught him, but by now he would have escaped.
""" ]


examinePaperScrap =
    [ """
Maybe the thief was here and it fell from your suitcase.

But on closer inspection it is just a piece of trash.  You throw it in the rubbish bin.
"""
    ]


askAboutThiefFail =
    [ """
"Excuse me - did you happen to see a man with a briefcase get off at this stop a few minutes ago?  No?  Are you sure?  OK, fine, thanks anyway."
        """
    , """
You don't want to bother him any more.
"""
    ]


askAboutThiefSucceed =
    [ """
"Hi, did a man with a briefcase get off at this stop a few minutes ago?  Yes!?  Where did he go?"

The young woman points at the maintenance door, then boards the train.

This is it, you've found him now!  You can just go right in and get your briefcase back, and go to work and give your presentation and get your promotion and all will be well.  All you have to do is confront him.  And that, is why your hands are shaking.
"""
    ]


examineMaintenanceDoor =
    [ """
The door is locked.  You notice a key card reader near the door.  How did the thief get in?  He must have a key card.  If you had a maintenance key card you could get in too.  But where would you find one of those?
        """
    ]


reflectOnMaintenanceDoor =
    [ """
You can't help thinking about the locked maintenance door.  Normally, you would leave it well enough alone.  But now...

An striking sight stirs you from your thoughts.  Just before pulling out of the station, you spotted a woman in a sunny yellow dress standing on the platform.   It might just be your imagination, but it looked like she was smiling at you.  The contrast of her bright dress against the dark, artificial underground tunnels sticks in your mind as you move closer to your next stop.
        """
    ]


openMaintenanceDoor =
    [ """
You make sure no one is around, then you slide the key card through the reader.  The door clicks open.

This is it.  One more step and you are officially trespassing.  You could turn back now, and forget the whole thing.

But what would you tell your boss?  You've come this far.  You must press forward.

You wind down a long, dirty hall, wondering where the thief could have gone, and once again, you wonder what will you do if you catch him?

And then you hear footsteps behind you.  There's no where to go.  A flashlight shines in your eyes and you realize a security guard has seen you.  You try to plead your case, but he escorts you to the place where they take all the people who break the rules.

The Central Guard Station.
        """
    ]


stealMaintenanceKeyCard =
    [ """
The maintenance man is still busy working at the end of the platform.  He doesn't even seem to know you are there.  You can see his bag next to him.  And in the bag, you see his key card.

This is your chance.  You tip toe over there and slip your hand into his bag.  You've never ever done anything like this before.  But it's not really stealing, you are just borrowing it.  You'll bring it back as soon as you get your briefcase back, you promise yourself that much.

You've got it.  The poor guy still has his head buried under the machinery he is working on.  Best to get away from here and fast.
"""
    ]


tauntMaintenanceMan =
    [ """
You didn't get caught the first time, no point arousing suspicion.
"""
    ]


reflectOnStolenKeyCard =
    [ """
What have you done?  You've stolen.  You've committed robbery.  You illegally possess private property that isn't yours.  You'll never get away with this.

You'll bring it back.  No one will be hurt.  The hard part is over.  Even still, you feel sick in your stomach.
        """
    ]
