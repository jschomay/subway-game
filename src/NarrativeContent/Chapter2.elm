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
        |> content__________________________________ "putUpLastMissingDogPoster" """
This station doesn't have a poster yet.  Here, I'll hang one up now.

There, that's the last one.  Hope someone finds "Jonathan."
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
        |> content__________________________________ "throwAwayPosters" """
I'll just toss these posters in here. I mean, I've got more important things to do than looking around for "Jonathan."
"""
        |> content__________________________________ "ABANDONED_JACKET" """
{PLAYER.call_boss=1?
{Maybe I'll just check the pockets for change. I mean, it'll probably just get thrown out anyway.
---
...
---
Nope, nothing. Ah, well. It was worth a look anyways.
|
The pockets are empty.  No change in here.
}
|
{It's lying on the bench like someone just forgot it. It's pretty worn out so I sort of doubt they'll be coming back for it.
|It's just a discarded jacket. Nobody's coming back for it.}
}
"""
        |> content__________________________________ "stealMusiciansChange" """
I snatch two dirty quarters from the top of the pile and pocket them quickly so no one sees.

The violinist keeps on playing.
---
This isn't right, but it is just 50 cents. He's probably not even going to notice that it's missing. I mean, how could he?
"""
        |> content__________________________________ "stealMusiciansChangeSecondTime" """
I guess another quarter might be useful...
---
The musician suddenly speaks in a surprisingly low voice, "Stealing from a blind man.  I guess you need that more than I do."
---
Shit!
"""
        |> content__________________________________ "girlInYellowSecondEncounter" """
It's that girl again!  She really sticks out down here.  Oh, she sees me.
---
"Excuse me sir, would you like to buy some flowers? Only 50 cents for a bundle."

She hold up a cardboard box with bunches of various weeds and flowers held together by rubber bands. They look like they were plucked from every public garden and sidewalk crack in the city.  Not worth 50 cents.
---
Suddenly she spots someone behind me.  A moment of worry crosses her face, then she giggles and dashes away.

I turn around to see who startled her.  It's just a maintenance person.
---
When I turn back, she has completely disappeared!
---
Where did she go?

Am I imagining things?
"""
        --
        |> content__________________________________ "useChangeFromMotherToCallBoss" """
I've got this change from that woman with the annoying kid. It's just 50 cents, she probably won't miss it. Plus that kid is probably better off without all that sugar.
---
*Ring* *Ring*
---
"Hello, this is In your Hands Insurance Agency, how may I direct your call?"

"Hey Paula, this is Steve. Can I-"
---
"Steve? Steve who? You're going to have to be a little more specific, sir."

"Steve. Steve Perry. Insurance agent, office 213. We talked about your cat for like, twenty minutes in the break room last week."
---
"Okay Mr. Kerry. How may I direct your call?"

"Can I speak to Mr. Harris please? It's very urgent."

"Mr. Harris is very busy, sir. What is the nature of the call?"
---
"Dammit Paula, just put Jason on the phone, will you?"

She murmurs something unpleasant, but makes the transfer.
---
Okay, so what do I say? My briefcase and proposal were stolen, please don't fire me?

I can feel his hands around my throat already. Damn it.
---
"Where the HELL are you with my proposal, Steve?"

"Ah! Good morning Mr. Harris!"
---
"Cut the bullshit. You were supposed to be HERE an hour and a half ago --".

"About that sir... I've had a little trouble..."
---
Mr. Harris goes into a rant before I can explain any more.  He is yelling so loud that I have to hold the phone away from my ear.

A train pulls onto the platform.  The only passenger that exits is an odd looking man in a pulled up blue hoody.

We're the only two on the platform and he gives me a once-over.  Mr. Harris keeps yelling.
---
This guy looks familiar.

It's the thief!
---
"That's the guy-- hey stop!"

The thief recognizes me too and turns and runs.  Mr. Harris stops his tirade in surprise.

"What did you say to me Steve?  You want me to stop?  Why don't you--"

"Sorry Mr. Harris, I have to run.  I'll see you with the proposal very soon.  Bye!"

*CLICK*
---
The man disappears around a concrete pillar.

I chase after him, just in time to see him dash through an obscure maintenance door.

I want my briefcase back.

I'm going after him.
"""
        |> content__________________________________ "collectedEnoughChangeToCallBoss" """
I have the change. Guess there's no more avoiding it.
Here we go.
---
*Ring* *Ring*
---
"Hello, this is In your Hands Insurance Agency, how may I direct your call?"

