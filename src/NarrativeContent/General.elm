module NarrativeContent.General exposing (content)

import Dict exposing (Dict)
import NarrativeEngine.Syntax.Helpers exposing (ParseErrors)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser


content__________________________________ =
    Dict.insert


content : Dict String String
content =
    Dict.empty
        |> content__________________________________ "BRIEFCASE"
            "My portable office, all my work is in it."
        |> content__________________________________ "notebookInstructions" """
{I have my notebook with me today to keep track of everything.

(Click the notebook icon or press 'n' to toggle the notebook from now on)
|}
"""
        |> content__________________________________ "RED_LINE_PASS"
            "This gets me anywhere on the Red Line, but I really only use it to get to work and back home."
        |> content__________________________________ "ORANGE_LINE_PASS"
            "I got this from the security guard guy.  Now I can ride the Orange Line without getting caught."
        |> content__________________________________ "GRAFFITI_EAST_MULBERRY"
            "That's just vulgar.  Why do people have to mess things up?"
        |> content__________________________________ "COFFEE" """
{PLAYER.day=1?  Carl's Coffee has been fueling me for years. Can't imagine surviving a Monday without it.}
{PLAYER.day=2?  Mmm, that's good coffee.}
{PLAYER.day=3?  I'm going to need a barrel of this if I'm going to get this proposal done by Friday. What is Mr. Harris thinking?  }
{PLAYER.day=4?  It tastes bitter.}
"""
        |> content__________________________________ "SAFETY_WARNING_POSTER" """
"ATTENTION: Pickpockets and thieves operate in this area. Report any suspicious behavior to your nearest Security Guard Station"
{---
That's just great.  I wish people would just follow the rules.
|}
"""
        |> content__________________________________ "jumpTurnstileFail"
            "{?I'm not the type to jump turnstiles.|I don't want to get caught.|Better to stick to the lines I have passes for.}"
        |> content__________________________________ "outOfServiceStations" """
PLEASE NOTICE: Normal service disruption is in effect.

{$.name} Station is temporarily out of service.  Please use alternative options.

Thank you and we apologize for the inconvenience.
"""
        |> content__________________________________ "SOGGY_JACKET" """
{I don't really have time to look at every piece of discarded junk in the subway. My proposal is gone, my life is falling apart.  Maybe I should focus on that.|Gross.}
"""
        |> content__________________________________ "BULLETIN_BOARD" """
{Maybe somebody has posted about my missing briefcase.
---
Nope, nothing.  Darn.|
Still nothing about my briefcase, but if I'm ever in need of a house cleaner or want to join a lame garage band, I know where to look.}
"""
        |> content__________________________________ "trashcan" """
{?I'm not about to rummage through the trash.
|
I've got a weird feeling about this can. Maybe it wouldn't hurt to take a quick look.
---
...
---
Nothing but trash.
|
Waste of time.
|
Wonder who takes out the garbage down here.
|
Just garbage.
|
There's nothing but junk in here. Just as it should be.
|
Nothing but trash in here.
}

---

{*.missing_dog_poster.location=PLAYER?
I'm lugging around these missing dog posters.  I don't want to go hang them all up, maybe I should just [throw them away](throw_away_posters) instead.
}
---
{MASCOT_PAPERS.location=PLAYER?
This resume is a joke.  Even if I deliver it nobody's going to hire this guy.  Maybe I should do him a favor and just [toss it](throw_away_mascot_papers).
}
"""
        |> content__________________________________ "MISSIONARIES" """
{
One of them tries to get my attention.

"You look like you've lost something important."
---
"Uh... yeah. How did you guess?"
---
"You look like all the others, so many people wandering around in this world, looking for themselves.  Well I can help you, I've got this wonderful pamphlet that I'd like to share with you..."
---
"Oh, sorry. I've got to run. My, uh, my train is about to leave."
---
"Just take a pamphlet with you!"
|
I should have known. I fell right into that.
}
"""
        |> content__________________________________ "DRINKING_FOUNTAIN" """
{?
No.
|
Not in a million years.
|
I'll never be thirsty enough to risk drinking from that.
|
I can see a piece of chewed bubble gum stuck to the spout.
}
"""
        |> content__________________________________ "WOMAN_IN_ODD_HAT" """
{She's dressed very finely and has an air about her that seems to scream "High class." Her hat resembles some kind of bird or a very angry fern.
---
"Pardon me, Ma'am. I--"

"I haven't got any change."

"No, I was actually--"

"I haven't a clue of the time either. Please leave me alone."
---
"I just--"

"Leave me be" she snorts as she turns her back to me.

I guess that's that.
|
I'm not going to try to talk to her again.
}
"""
        |> content__________________________________ "SCHOOL_CHILDREN" """
{A few children play some kind of game on one of the benches. One kid stands tall on the bench laughing and jeering while the other children scamper around below, clawing and grabbing at him.
---
An unspoken rule seems to keep them from just climbing on the bench and pushing him off. But after a few attempts, one of the kids manages to grab his arm and tugs hard, bringing the standing boy down on top of him. A scream, a crash, then laughter and the kids are picking themselves up and scurrying towards the bench again, fighting to see who gets to stand on the bench next.
---|}
Children aren't supposed to be down here unsupervised. And that game looks dangerous. Where are their parents?
"""
        |> content__________________________________ "SODA" """
This soda is probably really old and gross.
"""
        |> content__________________________________ "CHANGE" """
I have {CHANGE.format_amount} in change.
"""
        |> content__________________________________ "DOLLAR_BILL" """
A wrinkled dollar bill.
"""
        |> content__________________________________ "MUSICIAN" """
He's playing an old cracked violin with a hat out in front of him for spare change.

He has a sign: "Blind, Homeless Veteran. Anything helps. God Bless."

The music sounds nice, but I wouldn't call that a real job.
{PLAYER.call_boss>0?
---
Then again, he's got quite a lot of [change](musicians_change) in his hat.
|}
"""
        |> content__________________________________ "BROKEN_PAYPHONE" """
{Now that everyone's got cell phones, there's not much use for those things any more.  That's just as well, it's |Well, it used to be a payphone. Now it's } just a gutted payphone stand with stray wires poking out.
"""
        |> content__________________________________ "BUSTLING_CROWD" """
{Wow, this station is crowded. Everyone seems to be rushing off to somewhere.|
{?"Hey, watch it!" |
"Excuse me. Pardon me."|
"Make way, I've got a train to catch."
}}
"""
        |> content__________________________________ "MARCYS_PIZZA" """
I haven't eaten here before, but it looks popular.  It's packed, even this time of day.
"""
        |> content__________________________________ "MAINTENANCE_MAN" """
He's still at it, fixing the... well, whatever it is he's fixing.
"""
        |> content__________________________________ "SECURITY_DEPOT_SPRING_HILL_STATION" """
It's closed. It's good to see where my tax dollars are going.
"""
        |> content__________________________________ "BROOM_CLOSET" """
It's just a broom closet. Plenty of toilet paper and cleaning products, but no briefcase.{ If I ever see that Mark guy again, I swear, I'll...  I won't do anything. I'll probably be squatting next to him in a week or so.|}
"""
        |> content__________________________________ "PAYPHONE_SEVENTY_THIRD_STREET" """
It's a payphone. Not much use for those things anymore with everyone having cellphones these days.
"""
        |> content__________________________________ "inspectPasses" """
I have a Red Line Pass{ORANGE_LINE_PASS.location=PLAYER? and an Orange Line Pass}.

{It gets me anywhere on the Red Line, but I really only use it to get to work and back home.|}

{ORANGE_LINE_PASS.new?
I got the Orange Line Pass from the security guard guy.  Now I can ride the Orange Line without getting caught.
}
"""
        |> content__________________________________ "BUSINESS_MAN" """
He looks busy.
"""
        |> content__________________________________ "FRANKS_FRANKS" """
{MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1>1?
I may have helped one get a job, but I still don't like hot dogs.
|
I'm not really a hot dog guy.}
"""
        |> content__________________________________ "VENDING_MACHINE" """
It's an old snack machine. I don't recognize any of these brands. How long has it been since they changed these out? Ugh.
"""
        |> content__________________________________ "check_coin_return" """
Maybe there's some change left in the coin return, let me check.
---
...
---
Hey, a quarter!  Nice.
"""
        |> content__________________________________ "CONCERT_POSTER" """
{It's a poster for some kind of concert. Not sure what type of music it is, but telling from all the skulls, tigers, and half naked women colorfully scribbled in the margins I don't think I'd like it very much.
|
It's a poster for a rock concert, or something. I'm not much for music.
}
"""
        |> content__________________________________ "GRAFFITI_IRIS_LAKE" """
{It covers one of the walls from floor to ceiling. This station looks severely unused, but how can the authorities just leave this here?
|
These things are always so hard to read. Most of it illegible but I can make out the words "Wild West". I can't be sure though. If you're going to break the law, why not at least make what you're saying legible?
}
"""
        |> content__________________________________ "MAINTENANCE_DOOR_IRIS_LAKE_TO_WEST_MULBERRY" """
It's locked.
"""
        |> content__________________________________ "TRASHED_NEWSPAPERS" """
{It's a pile of trashed newspapers by a bench. They look pretty gross.  Hey, what's that? There's something in there.
---
...
---
AHH!
IT"S A FUCKING RAT!
|
NO!
------------------------------------------
NEVER!
|
GAH!
}
"""
        |> content__________________________________ "OLD_LADIES" """
{"...the state of this city has really gone down hill since-"

"I agree, all the radio talks about anymore is the homeless crisis-"

"And the crime rate."

"Did you hear about that man that jumped off that bank building yesterday? Laid on the side walk for nearly an hour before-"
|
"-nothing new, Maggy was nearly run down on MacArthur Street last week on her way to the bridge game."

"-probably a drunk driver.  I heard there's more of them these days than-"
|
"Go, go, go. That's all these people know how to do."

"-can't live that way."

"- won't last long."

"When's our train getting here? It's always late."
|
They're still chattering without a single pause. I bet a single second of silence would drive them mad.
}
"""
        |> content__________________________________ "LIVING_STATUE" """
Kind of cool... I bet they are really bored.
"""
        |> content__________________________________ "SLEEPING_MAN" """
{SLEEPING_MAN.coffee_ruined?  At least he didn't ask me to get him another coffee.
|
He's sitting on the ground with a shabby hat drawn over his face he's got a Styrofoam cup in front of him. Looks like he could use some {CHANGE.location=PLAYER.amount>0? [CHANGE](help_a_guy_out) | change}.
}
"""
        |> content__________________________________ "coffee_ruined" """
I toss a quarter in the cup.
---
*SPLASH*

"Hey, what the fuck, asshole? That was my coffee!"

"Oh, I'm sorry! I thought-"
---
"Just fuck off, will ya?"
---
...
---
"Um... could I have my quarter back?"
---
He just scowls.  Guess not.
"""
        |> content__________________________________ "CENTRAL_GUARD_OFFICE_ENTRANCE" """
I really dodged a bullet there, I have no desire to go back.
"""
        |> content__________________________________ "MURAL" """
It's a mosaic mural made out of many different colors of glass. I think it's supposed to be some type of abstract piece, because I can't make out what it's supposed to be. It looks pretty though. I think.
"""
        |> content__________________________________ "BIRD" """
It's flying all over the place, barely missing the passing commuters. I'm not sure how it got in here, but it seems scared. Hopefully it finds it's way out.
"""
        |> content__________________________________ "COMMUTERS_ST_MARKS" """
Various come and go through the busy station.
"""
        |> content__________________________________ "SECRET_SERVICE_TYPE_GUY" """
{He's just standing against the wall, not doing anything. He doesn't even react to the passing crowds or trains. If he's trying not to look suspicious, he's not doing a very good job.
|
Oh shit, I think he's watching me. Eeek!
}
"""
        |> content__________________________________ "MAGAZINE_STAND" """
{~Biking, cars, computers, tabloid gossip. There's a zine for everything.
|
Maybe I should get a hobby. Golf? No. Guns? Nah ah. Cars?

I think I'll just stick to doing nothing.
|
"End of the World? Top 10 Reasons Why You Should Be Very, Very Afraid."  Wow, they'll really try anything to get you to buy these tabloids. Resorting to top ten lists. Yeesh.
|
The old man smiles toothily at me he sits behind the rack of magazines. I think he wants me to buy something.
}
"""
        |> content__________________________________ "FAKE_COP" """
{Oh my god, it's a police officer! I'm saved! He has to help me!

"Officer! Officer! I need your help!"

I tell him the whole story. My proposal, the missed stop, the thief. I even spill about jumping the turnstile. I don't care, I just need help.
---
He doesn't say a word while I talk. It's tough to read him with his aviators on, but I think he's really listening.

I finally finish and he stays quiet for a minute, then he takes off his sunglasses.
---
"Wow, man. That's a crazy fucking story. What are you going to do?"

"Uh, I thought you could help. You're a cop. You help people!"
---
"Oh... Oh! You're talking about my costume! Sorry, man, I ain't no cop. I'm on my way to my girlfriends costume brunch party. I told her this was fucking weird, but women, am I right bud?"

"God damn it. I've got to go."

"Well, hey man, good luck finding your ring or whatever!"
|
It's not a police officer. It's just an idiot in a costume.
}
"""
        |> content__________________________________ "ADVERTISEMENT" """
It's a giant poster advertising a hot new off-road vehicle. Four wheel drive, the highest safety test awards, great gas mileage, and... out of the price range of anyone one who steps foot in the subway.  Who do they think their selling to?
"""
        |> content__________________________________ "OVERTURNED_TRASHCAN" """
{~Looks like someone kicked it over. Half eaten food, stained newspapers, and other junk are splayed over the platform. Why do people have to be so senselessly destructive?
|
I'm not going to clean it up. Who knows what that stuff is covered in.
}
"""
        |> content__________________________________ "NEWSPAPER_VENDING_MACHINE" """
The door's been forced open and all the papers cleaned out. Didn't think anyone read the paper anymore, let alone stole them.
"""
        |> content__________________________________ "CUSTODIAN" """
{He's asleep on a bench.  This place is a wreck! How does he still have a job?
|
He's asleep. He should really do his job.

I'm going to wake him up.
---
No, I can't do that.  Maybe he's just on his break.
|
Wow, still on break.
}
"""
        |> content__________________________________ "TROPICAL_T_SHIRT_MAN" """
He easily stands out from the crowd and he looks to be utterly lost. Maybe he's from out of town?
---
{He's got a map, but it doesn't seem to be doing him much good. He just keeps looking from his map to the signs overhead.
---
I like his shirt though.
|
He still looks lost.  I'm just getting the subway layout figured out myself.
}
"""
        |> content__________________________________ "CONSTRUCTION_AREA" """
Half of the platform is draped in yellow tape and littered with orange cones. I remember hearing about this hefty construction project going on around here, but at this rate they're never going to finish.
"""
        |> content__________________________________ "FLUORESCENT_LIGHTS" """
{~Ugh, it's giving me a headache.
|
How hard is it to get someone out here to fix this thing?
|
It. Won't. Stop. But I can't look away.
}
"""
        |> content__________________________________ "maintenanceManAtOneHundredFourthStreet" """
{He looks to be working indiscriminately on a wall of pipes. Taping here, hammering there, lots of wrenching. It doesn't look like much is being fixed though, in fact this whole station seems like a Case 27B - 6 waiting to happen.  Maybe I should leave my card.
---
He doesn't seem to notice me, but he's muttering to himself, something about "this whole damn place is falling apart."

Better give him his space.
|
Now he's either hammering a very rusty pipe or wrenching a bent nail.
|
Maybe I should offer him a hand.
---
Ha ha, good one Steve!
---
Why am I so fascinated with his maintenance guy?
}
"""
