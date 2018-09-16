module Manifest exposing (characters, items, locations)

import Components exposing (..)



{- Here is where you define your manifest -- all of the items, characters, and locations in your story. You can add what ever components you wish to each entity.  Note that the first argument to `entity` is the id for that entity, which is the id you must refer to in your rules.
   In the current theme, the description in the display info component is only used as a fallback narrative if a rule does not match with a more specific narrative when interacting with that story object.
-}


items : List Entity
items =
    [ entity "map"
    ]


characters : List Entity
characters =
    [ entity "Steve"
    ]


locations : List Entity
locations =
    [ entity "train"
    , entity "platform"
    ]
