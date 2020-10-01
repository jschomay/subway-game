module NarrativeContent.Chapter1 exposing (content)

import Dict exposing (Dict)
import NarrativeEngine.Syntax.Helpers exposing (ParseErrors)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser


content__________________________________ =
    Dict.insert


content : Dict String String
content =
    Dict.empty
        |> content__________________________________ "askMaintenanceManForDirections" """
{"Excuse me, sir! How can I get to Broadway Street Station as quickly as possible?"
---
"Damn it, can't you see I'm busy?  Go and check the damn map if you're lost. It's that big map looking thing on the wall over there."
---
"Uh, okay. Thank you."
|
He's busy and I don't want to get yelled at again.
}
"""
        |> content__________________________________ "getMap"
            """
{It's a map of the whole subway.{BRIEFCASE.location=PLAYER?   It's only 6:15. If I leave here now I should be able to make it to work on time.}
---
There's also little map pamphlets here as well.  I'll take one with me just in case. Don't want to get lost again!

(check MAP by pressing "M")
|}
"""
        |> content__________________________________ "notGoingToWorkAgain" """
I've got to get to Broadway Street Station.  Any more wrong stops and I'm really going to be late.
"""
        |> content__________________________________ "delaysAtBroadwayStreetStation" """
Everything's fine. It was just a little detour, I've still got time. At least I'm wide awake now.
---
The loud speaker buzzes.

"Attention passengers, due to some unforeseen events you may experience delays at Broadway Street Station.  Thank you for your understanding and have a nice day."
---
What? What do they mean "delays?"
"""
        |> content__________________________________ "EXIT" """
{ANGRY_CROWD.location=BROADWAY_STREET? There's a big crowd of people blocking my view, but it looks like the exits have their shutters down.  What the hell is going on here?|It's still locked.}
"""
        |> content__________________________________ "ANGRY_CROWD" """
{BRIEFCASE.location=PLAYER?
{What's going on over here? No one seems to be moving and everyone seems pretty angry.

Some people are shouting about the doors being locked.
---
|}
I can't seem to push my way through all these angry people.  Now what?
|
{They haven't budged.  Apparently no one saw me get robbed.  Or they just don't care.
---
The mob seems to be getting angrier. I hope they open those doors soon or this could get ugly.}
}
"""
        |> content__________________________________ "leavingBroadwayStationPrematurely" """
This is my stop, where else would I need to go?
"""
        |> content__________________________________ "askOfficersAboutDelay" """
{
Oh good, some officers are here.  I can find out what the hold up is.

"Excuse me, ma'am? I--"

She cuts me off mid sentence.
---
"This exit is closed sir. There's an incident going on above ground and we're not letting anyone through 'till we get the all clear. You will have to wait like all the others."
---
"But I work up there! I'm going to be late if I don't--"

Again she cuts me off.
|}
"If you are unable to wait, take the train to the next stop and walk from there."

"But I--"

"Have a nice day sir."
---
Why aren't these officers doing their jobs?
"""
        |> content__________________________________ "askCommuter1AboutDelay" """
{COMMUTER_1.friendliness>0?
{It's that woman I saw on Monday.

"Excuse me, miss? What's going on? Why isn't anyone moving?"

"Oh, Hi! Those security guards locked the gates. They're not budging. All they'll say is that there is some incident above ground and they're not letting anyone through."
---
"But I can't stay here. I have to get to work.  I have an important presentation today."

"I know.  If I'm late one more time I'm bound to get fired.  I've got to figure out some other way out of here."
|
Looks like she's just as stuck as I am.
}
|
{"Excuse me, miss?"
|
She's ignoring me. The nerve of some people.}
}
"""
        |> content__________________________________ "noticeGirlInYellow" """
I can't help noticing this girl.  There's something about her, like she doesn't belong.  Her dress is the brightest thing down here.  She sticks out like a dandelion growing through the cracks in the sidewalk.
---
The crowd closes around her for a second, blocking my view.  I wait for a minute, but she seems to have disappeared.
---
I only saw her for a split second.  Did I imagine her?
"""
        |> content__________________________________ "briefcaseStolen" """
Jeez!  Someone just ran into me.

"Ow! Hey! Watch where you're going!"
---
Wait. Where's my briefcase?
---
No. No no no no no no no no no. No.
---
I've been robbed... My presentation... It's gone!  I... I need to get help. Now.
"""
        |> content__________________________________ "tellOfficersAboutStolenBriefcase" """
{
"Help! Help! I've been robbed! Some crook just took my briefcase!"

"I'm sorry, but the exit is closed sir--"
---
"I don't care about that! My presentation is gone!  I need you to do something!"

"Please calm down, sir. We need people to clear this station. Please take any concerns you have to the Security Depot at Spring Hill Station. We apologize for any inconvenience and hope you have a nice day."
---
"But I can't go to work with out it. My life will be over!"

"Have a nice day, sir."
---
They aren't even listening to me.  Why aren't they helping me?

I guess I can check out the Security Depot.  Maybe they'll actually do something.
|
"Have a nice day sir."
}
"""
        |> content__________________________________ "tellCommuter1AboutStolenBriefcase" """
{COMMUTER_1.friendliness>0?
{"Did you see a man run by with my briefcase I was carrying? He just robbed me."
---
"Oh my God, that's terrible! I think I saw someone with a briefcase like yours head for the trains. But it's hard to tell, there's so many of you business types with similar briefcases."

"Oh man, I've got to get it back somehow.  I'm so screwed."

"I hope you find it!"
|
"Did you find it yet?"
}
|
{"Pardon me, miss! Did you see a man run through here with a briefcase?"

"Um, yes? There's a lot of those around."
---
"No, he was a thief! He took my briefcase!"

"Sorry, sir. I can't help you."
---
Useless!
|
She's no help.
}
}
"""
        |> content__________________________________ "SECURITY_OFFICERS" """
"Have a nice day sir."
"""
        |> content__________________________________ "followGuardsAdvice" """
{"Someone at the Security Depot better be able to help me. I have to get my proposal back!"|}
"""
        |> content__________________________________ "ignoreGuardsAdvice" """
If those guards at Metro Center can't help me, what are the chances that any of the other guards will be any better? Maybe I can find the thief on my own and make a citizens arrest. Or something.
---
This is a bad idea.
"""
        |> content__________________________________ "panic" """
Why is this happening to me?!  I always follow the rules.  I work hard.  But I get walked over all my life.  And now some crook is going to make me miss my presentation and my promotion!  It's just not fair.
---
I'm going to have to take matters into my own hands.  Maybe I can find the thief and arrest him or something.
---
This is a bad idea.

I better just report this to the authorities somewhere.
"""
        |> content__________________________________ "findingSecurityDepotClosed" """
It's closed. Of course it's closed! The one time I need the subway security and they're off doing God knows what.
---
What am I going to do? Everything was in that Briefcase.  My wallet, my reports, and worst of all my proposal! The key to finally turning my life around. Without it I may as well just walk in front of the next train.
---
I followed the rules. I pay my taxes on time. I make sure to do everything right. And people can still just up and break the law and nobody does a thing about it. Shitty people run rampant while people like me are left to suffer.
---
Mr. Harris is going to kill me. What the hell am I going to do?
---
...
---
"Hey, man. Are you crying?"

Who said that?
"""
        |> content__________________________________ "helpFromSkaterDude" """
{Aw damn!  It's that skater punk that's always goofing around my station.

He lights up a cigarette even though this is clearly a no smoking area, and gazes at me with smug amusement.
---
"I'm not crying.  I'm just... under a lot of stress."

"Something of yours get snatched?"

"Why would you say that?"
---
He flicks ashes onto the floor.

"Seen a few suits like you dragging around the pig sty. Not sure why, it's been closed all week.  None of 'em cried though."
---
"I wasn't-- never mind.  Did the others get any help?"

"Nah, cops are never any help.  Especially today, they're all hung up at Broadway Station for some reason.  Your junk's probably been dumped in a trashcan somewhere.  That's what usually happens."

"That's great!  Maybe we can still find it."
---
The punk takes his time finishing off his cigarette before finally responding.

"Doubt it, the bums will beat us to it.  What's so important about it anyway?  Just buy another one."

"Damn!  No, I need to get it back at all costs. It's got a very important presentation in it."

He looks at me with a glimmer in his eye.
---
"Well...  I happen to know the bum's ringleader.  I could take you to him."

"Yes!  Please!"

"What's it worth to you?"
---
"What do you mean, you want cash?  I guess I could give you a hundred--"

"A thousand."

"No way, I--"

He jumps on his skate board and starts rolling away.

"Wait!  OK, a thousand.  But not until I see some results.  Who do I talk to?"

"Follow me. We got a train to catch."
---
He rides off on his skateboard over to the orange line.
|
"Let's go, orange line's this way."
}
"""
        |> content__________________________________ "forcePlayerToFollowSkaterDudeOntoOrangeLine" """
"Hey! Where you going? We gotta ride the orange line."

"But I don't have a ticket."

"So?"
"""
        |> content__________________________________ "forcePlayerToFollowSkaterDudeToCapitolHeights" """
"Yo, that's the wrong train!  We're headed to Capitol Heights."
"""
        |> content__________________________________ "followSkaterDudeToOrangeLine" """
"My guy's at Capitol Heights Station."

"But I don't have tickets for the orange line!"
---
"You don't need any of that. Just hop the stile. It don't cost a thing."

Without another word he's over the turnstile in one swift movement. No alarms sound, no security guards running.

Nothing.

"Come on, man. It ain't nothin. Hurry up, train's about to leave."
---
He makes it sound so easy. But I can't just break the law.  This punk's used to it, but what if I get caught?

Then again what if I don't get my proposal back?
"""
        |> content__________________________________ "jumpTurnstileWithSkaterDude" """
Here goes nothing...
"""
        |> content__________________________________ "followSkaterDudeToCapitalHeights" """
I just broke the law. I'm riding without a ticket or a pass.  This isn't right.
---
Is that guy staring at me? He knows I jumped. He knows I did something wrong. Everyone knows. I have to get out of here, I can't breath. I--

"Hey, man. Chill the fuck out.  You don't want to draw attention to us."
---
"Speaking of which... I can't be seen around Capitol Heights, so you're gonna have to do this next part alone.  Just look for Mark.  You got that?  Mark."

The train approaches our station.
---
"Wait, how will I know what he looks like?"

"I'll be waiting for you down at 104th Street Station.  Come find me there when you find your briefcase.  And don't try running off without paying me. I got eyes and ears everywhere down here, man. If you don't find me, I'll find you."
---
He shoves me off the train onto the platform.
"""
        |> content__________________________________ "findKeyInTrashCan" """
It's just a trash can. Nothing important here.
---
...
---
Wait. There's something inside.

I better not regret this...
---
This is a strange key.  I think I'll hold onto it. Just in case.
"""
        |> content__________________________________ "ODD_KEY" """
I wonder what this is for. It's probably just junk.
"""
        |> content__________________________________ "SHIFTY_MAN" """
{He stands in the shadows of the platform away from the crowds and he seems to jump at every loud noise. This guys has to be up to something.
|
{PLAYER.find_briefcase=2?"Excuse me, sir? Your name wouldn't happen to be Mark would it?"
---
"Beat it, shit head. I'm waiting for someone."
|
He's still up to no good.
}
|
He's still up to no good.
}
"""
        |> content__________________________________ "SPIKY_HAIR_GUY" """
{{PLAYER.find_briefcase=2?"Excuse me, Mark?"

"Sorry, bud. Wrong guy."
|
That's not Mark.
}
|
That's not Mark.
}
"""
        |> content__________________________________ "GREEN_SUIT_MAN" """
His suit looks like it costs more than my rent.  I'm not going to bother him.
"""
        |> content__________________________________ "markTellsAboutBroomCloset" """
His clothes are covered in dirt and holes. He sits on the tile floor with a sign.

The sign reads, "Hi, I'm Mark. Anything helps. God Ble$$."
---
Well, that was easy.
---
I quickly explain the situation, but he doesn't seem to be following any of it.

This was a waste of time!
---
"Did you say briefcase?"

"Yeah, it was stolen.  I was told you might have found it."

Now that I say it, it sounds really dumb.  Why did I think this would work?
---
His eyes go blank for a few moments, then with a sudden jolt, he's back again.

"Yeah, bout 10 minutes ago. One of the rail kiddies was lugging around this real fancy thing."

"Oh my God, really?! Did you say rail kitty?  Never mind.  Tell me, where did he go?"
---
"Hold your horses. He hangs out with a real rough group, bunch of nabbers and grabbers. But ol' Mark's seen where they horde their stash.  An old broom closet at 73rd Street Station, lock doesn't even work--"
---
"That's great, thanks!  Gotta go!"

I leave the bum still talking to himself about the broom closet.
"""
        |> content__________________________________ "pleasantriesWithMark" """
He's still describing the broom closet...
"""
        |> content__________________________________ "jumpTurnstileAfterTaklingToMark" """
Ok, I've done this once before, I'll just do it the same way the skater punk showed me.  Nice and easy...
---
Made it!  That wasn't so bad.  I'm starting to get the hang of it.
"""
        |> content__________________________________ "caughtOnOrangeLineHeadingTo73rd" """
I'm so close.  This has been one crazy morning, but I'll just grab my briefcase now, hopefully everything is still in there, and I can buy a ticket back to my station and get to work and give the presesntation and get my promotion and everything will be fine.
---
"Excuse me sir, can I see your ticket or pass please?"
---
...
---
Oh.  Shit.
"""
        |> content__________________________________ "caughtOnOrangeLineHeadingToOther" """
Oh no, I got on the wrong train!  Mark said 73rd Street Station, how did I mess this up?
---
It's ok, take a few breaths.  I'll just get off at the next stop, then catch the right train.  Then I can grab my briefcase, hopefully everything is still in there, and I can buy a ticket back to my station and get to work and give the presesntation and get my promotion and everything will be fine.
---
"Excuse me sir, can I see your ticket or pass please?"
---
...
---
Oh.  Shit.
"""
        |> content__________________________________ "TICKET_INSPECTOR" """
"Where am I!?"

"This is the Central Guard Station at St. Mark's. Follow the instructions on the poster."

"But--"
---
The steel door slams shut before I can get another word out and he is gone.
"""
        |> content__________________________________ "INFRACTIONS_ROOM_DOOR" """
{It's locked. I'm trapped. What am I supposed to do? And how do I get out  of here? They can't keep me in here like this.
---
Can they?
|{?
It's locked.
|
Still locked.
|
Maybe if I jiggle the handle a few more times...
|
Nope. It's locked.
|
Wait a second. I think I got it! Oh, no. Just kidding. Still locked.
}}
"""
        |> content__________________________________ "readingInfrationsPoster" """
{_Violators of the law! Due to high volumes of fare evasion, vandalism, and littering, all minor infractions will be dealt with by our new automated system. Please read carefully the following instructions as Transit Authorities Fine Distribution has recently changed:_
---
_Step 1: Approach computer terminal in center of room (WARNING: Do not press the big green button)._
---
_Step 2:  Scan a state issued ID, Transit Line Pass, or input social security number and verify the listed personal information. System will power on after input._
---
_Step 3: Select minor infraction the violator is accused of (WARNING: you are being monitored, any attempt to supply misinformation will be met with harsh consequences!)._
---
_Step 4: Press send. The information provided will now be processed and verified by a member of Transit Authority. Whilst this is happening the violator may fill out a Violation Dispute Document on the computer or a Violation Apology Document (WARNING: All documents are subject to be read at Transit Authorities earliest convenience)._
---
_Step 5:  If all the information is correct, a fine ticket will print out next to the computer and the door will be unlocked. Once the ticket has been removed the violator may leave the Detention Room._
---
_Thank you and have a nice day!_
---
Wow, this seems overly complicated. I'm never going to break the law again.
|
_Violators of the law! Due to high volumes of fare evasion..._

Blah, blah blah... let's see, scan your pass... check the computer... print ticket.

Hmmm.
}
"""
        |> content__________________________________ "infractionAutomationStep1" """
Well, It's a card reader, and the only card I have on me is my Red Line Pass. It's worth a try.
---
*BEEP*
---
Aha! The computer seems to be booting up... very slowly. Where did they dig up this antique? It makes our computers at the office look new. As long as it's working I guess.
"""
        |> content__________________________________ "INFRACTIONS_CARD_READER" """
{INFRACTIONS_ROOM_DOOR.infraction_step=1?  I can already see my personal information on the computer screen.  No need to scan my Red Line Pass again. }

{INFRACTIONS_ROOM_DOOR.infraction_step=2?  They already  have my info.  I don't want to get fined again! }

{INFRACTIONS_ROOM_DOOR.infraction_step=3?  The computer is still rebooting and the whole system is broken. Damn it! Why isn't anything working!
}
"""
        |> content__________________________________ "infractionAutomationStep2" """
I can see all of my personal info on the dusty computer monitor. My name, age, address. Everything. It all seems up to date, though that picture certainly isn't.

I'll just going to hit send and get this over with.
---
...
---
This thing is sure taking a long time.
---
There it goes. Now it's asking me to select my violation. "Fare Evasion" sounds so official.  I hope this doesn't go on a permanent record. I don't know if I'll ever live this down.
---
There. It's sent. How long will I have to wait now for this to print?
"""
        |> content__________________________________ "INFRACTIONS_COMPUTER" """
{INFRACTIONS_ROOM_DOOR.infraction_step=0?  The computer doesn't seem to be on. But there is a [green lit button](INFRACTIONS_GREEN_BUTTON) on it's front.}

{INFRACTIONS_ROOM_DOOR.infraction_step=2?  Everything is sent and I just have to get my printed ticket. I wonder how much this is going to cost me.}

{INFRACTIONS_ROOM_DOOR.infraction_step=3?  It's stuck on the blue screen of death! }
"""
        |> content__________________________________ "infractionAutomationStep3" """
{Nothing's coming out! Did something break?
---
Something must have went wrong because the computer seems to be rebooting!

Damn it! Why isn't anything working!  What do I do now?
|
The whole damn system is broken and I'm stuck!
}
"""
        |> content__________________________________ "INFRACTIONS_PRINTER" """
It's an old printer attached to the computer. It looks like it barely works.
"""
        |> content__________________________________ "breakInfractionAutomationSystem" """
Maybe it will start if I press this.
---
Nothing happens.
---
...
---
Oh no.  The computer is making a terrible sound.
---
Maybe it's starting up.
---
Nope.  It's rebooting.  But it looks like it froze.

I'm stuck! What did I do? What did I do?
"""
        |> content__________________________________ "pourSodaOnInfractionsMachine" """
This damn system!

In an uncharacteristic moment of weakness, I pop open this can of soda I still have for some reason and pour it all over the damn machine.

It sizzles and sparks, and the whole thing goes off-line, then resets.
"""
        |> content__________________________________ "escapingInfractionRoom" """
It's open! The reseting computer must have reset the locks. Seems like a flaw in the design, but I'll take it.
---
The door opens up to the maze of hallways. I think I can remember the path back to the station platform.

It was left, left, right, straight till the water cooler, then another left, or was it right--
---
"Hey, what are you doing back here?"
---
Shit, another security guard.

He's looking right at me.

He looks pissed...
"""
        |> content__________________________________ "meetConductorFirstTime" """
"No one is supposed to be back here right now! What are you doing here?"

Now that he's close up, he seems a lot different than the other security guards. His uniform even seems a little too big for him.  He does look flustered, though.
---
"I-I'm sorry, sir. {INFRACTIONS_GREEN_BUTTON.pressed? The computer was turned off.  I just pressed the button to turn it on|I followed all of the steps like the poster said}, but the whole thing broke down."

He seems real upset.
---
"That's typical.  Everything around here is breaking down under too much load."

He looks in the room as if expecting to find someone else.
---
"I'm sorry pal, I didn't mean to yell at you.  They aren't supposed to be taking people here today.  It's closed.  For pest control spraying."

"Spraying?"

"Look, just go.  The exit is down the hallway behind me.  Three lefts and a right and you're out.  I've got to take care of something."
---
I guess I got off easy.  I didn't see any rats or bugs or anything in there though.
---
"Hey, buddy!  Hang on a minute."

Uh oh.
---
He holds something out to me.

"Here, take this.  Don't want you to end up back here again."
---
It's an Orange Line pass!  That's great.

What a strange guy.
"""
