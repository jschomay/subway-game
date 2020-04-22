module NarrativeContent.Static exposing (content)

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
        |> content__________________________________ "GRAFFITI"
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
        |> content__________________________________ "ridingTheTrain" ""
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
        |> content__________________________________ "TRASH_CAN_WEST_MULBERRY" """
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
I have 0.{CHANGE.amount} cents.
"""
        |> content__________________________________ "DOLLAR_BILL" """
A wrinkled dollar bill.
"""
        |> content__________________________________ "MUSICIAN" """
He's playing an old cracked violin with a hat out in front of him for spare change.

The music sounds nice, but I wouldn't call that a real job.
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
