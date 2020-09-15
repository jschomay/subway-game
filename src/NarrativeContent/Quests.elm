module NarrativeContent.Quests exposing (content)

import Dict exposing (Dict)
import NarrativeEngine.Syntax.Helpers exposing (ParseErrors)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser


content__________________________________ =
    Dict.insert


content : Dict String String
content =
    Dict.empty
        |> content__________________________________ "meetingScreamingChild" """
The child is screaming his head off.  It's actually very annoying.  Even his mother looks like she can barely take any more of it.  She looks at me apologetically.
---
"I'm sorry, he won't calm down.  He wants a soda, but I can't leave this spot because I'm waiting for someone."
---
This situation seems bad for everyone.
"""
        |> content__________________________________ "offerYourSodaToScreamingChildFromSoda" """
"Say, I actually have a soda.  I didn't drink it yet.  Do you want it?"
---
"Gross!  I don't want your weird soda!  Get away from me!"
"""
        |> content__________________________________ "offerYourSodaToScreamingChild" """
"Say, I actually have a soda.  I didn't drink it yet.  Do you want it?"
---
"Gross!  I don't want your weird soda!  Get away from me!"
"""
        |> content__________________________________ "offerToHelpScreamingChild" """
"Hey, I could go get you a soda if you want..."
---
"Oh my God, yes, please!  Here, take some change to buy it.  Thank you!"
"""
        |> content__________________________________ "keepBotheringMother" """
{"Did you find any soda?"

"Um... not yet."
|"So are you going to get me a soda or not?"
}
"""
        |> content__________________________________ "getSodaForScreamingChild" """
I put 50 cents in and a soda comes out.  Hope it's the right flavor.
"""
        |> content__________________________________ "giveSodaToScreamingChild" """
Here's your soda. I didn't know what flavor to get."

Without hesitation the child snatches the can from my hand and starts guzzling it down.

"Thank you so much!  Nice to know there are still decent people around."
"""
        |> content__________________________________ "noMoreScreamingChild" """
The kid has stopped screaming and the mother looks very relieved.  So am I.
"""
        ------------------------
        |> content__________________________________ "ratty_hat_man_advice_1" """
He's staring at me from across the room and mumbling to himself.

Wait a minute, did he just say something about a briefcase?
---
"Excuse me, I thought I just heard you mention--"

He holds up his finger with the utmost importance.

"Holds your things.  That's what you need.  A place to hold your things.  Where are your things?"

"Um... my briefcase was stolen.  Do you know something?"
---
"Ah... briefcase!  Yes.  West Mulberry.  East.  No, West.  Mulberry.  Yes."

"Are you saying you saw it at West Mulberry?"

"West Mulberry.  West Mulberry."

With that he turns and scampers away.
"""
        |> content__________________________________ "ratty_hat_man_advice_2" """
Hey, it's that guy again.  Oh no, he saw me.  Now he's approaching me.
---
"I have your case."
---
"Wait, what?"
---
"Forty third.  That's where it's at.  That's where it's all at."

Again, he dashes away.
"""
        |> content__________________________________ "ratty_hat_man_advice_3" """
There he is again.

"Proposal.  I've got a proposal.  A proposal to make."

"Ok, I'll bite."
---
"My friends, they know.  Samual, Walter and Mark.  Go to them.  Say hello."
"""
        |> content__________________________________ "ratty_hat_man_advice_4" """
Oh no, not again.
---
"Brief case.  Thief's face.  Safe place.  Iris Lake."
"""
        |> content__________________________________ "ratty_hat_man_advice_5" """
"Hey you!  I've been on a wild goose chase all over this subway system following your nonsense advice.  Have you seen my briefcase or haven't you?"
---
"Briefcase?  I haven't heard of any briefcase.  You really shouldn't talk to strangers.  Now if you'll excuse me, I have to go."
"""
        -----------------------
        |> content__________________________________ "meet_the_man_in_the_hot_dog_suit" """
{It's a man... in a grubby looking hot dog suit.

I guess I've seen weirder things down in the subway.

But... it looks like he is... crying?
---
"DON'T LOOK AT ME!"

"I'm sorry.  Are you... are you alright?"

He looks up at me and his face brightens up.  He pats the bench for me to join him, but the size of his suit makes it hard to sit. I think I'll just stand.
---
"Listen, buddy. You ever feel like no matter how hard you try, the world manages to find new ways of bringing you right back down?"
---
"Well, actually--"

"I know! Like take me for instance. I've been at this mascot game for years. I've done baseball games, sign flipping, children's pizza play houses. I've been around the rotisserie and back again. But this was my one chance. A chance for the big times."
---
"Listen, I really don't have time for this. I've got my own problems right now."

"Hey just hear me out. I'll be brief.  I need to get a job at a hot dog stand, but I can't without a respectable reference to butter me up.  You look like a respectable sort.  Will you be my representation?"
---
That's my cue to slowly walk away...

But the guy jumps up and tosses his resume in my hands.

"Listen, stop by Frank's Franks on University Station.  Ask for Frank, drop off my papers, tell him I'm a swell guy.  Do this for me and I'll make it worth your while."
---
Why does this keep happening to me? Am I a freak magnet or something?

"Thanks, bud. You won't regret this!"
|
"Hey, did you talk to Frank at Frank's Franks for me yet? I can't just sit around on my buns all day!"
}
"""
        |> content__________________________________ "MASCOT_PAPERS" """
Resume for the man in the hot dog suit.

Wow, he means business.
"""
        |> content__________________________________ "give_mascot_papers_to_frank" """
The stand is greasy looking and the man behind it even greasier.

"Yo, wanna 'dog? Only a buck fifty."
---
"No thanks, but are you Frank? I... uh... hear you're looking for a hot dog guy."

"Oh yeah? What experience you got?"

"Oh!  No, not for me. It's for my... client. A real stand-up guy.  Here's his resume."
---
Frank looks it over and whistles.

"Hey, this looks good.  You cant imagine the weirdos that try to get this sort of gig. I'll give him a ring."
---
Well, Steve, today you're going to make a weirdo very happy. Good on you.
"""
        |> content__________________________________ "check_up_on_hot_dog_guy_at_franks_franks" """
Wow, he got here fast.

He's already at it.  Looks like he's having the time of his life.  But everyone mostly ignores him.  At least he's happy.

He's coming over to talk to me.
---
"Oh, man. I didn't think I'd get the chance to thank you! But... Thank you! You don't know how much you've just changed my life!"

He hugs me tight.

"Uh, don't mention it. Please."
---
"Oh, and here's a little tip someone gave me, it's all yours for the help you're doing me."

He drops 2 quarters in my hand and waves as he rushes back to his stand.  Is this what he meant by "worth while?"
"""
        |> content__________________________________ "throw_away_mascot_papers" """
There.  Who makes a resume to be a hot dog anyway?
"""
        |> content__________________________________ "hot_dog_man_rebuffed" """
{"What did Frank say?  Did he say anything?  Did he turn me down?  Oh no, he turned me down, didn't he.  I'm a failure.  I'll never be a hot dog man.  Ohhhhhh....."
|
The guy is still crying.  What a weenie.
}
{||Heh heh.  Weenie.}
"""
        |> content__________________________________ "man_in_hot_dog_suit_wants_more" """
"Thanks, bud. You won't regret this!"
"""
