module Constants exposing (scenes)

{-| Constants for the entities, stats, scenes, etc used in the manifest and rules. Created as a record to get some compiletime type checking on the otherwise string/int ids/values.
-}


scenes =
    { intro = 1
    , lostBriefcase = 2
    , wildGooseChase = 3
    , endOfDemo = 4
    }
