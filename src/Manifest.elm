module Manifest exposing (characters, findEntity, items, locations)

import Components exposing (..)


findEntity : String -> Entity
findEntity id =
    (items ++ locations ++ characters)
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (Components.entity id)



{- Here is where you define your manifest -- all of the items, characters, and locations in your story. You can add what ever components you wish to each entity.  Note that the first argument to `entity` is the id for that entity, which is the id you must refer to in your rules.
   In the current theme, the description in the display info component is only used as a fallback narrative if a rule does not match with a more specific narrative when interacting with that story object.
-}


items : List Entity
items =
    [ entity "briefcase"
        |> addDisplayInfo "Briefcase" "The tool of your trade, perfectly organized, and always by your side.  It has papers, pencils, but most importantly, the hard copy of your presentation."
    , entity "redLinePass"
        |> addDisplayInfo "Red Line pass" "This will get you to any station along the Red Line.  Expires in 8 months."
    , entity "safteyWarningPoster"
        |> addDisplayInfo "Safety Message Poster" "A poster that warns you to watch out for pickpockets and report any suspicious activity. "
    , entity "mapPoster"
        |> addDisplayInfo "Map on the wall" "This shows the full map of the subway system."
    , entity "cellPhone"
        |> addDisplayInfo "Cellphone" "It's not one of those $800 ones, but it does everything you need.  Unless there's no service.  Down here there's no service, so it's practically useless.."
        , entity "policeOffice" 
        |> addDisplayInfo "Police Office" "It's not much help when it's closed."
        , entity "ticketMachine"
        |> addDisplayInfo "Ticket Machine" "You can buy tickets and passes here.  You reach for your wallet, but realize you left it in your briefcase!  It won't help you without money."
    ]


characters : List Entity
characters =
    [ entity "securityGuard"
        |> addDisplayInfo "Security Guard" "He's probably busy, you don't really have any reason to bother him."
    , entity "ticketInspector"
        |> addDisplayInfo "Ticket inspector" "Ticket inspectors aren't really the nicest people to associate with.  Unless you have a good reason to talk to him, you'd rather keep your distance."
    , entity "largeCrowd"
        |> addDisplayInfo "A large crowd" "They ignore you for the most part, occupied with the situation at hand."
    , entity "securityOfficers"
        |> addDisplayInfo "Security officers" "Two of them, looking official, but not really all that helpful over all."
    ]


{-| The locations are mostly handled through the main code, and are the different stations. The train is hard coded as a psudo-location, it never actually ends up in `currentLocation` -}
locations : List Entity
locations =
    [ entity "train"
        |> addDisplayInfo "Train car" "The train hurtles through the dark tunnel towards the next stop."
    ]