"Hey Paula, this is Steve. Can I-"
---
"Steve? Steve who? You're going to have to be a little more specific, sir."

"Steve. Steve Perry. Insurance agent, office 213. We talked about your cat for like, twenty minutes in the break room last week."
---
"Okay Mr. Kerry. How may I direct your call?"

"Can I speak to Mr. Harris please? It's very urgent."

"Mr. Harris is very busy, sir. What is the nature of the call?"
---
"Dammit Paula, just put Jason on the phone, will you?"

She murmurs something unpleasant, but makes the transfer.
---
Okay, so what do I say? My briefcase and proposal were stolen, please don't fire me?

I can feel his hands around my throat already. Damn it.
---
"Where the HELL are you with my proposal, Steve?"

"Ah! Good morning Mr. Harris!"
---
"Cut the bullshit. You were supposed to be HERE an hour and a half ago --".

"About that sir... I've had a little trouble..."
---
Mr. Harris goes into a rant before I can explain any more.  He is yelling so loud that I have to hold the phone away from my ear.

A train pulls onto the platform.  The only passenger that exits is an odd looking man in a pulled up blue hoody.

We're the only two on the platform and he gives me a once-over.  Mr. Harris keeps yelling.
---
This guy looks familiar.

It's the thief!
---
"That's the guy-- hey stop!"

The thief recognizes me too and turns and runs.  Mr. Harris stops his tirade in surprise.

"What did you say to me Steve?  You want me to stop?  Why don't you--"

"Sorry Mr. Harris, I have to run.  I'll see you with the proposal very soon.  Bye!"

*CLICK*
---
The man disappears around a concrete pillar.

I chase after him, just in time to see him dash through an obscure maintenance door.

I want my briefcase back.

I'm going after him.
"""
        |> content__________________________________ "chaseThiefAgain" """
There's a big "DO NOT ENTER" sign.  But the door is unlocked...
---
*Creak*
---
This leads to a dark, dank, twisty passage.
---
What the hell, I'm going for it.
"""
        |> content__________________________________ "exitPassagewayAtFortySecondStreet" """
This passageway lets out in a different station.

I don't see the thief anywhere though.  Maybe he outran me?  Or took a different turn?
"""
        |> content__________________________________ "ELECTRIC_PANEL" """
Hmm... the lock is busted.  Lots of wires and blinking lights inside.  This is the panel that odd repairman-slash-security guard was messing with...
"""
        |> content__________________________________ "SECURITY_CAMERA_FORTY_SECOND_STREET" """
{You know, I'm surprised I never noticed these before.
|}
They must have this whole place under surveillance.
{---
Maybe I can locate the thief and see where he goes if I can find the security footage.  They must have a surveillance room down here somewhere.|}
"""
        |> content__________________________________ "catchConductorMessingWithPanel" """
He tinkers away on an electric panel on the wall.
---
...
---
There's [something](confront_repairman) about that guy...
"""
        |> content__________________________________ "confrontConductor" """
I know what it is, he looks like the security guard who yelled at me before.  But now he's a repair man?

I shout out to him.  "Hey, excuse me!"
---
He doesn't turn around.  I call out again.
---
He stops what he is doing and looks around.

I do know this guy.

"Aren't you that guy from Central Security?"

"Nope."
---
"You bailed me out, remember? Gave me an Orange pass and everything?"

"Nope."
---
What's going on here?  There's no mistaking it. This is him.  It's hard not to remember that grizzle.

"What are you doing here? And what's up with the uniform?"
---
He finally looks me in the eye and his expression changes.

"You ever think about what runs these trains?"

"Uh, no. Not really."
---
"Well maybe you should."

With that he takes off, heading deeper into the tunnel for the oncoming train.
---
What the hell just happened?
"""
        |> content__________________________________ "passageLocked" """
I guess it locked behind me. No going back now.
"""
        |> content__________________________________ "tryToJumpTurnstileWithRepairManWatching" """
I can't jump it with that repair guy here, he'll report me.
"""
        |> content__________________________________ "questionJumpingTurnstiles" """
I'm not the type to jump turnstiles.
---
Well...
---
Maybe I should [jump anyway](just_do_it).
"""
        |> content__________________________________ "jumpTurnstileFortySecondStreet" """
Okay, the first time didn't go so hot, but maybe I can do it this time.

This is it, Steve. No turning back. It's either get this proposal back, or get fired.
---
No one's looking. No guards in sight. Don't think about the consequences. Just jump and run.
---
Here.
---
We.
---
Go!
"""