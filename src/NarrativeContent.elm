module NarrativeContent exposing (parseErrors, t)

import Dict exposing (Dict)
import NarrativeEngine.Utils.Helpers exposing (ParseError)
import NarrativeEngine.Utils.NarrativeParser exposing (..)


{-| This is a little nicer than having to export every string.
NOTE this could be used for i18n too kind of
-}
t : String -> String
t key =
    Dict.get key all
        |> Maybe.withDefault ("ERROR: can't find content for key " ++ key)


emptyConfig =
    { cycleIndex = 0
    , propKeywords = Dict.empty
    , trigger = ""
    , worldModel = Dict.empty
    }


{-| Pre-parses everything at run time to find errors to display.
-}
parseErrors : List ( String, ParseError )
parseErrors =
    Dict.foldl
        (\k v acc ->
            case parsible emptyConfig v of
                Err e ->
                    ( "Narrative content: " ++ k ++ " " ++ v ++ " ", e ) :: acc

                _ ->
                    acc
        )
        []
        all


all : Dict String String
all =
    List.foldl Dict.union
        Dict.empty
        [ silent
        , general
        , intro
        , chapter1
        ]


content__________________________________ =
    Dict.insert


{-| rules that shouldn't show any text
-}
silent : Dict String String
silent =
    Dict.empty
        |> content__________________________________ "goToLobby" ""
        |> content__________________________________ "goToLineTurnstile" ""
        |> content__________________________________ "goToLinePlatform" ""
        |> content__________________________________ "checkMap" ""


general : Dict String String
general =
    Dict.empty
        |> content__________________________________ "BRIEFCASE"
            "My portable office, all my work is in it."
        |> content__________________________________ "notebookInstructions" """
{I have my notebook with me to day to keep track of everything.

(Click the notebook icon or press 'n' to toggle the notebook from now on)
|}
"""
        |> content__________________________________ "RED_LINE_PASS"
            "This gets me anywhere on the Red Line, but I really only use it to get to work and back home."
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
            "{I've never jumped a turnstile in my life, and I'm not about to start now.|I don't want to get caught.|Better to stick to the lines I have passes for.}"
        |> content__________________________________ "outOfServiceStations" """
PLEASE NOTICE: Normal service disruption is in effect.

{$.name} Station is temporarily out of service.  Please use alternative options.

Thank you and we apologize for the inconvenience.
"""


