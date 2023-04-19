module NarrativeContent exposing (parseAll, t)

import Dict exposing (Dict)
import NarrativeContent.Chapter1 as Chapter1
import NarrativeContent.Chapter2 as Chapter2
import NarrativeContent.General as General
import NarrativeContent.Quests as Quests
import NarrativeEngine.Syntax.Helpers exposing (ParseErrors)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser


{-| This is a little nicer than having to export every string.
NOTE this could be used for i18n too kind of
-}
t : String -> String
t key =
    Dict.get key all
        |> Maybe.withDefault ("ERROR: can't find content for key " ++ key)


{-| Pre-parses everything at run time to find errors to display.
-}
parseAll : Result ParseErrors ()
parseAll =
    NarrativeParser.parseMany all


all : Dict String String
all =
    List.foldl Dict.union
        Dict.empty
        [ silent
        , Quests.content
        , achievements
        , intro
        , Chapter1.content
        , Chapter2.content
        , General.content
        ]


content__________________________________ =
    Dict.insert


{-| rules that shouldn't show any text
-}
silent : Dict String String
silent =
    Dict.empty
        |> content__________________________________ "nextDay" ""
        |> content__________________________________ "goToLobby" ""
        |> content__________________________________ "goToLineTurnstile" ""
        |> content__________________________________ "goToLinePlatform" ""
        |> content__________________________________ "checkMap" ""
        |> content__________________________________ "ridingTheTrain" ""
        |> content__________________________________ "disembark" ""
        |> content__________________________________ "use_secret_passage_way" ""


achievements : Dict String String
achievements =
    Dict.empty
        |> content__________________________________ "get_caffeinated_quest_achievement" """
_Achievement unlocked:_
Get caffeinated
"""
        |> content__________________________________ "fools_errand_achievement" """
_Achievement unlocked:_
Fool's errand
"""
        |> content__________________________________ "transfer_station" """
_Achievement unlocked:_
Transfer station
"""
        |> content__________________________________ "freedom" """
_Achievement unlocked:_
Free to roam
"""
        |> content__________________________________ "f_the_system" """
_Achievement unlocked:_
F&ast;&ast;&ast; the system
"""


