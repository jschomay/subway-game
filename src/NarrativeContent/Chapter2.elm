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
        |> content__________________________________ "getDogPostersFromDistressedWoman" """
She's wearing a pink poncho, maybe she's expecting rain in the subway?

Oh no, she's walking towards me.  I look away.
---
"Oh, thank goodness. You look like a capable young man. Could I ask for an itsy bitsy favor from you? It won't take long, and you'd be saving a life."
---
She shoves a handful of posters at me.

"Thanks!  I lost my little dog, Jonathan, down here.  I'm hanging up these posters hoping someone will find him.  Just hang these up on the Red Line for me."

Before I can respond she dashes after someone else.
"""
        |> content__________________________________ "lookAtHangingDogPosters" """
{How sad!  He must be so scared down here.  |
Says the dog's name is Jonathan. Weird name for a dog.
|
Maybe I should make one of these for my briefcase.

Naw, that's stupid. These things never work.
|
$3000 reward? Damn, I'm in the wrong business. How would "Dog Bounty Hunter" look on a business card. Hmmmm...
|
I wonder if he's been found yet.
}
"""
        |> content__________________________________ "putUpMissingDogPoster" """
This station doesn't have a poster yet.  Here, I'll hang one up now.
"""
        |> content__________________________________ "tryToHangDogPosterOnWrongLine" """
That lady in the pink poncho wanted me to hang these on the Red line.
"""
        |> content__________________________________ "tryToHangRedundantDogPosters" """
I've got a few posters left, but this station already has one.
"""
        |> content__________________________________ "askBusinessmanForChange" """
"Say, you don't happen to have 50 cents, do you?"

"And what have you done to earn, may I ask?"
---
"No, I just need 50 cents for the--"

"I didn't ask what you needed it for, I'm asking what you've done to deserve it."
---
What the hell?
---
"Listen, I--"

"No, you listen. Pay is given to those that work. Sitting on your ass begging people for money is not work. You think I got to where I am today by "asking" for what I wanted?"
---
"Forget about it. I can--"

"No, I worked for what I wanted and took it. Success is not founded by beggars, but by choosers."
---
Before I can say another word, the man steps through the turnstile and doesn't look back.

What an asshole.
"""
        |> content__________________________________ "TRASH_CAN_SEVENTY_THIRD_STREET" """
Nothing but trash in here.
"""
        |> content__________________________________ "trashcanWhileHoldingPosters" """
Nothing but trash in here.
---
I'm lugging around these missing dog posters.  I don't want to go hang them all up, maybe I should just [throw them away](throw_away_posters) instead.
"""
        |> content__________________________________ "throwAwayPosters" """
I'll just toss these posters in here. I mean, I've got more important things to do than looking around for "Jonathan."
"""
