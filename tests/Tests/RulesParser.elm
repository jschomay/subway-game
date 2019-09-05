module Tests.RulesParser exposing (all)

import Expect
import Narrative.WorldModel exposing (..)
import Result
import Rules.Parser exposing (parseEntity)
import Test exposing (..)


all =
    describe "parsing narrative"
        [ worldDefinition
        ]


makeEntity id =
    ( id
    , { tags = emptyTags
      , stats = emptyStats
      , links = emptyLinks
      }
    )


worldDefinition =
    describe "world definition"
        [ test "just id" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE" |> Ok)
                    (parseEntity "CAVE_ENTRANCE")
        , skip <|
            test "does it work with a space in id?" <|
                \() ->
                    Expect.equal
                        (makeEntity "CAVE ENTRANCE" |> Ok)
                        (parseEntity "CAVE ENTRANCE")
        , test "with one tag" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> tag "location"
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.location")
        , todo "with multiple tags"

        -- stats, links
        -- mixed
        -- multi line?
        ]



{- WORLD DEFINITION


   CAVE_ENTRANCE.location
   CAVE.location.dark

   GOBLIN.character.sleeping.location=CAVE
   PLAYER
   .character
   .fear=0
   .treasure_hunt_plot=1
   .location=CAVE_ENTRANCE

   LIGHTER.item.illumination=2.location=PLAYER
   TORCH.item.illumination=7.location=CAVE_ENTRANCE
   BAG_OF_GOLD.item.quest_item.location=CAVE.guarded_by=GOBLIN

-}
{- QUERY
   // Get a list of all of the locations:
   *.location

   // Get all items in the player's inventory:
   *.item.location=PLAYER

   // Test if the player has any item with enough illumination:
   *.item.location=PLAYER.illumination>5

-}
{- RULES

   trigger: CAVE.!explored
   conditions:
   *.item.location=PLAYER.illumination>5
   changes:
   PLAYER.location=CAVE.fear+2
   CAVE.explored
   narrative: You can see a short ways into the cave, and bravely enter.  You hear an awful snoring sound...


   trigger: GOBLIN.sleeping
   changes:
   GOBLIN.-sleeping
   PLAYER.fear=9
   narrative: There's an old saying, "Let sleeping dogs lie."  That applies double when it comes to goblins.  Too late...

   // moving around
   trigger: *.location
   changes: PLAYER.location=$

   // picking stuff up
   trigger: *.item.!location=PLAYER
   changes: $.location=PLAYER
   narrative: This might be useful.

   nested (PLAYER.location=(*.dark))
-}