intro : Dict String String
intro =
    Dict.empty
        |> content__________________________________ "firstInteractionWithCommuter1" """
{Another commuter waiting on the train.  I say hello and she says hello back.
|I think one hello is enough when talking to complete strangers.}
"""
        -- (NOTE this rule is general)
        |> content__________________________________ "checkEmails" """
{There's no service, but I can view my emails.
---
|}
{PLAYER.day=1?
    From: Jason Harris
    To: Steve Perkins
    Sent: Sunday, 4:00 pm
    Subject: I've Got a Job for You

    Steve,
    Just got word that some very important clients are coming in in the next few weeks.
    The boys up stairs want me to put together a new proposal to bring to them. 
    Steve, you're one of our senior agents and you've been in the department for, what, 6 years?
    I need you to work on this and really make it shine.
    Be at my office at 6:30 am Monday and we can talk over the details.

    Jason Harris
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply -

    From: Steve Perkins
    To: Jason Harris
    Sent: Sunday, 4:01 pm
    Subject: RE: I've Got a Job for You
    
    Dear Mr. Harris,
    I've actually been with the company for eight years, but no need to worry, sir. I'm happy for the 
    opportunity. I've got a few big ideas that I've been wanting to try out.
    I'll be there bright and early, sir.
    
    Steve Perkins
    Insurance Agent
    In Your Hands Insurance
---
    From: Janice Franz
    To: Steve Perkins
    Sent: Monday, 6:05am
    Subject: Job Opportunity
    
    Hi Mr. Steve Perkins

    My name is Janis and I'm reaching out on behalf of Embrace Insurance. I came across your resume
    in our system and I believe you would make a perfect fit for our team here at Embrace Insurance.
    If you're looking for a job change or would just simply like to see what your options are we would
    love to set up a meeting with you and see what your future could hold.

    We look forward to your response!
    
    Janis Franz
    Assistant Director
    Embrace Insurance
}
{PLAYER.day=2?
    From: Jason Harris
    To: Steve Perkins
    Sent: Monday, 6:26pm
    Subject: Good Things!

    Steve,

    I like a few of the ideas that you brought to me this morning.  But I just got word that our clients are
    pushing up the meeting and will be here on Friday! You're going to have to put this thing in high gear, Steve.
    I can't hand them half assed work.

    Don't let me down.

    Jason Harris
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply-

    From: Steve Perkins
    To: Jason Harris
    Sent: Monday, 6:32pm
    Subject: RE: Good Things!

    Dear Mr. Harris,

    Thank you for the update.  I'll do my best, but Friday is a little soon isn't it? I just want to be able to
    put together something that will really help our customers.  I'll have to cut a lot of the ideas we spoke about.
    But I'll do my best, sir.

    See you tomorrow, Mr. Harris

    Steve Perkins
    Insurance Agent
    In Your Hands Insurance
---
    From: Henry Thorne
    To: Steve Perkins
    Sent: Monday, 8:25pm
    Subject: Stevey!

    Hey Steve!

    How's it going? Long time no talk! Just checking in with you and letting you know I'm going to be
    in the city in a few days. It's supposed to be a business trip and it's just for a day, but I
    thought it's be nice to drop by and see how things were and maybe grab a few drinks somewhere.
    I know things have been difficult since we last talked. Just let me know when you're free and I'll
    make something work.

    See you soon!

    Henry

}
{PLAYER.day=3?

    From: Jason Harris
    To: Steve Perkins
    Sent: Tuesday, 4:48pm
    Subject: No good

    Steve,

    What you handed me today WON'T work. The Premiums we offer will NOT cover these plans. Half of these
    seem like life quality expenses. We need to think about the bottom dollar here, Steve. "Pet Insurance
    Plan", "Kidnap/Ransom Insurance", "Divorce Insurance"? These benefits not only expose us to
    unwarranted risk of loss, but also far out weigh our customers premiums. You've got to do better than
    this, Steve. We're two two days from the proposal meeting. Do NOT fuck this up.

    Put something better together tonight and get it to me in the morning. You're running out of time.

    Jason Harris
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply- (unsent)

    From: Steve Perkins
    To: Jason Harris
    Sent: Tuesday, 5:00pm
    Subject: RE: No good

    Dear Mr. Harris,

    Sir, I have to disagree. I feel that these plans are essential for our customers. If you'd just
    look over the papers I sent you about the
}
{PLAYER.day=4?
    From: Jason Harris
    To: Steve Perkins
    Sent: Wednesday, 4:27pm
    Subject: (Subject)

    Steve, our clients are going to be here tomorrow whether you're ready or not. You're going to need
    to push harder. I don't care what you have to do to put this thing together, just get it done.

    Bring me what you have in the morning.

    Jason Harris
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    From: Henry Thorne
    To: Steve Perkins
    Sent: Thursday, 5:45am
    Subject: Today?

    Hey Steve,
    I'm in the city today and I haven't heard back from you. I'm sure you're busy, but it would 
    really be nice to see you while I'm down. My plane leaves tomorrow, so today is probably it. You 
    can call me at my old number if you get this in time and we can plan something out. It hasn't 
    changed.

    Hope to talk to you soon.
}
{PLAYER.day=5?
    From: Jason Harris
    To: Steve Perkins
    Sent: Friday, 6:00am
    Subject: where the hell are you?

    I want to run through the presentation once before the clients are here.
    Get your ass down here right away.

    Jason Harris
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    From: Janice Franz
    To: Steve Perkins
    Sent: Friday, 6:09am
    Subject: RE: Job Opportunity

    Hi Steve!

    Hope you're having a great day!  I didn't hear back from you.  I just wanted to reach out to you
    one more time to set up a quick chat.  How's Tuesday morning next week?  Let me know either
    way.  I'm excited to talk to you!

    Have a wonderful weekend.
    
    Janis Franz
    Assistant Director
    Embrace Insurance
}
"""
        |> content__________________________________ "coffeeCartMonday" """
{Carl runs the little coffee stand at my local station.  The coffee is decent, and it's nice to see his smiling face each morning.

"Morning, Carl! Can I just get the usual?"

"Sure thing, Steve. That'll be a buck twenty five."

"Here you go, Carl, exact change. Thanks. Have a good one."
|"See you tomorrow."|"See you tomorrow."|"Don't miss your train."}
"""
        |> content__________________________________ "coffeeCartTuesday" """
{"The usual for you today, Steve?"

"Yes please."

"Enjoy."
|"Need anything else?"

"No, I'm fine."}
"""
        |> content__________________________________ "coffeeCartWednesday" """
{"Morning Steve.  You alright?"

"Fill it up to the top, Carl. I'm going to need every last drop today."

"You got it.  Take it easy Steve. Don't want to work too hard."

"Easy for you to say, Carl. But I'll try. Thanks!"
|I've got plenty already, and plenty of work to do too.}
"""
        |> content__________________________________ "coffeeCartThursday" """
{Instead of Carl, there's some young lady behind the stand, looking at her phone.
---
"You're not Carl."

"Nope. Was called in last minute. Guess his wife just went into labor or somethin'. Can I get you anything?"

"Carl's married?"

"Guess so,  I don't know the guy. You getting something or not?"

"Sure. Coffee. Black."

"Here you go. See ya."
|I miss Carl.}
"""
        |> content__________________________________ "coffeeCartFriday" """
Huh, that's strange.  It's closed.  I really need my coffee.  Today of all days!
"""
        |> content__________________________________ "COFFEE_CART" """
It's closed. I hope Carl comes back.
"""
        |> content__________________________________ "LOUD_PAYPHONE_LADY" """
{
"I've been here for 30 damn minutes!  When the hell are you going to help me out?!"
---
She sure seems upset.
---
"HOW THE FUCK ARE YOU GOING TO CALL ME BACK?! I'M ON A FUCKING PAYPHONE, YOU IDIOT!"
---
Wow, you'd think people would try to take care of these matters at home. Yeesh.
|
I want to stay very far away from her.
}
"""
        |> content__________________________________ "SODA_MACHINE" """
I wonder how long the cans have been in that old thing?
"""
        |> content__________________________________ "sodaMachineBroken" """
{An "Out of Order" sign is stuck to the front.  This thing has been broken since I moved here.

Not that I've had a real hankering for a soda, but it's just kind of annoying.
|
It's out of order.
}
"""
        |> content__________________________________ "sodaMachineFixed" """
Wow, the "Out of Order" sign is gone. Did they actually fix it?
"""
        |> content__________________________________ "get_caffeinated_plot_1" """
{The "Out of Order" sign is gone. Maybe it will work?

Since I can't get my coffee, I might as well get my caffeine fix from somewhere.
---
Great, the button doesn't work and it's not giving my change back. Damn.
|
The "Out of Order" sign might be gone, but I know better.
}
"""
        |> content__________________________________ "get_caffeinated_plot_2" """
{This thing stole my quarters.  I want my soda!

I know it's dumb, but I kick the machine so hard my foot hurts.
---
OK, calm down Steve.  The hard part is done, just focus on the getting to work.
---
Wait, I think I hear something...
---
A soda dropped out!  Yes!

Ugh, this tastes disgusting.  How long has it been in there?
}
"""
        |> content__________________________________ "get_caffeinated_plot_achievement" """
_Achievement unlocked:_  
Get caffeinated
"""
        |> content__________________________________ "get_caffeinated_plot_3" """
No thank you.
"""
        |> content__________________________________ "TRASH_DIGGER" """
{"Spare some change?"
---
I've seen that guy almost every day for years.  He always asks for money.  I used to give him some, but eventually stopped.  I work very hard to make a living.
|
He's still at it.  Wonder what he thinks he'll find.
}
"""
        |> content__________________________________ "BENCH_BUM" """
{Some college kid is sprawled out across the whole bench. I wished he'd move. I'd like to just sit down.
---
"Hi there. Could you sit up please? I'd like to sit while I wait for my train."
---
He just ignores me.  Maybe he didn't hear me?
|
"Hey!  I'd like to sit down, please."
---
"Fuck off... I.. arghhh..."
---
He must be drunk.  I don't think he's getting up.
|
I guess I'm standing.
}
"""
        |> content__________________________________ "firstMeetSkaterDude" """
I've seen this young punk before, riding his skateboard up and down the platform.  He almost ran into me once.  The signs clearly say "No skateboarding allowed."
---
Oh great, now he's jumping the turnstile.  He probably doesn't even have a ticket.  You know, we've got rules for a reason.  When people like him disrespect them, it's the rest of us who have to pay.
"""
        |> content__________________________________ "notGoingToWork" """
 { That's not my station. |}I have to go to {the office|work}{ at Broadway Street Station|}.
 """
        |> content__________________________________ "forcePlayerToReadEmails" """
{I have a few minutes before my train arrives.  I could check my emails while I wait.|It's kind of my routine to reread my emails before heading in.}
"""
        |> content__________________________________ "endMonday" """
I'm curious what my boss has in mind for this proposal.  It's nice he thought of me.  Maybe this will finally get me the promotion he's been promising.
"""
        |> content__________________________________ "endTuesday" """
It's going to be tough getting this proposal put together by Friday, but I've got to do it.  I just wish I had more time to make it good.
---
Also, It would be great to see Henry again. I've got to remember to get back to him.  
"""
        |> content__________________________________ "endWednesday" """
This train is two minutes late again.  This is becoming more and more of a problem lately.  They've got to do something about it.
---
I'm not looking forward to talking to Mr. Harris this morning.  This proposal is going to be a disaster.  Figures I get stuck with it.
---
But I've got to make it work.
"""
        |> content__________________________________ "endThursday" """
I'm so tired.  I've been up all night working on this damn proposal, and there's still a lot more work to be done. I hope Mr. Harris appreciates it.
"""
        |> content__________________________________ "fallAsleep" """
Today's the day.  I busted my ass, but I think it will work.  I better get my damn promotion.

I just wish I wasn't so tired.
---
Three more stops. Maybe I can steal a wink or two before I get to the station. I'll just close my eyes for a minute.
---
...
---
"Sir. Sir!"
---
Whoa... what?  What's going on?

A janitor is shaking my shoulder.

"We're almost at the end of the line, sir. You have to wake up."
---
End of the line?

Shit, I feel asleep!  I missed my stop!  What station is this?

Oh my God, I'm in so much trouble!  I have to get back to my stop.
"""


chapter1 : Dict String String
chapter1 =
    Dict.empty
        |> content__________________________________ "MAINTENANCE_MAN" """
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
        |> content__________________________________ "MUSICIAN" """
He's playing an old cracked violin with a hat out in front of him for spare change.

The music sounds nice, but I wouldn't call that a real job.
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

"Excuse me, officers? I--"

They cut me off mid sentence.
---
"This exit is closed sir. There's an incident going on above ground and we're not letting anyone through 'till we get the all clear. You will have to wait like all the others."
---
"But I work up there! I'm going to be late if I don't--"

Again they cut me off.
|}
"If you are unable to wait, take the train to the next stop and walk from there."

"But I--"

"Have a nice day sir."
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
END OF DEMO!  Thank you for playing.
"""
        |> content__________________________________ "SECURITY_DEPOT_SPRING_HILL_STATION" """
END OF DEMO!  Thank you for playing.
"""
