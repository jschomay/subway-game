module NarrativeContent exposing (parseErrors, t)

import Dict exposing (Dict)
import Narrative
import Rules.Parser exposing (ParseError)


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
            case Narrative.parsible emptyConfig v of
                Err e ->
                    ( "Narrative content: " ++ k ++ " " ++ v ++ " ", e ) :: acc

                _ ->
                    acc
        )
        []
        all


content__________________________________ =
    Dict.insert


all : Dict String String
all =
    Dict.empty
        |> content__________________________________ "BRIEFCASE"
            "My portable office, all my work is in it."
        |> content__________________________________ "RED_LINE_PASS"
            "This gets me anywhere on the Red Line, but I really only use it to get to work and back home."
        |> content__________________________________ "COMMUTER_1" """
{Another commuter waiting on the train.  I say hello and she says hello back.
|I think one hello is enough when talking to complete strangers.}
"""
        |> content__________________________________ "GRAFFITI"
            "That's just vulgar.  Why do people have to mess things up?"
        |> content__________________________________ "CELL_PHONE" """
{There's no service, but I can view my emails.
---
|}
{PLAYER.day=1?
    From: Dennis Ferbs
    To: Steve Kerry
    Sent: Sunday, 4:00 pm
    Subject: I've Got a Job for You

    Steve,
    Just got word that some very important clients are coming in in the next few weeks.
    The boys up stairs want me to put together a new proposal to bring to them. 
    Steve, you're one of our senior agents and you've been in the department for, what, 6 years?
    I need you to work on this and really make it shine.
    Be at my office at 6:30 am Monday and we can talk over the details.

    Dennis Ferbs
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply -

    From: Steve Kerry
    To: Dennis Ferbs
    Sent: Sunday, 4:01 pm
    Subject: RE: I've Got a Job for You
    
    Dear Mr. Ferbs,
    I've actually been with the company for eight years, but no need to worry, sir. I'm happy for the 
    opportunity. I've got a few big ideas that I've been wanting to try out.
    I'll be there bright and early, sir.
    
    Steve Kerry
    Insurance Agent
    In Your Hands Insurance
---
    From: Janice Franz
    To: Steve Kerry
    Sent: Monday, 6:05am
    Subject: Job Opportunity
    
    Hi Mr. Steve Kerry

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
    From: Dennis Ferbs
    To: Steve Kerry
    Sent: Monday, 6:26pm
    Subject: Good Things!

    Steve,

    I like a few of the ideas that you brought to me this morning.  But I just got word that our clients are
    pushing up the meeting and will be here on Friday! You're going to have to put this thing in high gear, Steve.
    I can't hand them half assed work.

    Don't let me down.

    Dennis Ferbs
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply-

    From: Steve Kerry
    To: Dennis Ferbs
    Sent: Monday, 6:32pm
    Subject: RE: Good Things!

    Dear Mr. Ferbs,

    Thank you for the update.  I'll do my best, but Friday is a little soon isn't it? I just want to be able to
    put together something that will really help our customers.  I'll have to cut a lot of the ideas we spoke about.
    But I'll do my best, sir.

    See you tomorrow, Mr. Ferbs

    Steve Kerry
    Insurance Agent
    In Your Hands Insurance
---
    From: Henry Thorne
    To: Steve Kerry
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

    From: Dennis Ferbs
    To: Steve Kerry
    Sent: Tuesday, 4:48pm
    Subject: No good

    Steve,

    What you handed me today WON'T work. The Premiums we offer will NOT cover these plans. Half of these
    seem like life quality expenses. We need to think about the bottom dollar here, Steve. "Pet Insurance
    Plan", "Kidnap/Ransom Insurance", "Divorce Insurance"? These benefits not only expose us to
    unwarranted risk of loss, but also far out weigh our customers premiums. You've got to do better than
    this, Steve. We're two two days from the proposal meeting. Do NOT fuck this up.

    Put something better together tonight and get it to me in the morning. You're running out of time.

    Dennis Ferbs
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    -Reply- (unsent)

    From: Steve Kerry
    To: Dennis Ferbs
    Sent: Tuesday, 5:00pm
    Subject: RE: No good

    Dear Mr. Ferbs,

    Sir, I have to disagree. I feel that these plans are essential for our customers. If you'd just
    look over the papers I sent you about the
}
{PLAYER.day=4?
    From: Dennis Ferbs
    To: Steve Kerry
    Sent: Wednesday, 4:27pm
    Subject: (Subject)

    Steve, our clients are going to be here tomorrow whether you're ready or not. You're going to need
    to push harder. I don't care what you have to do to put this thing together, just get it done.

    Bring me what you have in the morning.

    Dennis Ferbs
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    From: Henry Thorne
    To: Steve Kerry
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
    From: Dennis Ferbs
    To: Steve Kerry
    Sent: Friday, 6:00am
    Subject: where the hell are you?

    I want to run through the presentation once before the clients are here.
    Get your ass down here right away.

    Dennis Ferbs
    District Sales Manager
    In Your Hands Insurance, Inc.  All rights reserved.
---
    From: Janice Franz
    To: Steve Kerry
    Sent: Friday, 6:09am
    Subject: RE: Job Opportunity

    Hi Steve!

    Hope you're having a great day!  I just wanted to reach out to you one more time to set up a 
    quick chat.  How's Tuesday morning next week?  Let me know either way.  I'm excited to talk
    to you!

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
{Huh, that's strange. |}It's closed.{  I really need my coffee.  Today of all days!|  I wonder where Carl is?|  I hope Carl comes back.|}
"""
        |> content__________________________________ "COFFEE" """
{PLAYER.day=1?  Carl's Coffee has been fueling me for years. Can't imagine surviving a Monday without it.}
{PLAYER.day=2?  Mmm, that's good coffee.}
{PLAYER.day=3?  I'm going to need a barrel of this if I'm going to get this proposal done by Friday. What is Mr. Ferbs thinking?  }
{PLAYER.day=4?  It tastes bitter.}
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
        |> content__________________________________ "TRASH_DIGGER" """
{"Spare some change?"
---
I've seen that guy almost every day for years.  He always asks for money.  I used to give him some, but eventually stopped.  I work very hard to make a living.
|
He's still at it.  Wonder what he thinks he'll find.
}
"""
        |> content__________________________________ "firstMeetSkaterDude" """
I've seen this young punk before, riding his skateboard up and down the platform.  He almost ran into me once.  The signs clearly say "No skateboarding allowed."
---
Oh great, now he's jumping the turnstile.  He probably doesn't even have a ticket.  You know, we've got rules for a reason.  When people like him disrespect them, it's the rest of us who have to pay.
"""
        |> content__________________________________ "SAFETY_WARNING_POSTER"
            "It says to watch out for pickpockets and report any suspicious activity."