intro : Dict String String
intro =
    Dict.empty
        |> content__________________________________ "title_intro" """
Steve,
---
Steve,

I've got something big for you.
---
Steve,

I've got something big for you.

Come by my office first thing Monday morning.
"""
        |> content__________________________________ "firstInteractionWithCommuter1" """
{Another commuter waiting on the train.  I say hello and she says hello back.
|I think one hello is enough when talking to complete strangers.}
"""
        |> content__________________________________ "checkEmailsDay1" """
{There's no service, but I can view my emails.
---
Email 1

    From: Jason Harris
    To: Steve Kerry
    Sent: Monday, 5:15am
    Subject: I've Got a Job for You

    ---
    Steve,

    I've got something big for you.
    We've landed some important clients. The boys upstairs want you to wow them with a new
    proposal. You're one of our senior agents and you've been in the department for, what, 6 years?

    I'm giving this opportunity to you.  Be at my office at 6:30 am this Monday and we can talk over the details.
---

Reply

    Dear Mr. Harris,

    I've actually been with the company for eight years, but no need to worry, sir. I'm happy to finally
    be given the opportunity to do some real good for the company. I've got a few big ideas that I feel
    could really help our customers in a really big way.

    I'll be there bright and early, sir. I can't wait to start on this project together.

---
Email 2

    From: Janice Franz
    To: Steve Kerry
    Sent: Monday, 6:05am
    Subject: RE: RE: Job Opportunity
---
    Hi Mr. Steve Kerry

    My name is Janis and I'm reaching out on behalf of Embrace Insurance. I came across your resume
    in our system and I believe you would make a perfect fit for our team!
    If you're looking for a change or would simply like to see what options are available, we would
    love to set up a meeting soon!

    We look forward to your response!
|
Still no service, but Mr. Harris is waiting for me at the office.
}
"""
        |> content__________________________________ "checkEmailsDay2" """
{
Email 1

    From: Jason Harris
    To: Steve Kerry
    Sent: Tuesday, 6:10am
    Subject: Good Things!
---
    Steve,

    I liked the ideas that you brought up yesterday. But I got word that the new clients are pushing up
    the meeting to Friday! You're going to have to put this thing in HIGH gear, Steve. I can't hand them
    half assed work.

    Don't let me down.
---
Reply

    Dear Mr. Harris,

    Thanks for the update. But Friday is a little soon isn't it? I just want to put something
    together that will really help our customers. I may have to cut a lot of the ideas we spoke
    about.

    But I'll do my best, sir!

---
Email 2

    From: Henry Thorne
    To: Steve Kerry
    Sent: Tuesday, 6:29am
    Subject: Stevey!
---
    Hey Steve!

    Long time no talk! Just checking in with you and letting you know I'm going to be in the city in a
    few days. It's supposed to be a business trip and it's only for a day, but I thought it's be nice to drop
    by and catch up. I know things have been difficult since we last talked.

    Just let me know when you're free and I'll make something work.

    See you soon!
|
That's all the emails.  How am I supposed to get this done by Friday?
}
"""
        |> content__________________________________ "checkEmailsDay3" """
{
Email 1

    From: Jason Harris
    To: Steve Kerry
    Sent: Wednesday, 5:45am
    Subject: Pure Risk
---
    Steve,

    What you handed me today WON'T work. The Premiums we offer do NOT cover these plans.
    Half of these are life quality expenses. We NEED to think about the bottom dollar here. We're
    two days from the proposal meeting. You've got to do better than this.

    Put something better together today and get it to me by tonight. You're running out of time.

---
Reply (Unsent)

    Dear Mr. Harris,

    Sir, I have to disagree. I feel that these plans are essential for our customers. If you'd just look
    over the papers I sent you about the

---
Reply

    Dear, Mr. Harris

    Yes, sir. I'll make some changes.

|
Have to cut more. Have to work harder. Have to keep moving. This will be worth it. Right?
}
"""
        |> content__________________________________ "checkEmailsDay4" """
{
Email 1

    From: Jason Harris
    To: Steve Kerry
    Sent: Thursday, 4:27am
    Subject: (Subject)
---
    Steve, our clients are going to be here tomorrow whether you're ready or not. You're going to
    need to PUSH HARDER. I don't care what you have to do to put this thing together, just GET IT DONE.

    BRING ME WHAT YOU HAVE ASAP.

---
Email 2

    From: Henry Thorne
    To: Steve Kerry
    Sent: Thursday, 5:45am
    Subject: Today?
---
    Hey, Steve

    I'm in the city today and I haven't heard back from you. I'm sure you're busy, but it would really
    be nice to see you while I'm down. My plane leaves tomorrow, so today is probably it. You can
    call me at my old number if you get this in time and we can plan something out. It hasn't
    changed.

    Hope to talk to you soon.
|
How can Mr Harris ask me to push harder? I'm working my ass off!
}
"""
        |> content__________________________________ "checkEmailsDay5" """
{
Email 1

    From: Jason Harris
    To: Steve Kerry
    Sent: Friday, 5:00am
    Subject: WHERE THE HELL ARE YOU?
---
    I WANT TO RUN THROUGH THE PRESENTATION BEFORE THE CLIENTS GET HERE.
    GET YOUR ASS DOWN HERE RIGHT AWAY!
|
Maybe I should call in sick.
}
"""
        |> content__________________________________ "coffeeCartMonday" """
{Carl runs the little coffee stand at my local station.  The coffee is decent, and it's nice to see his smiling face each morning.
---
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
This is a bad idea...
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
        |> content__________________________________ "get_caffeinated_quest_1" """
{The "Out of Order" sign is gone. Maybe it will work?

Since I can't get my coffee, I might as well get my caffeine fix from somewhere.
---
Great, the button doesn't work and it's not giving my change back. Damn.
|
The "Out of Order" sign might be gone, but I know better.
}
"""
        |> content__________________________________ "get_caffeinated_quest_2" """
{This thing stole my quarters.  I want my soda!

I know it's dumb, but I kick the machine so hard my foot hurts.
---
OK, calm down Steve.  The hard part is done, just focus on the getting to work.
---
Wait, I think I hear something...
---
A soda dropped out!  Yes!
}
"""
        |> content__________________________________ "drink_old_soda" """
Ugh, this tastes disgusting.  How long has it been in there?
"""
        |> content__________________________________ "get_caffeinated_quest_3" """
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
{Some college kid is sprawled out across the whole bench. I wish he'd move. I'd like to just sit down.
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
I'm so tired.  I've been up all night working on this damn proposal, and there's still a lot more work to be done. Mr. Harris better appreciate it.
"""
        |> content__________________________________ "fallAsleep" """
Today's the day.  I busted my ass, but I think it will work.  I better get my damn promotion.

I just wish I wasn't so tired.
---
Two more stops. Maybe I can steal a wink or two before I get to the station. I'll just close my eyes for a minute.
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
