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
    , entity "mapPoster"
    ]


characters : List Entity
characters =
    [ entity "ticketCollector"
    , entity "skaterDude"
    ]


locations : List Entity
locations =
    [ entity "train"
    , entity "platform"
    ]
