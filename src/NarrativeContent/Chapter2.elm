module NarrativeContent.Chapter2 exposing (content)

import Dict exposing (Dict)
import NarrativeEngine.Syntax.Helpers exposing (ParseErrors)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser


content__________________________________ =
    Dict.insert


content : Dict String String
content =
    Dict.empty
        |> content__________________________________ "checkBroomClosetButNotBriefcase" """
I finally made it. This is my last chance. It has to be in here.
---
*Click*
---
Well, it's unlocked.
---
*Creeeeeeaaak*
---
It's dark, but I don't need to flip the switch to see that there's nothing in here but cleaning supplies.

Of course there's nothing in here. What was I expecting? 
---
Damn I wanted it to be true.
---
...
---
My proposal is gone, and without that, no promotion. Hell, who am I kidding?  It's way past 6:30, I probably don't even have a job anymore.
---
I guess it's time to call Mr. Harris and tell him what happened.  I better find a phone.
---
Damn, and I was so close to that promotion. I would have had it made.
"""
        |> content__________________________________ "needCoinsForPayphone" """
{Hmm, there's no dial tone.
---
Oh yeah, you've got to pay for these things.  Shoot, and I don't have enough change.  No wonder they're disappearing.
---
Guess I'll have to ask around for change. I mean, how hard can it to be to get 50 cents?
---
I'm not really in any rush to talk to Mr. Harris anyways.
|
It costs 50 cents to use. Better start begging for change.  I'm going to need the practice.
}
"""
        |> content__________________________________ "ponderingCallingBossOnTrain" """
{Mr. Harris is going to hate me.  I'm really not looking forward to calling him.|}
"""
        |> content__________________________________ "tryingToCallBossWithCellphone" """
I still don't have any service down here.  I'd have to go above ground to make a call.  I guess I could do that, but I'm in no hurry.  And it's probably raining.  And this is my big opportunity to use a payphone for once.
"""
