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
        , test "parses the whole thing (extra after id)" <|
            \() ->
                shouldFail "has extra chars after id"
                    -- `;` isn't a valid prop char
                    (parseEntity "CAVE_ENTRANCE;drop table")
        , test "parses the whole thing (extra after prop)" <|
            \() ->
                shouldFail "has extra chars after prop"
                    -- `;` isn't a valid prop char
                    (parseEntity "CAVE_ENTRANCE.location;drop table")
        , test "spaces in id not allowed" <|
            \() ->
                shouldFail "can't use spaces"
                    (parseEntity "CAVE ENTRANCE")
        , test "spaces in prop not allowed" <|
            \() ->
                shouldFail "can't use spaces"
                    (parseEntity "CAVE_ENTRANCE.is dark")
        , test "with one tag" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> tag "location"
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.location")
        , test "with multiple tags" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> tag "location"
                        |> tag "dark"
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.location.dark")
        , test "with one stat" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> stat "illumination" 4
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.illumination=4")
        , test "with one negative stat" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> stat "illumination" -4
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.illumination=-4")
        , test "improper stat" <|
            \() ->
                shouldFail "improper stat (char after int)"
                    (parseEntity "CAVE_ENTRANCE.illumination=4x")
        , test "tag followed by stat" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> stat "illumination" 4
                        |> tag "scary"
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.scary.illumination=4")
        , test "stat followed by tag" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> stat "illumination" 4
                        |> tag "scary"
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.illumination=4.scary")
        , test "multiple stats" <|
            \() ->
                Expect.equal
                    (makeEntity "CAVE_ENTRANCE"
                        |> stat "illumination" 4
                        |> stat "temp" 32
                        |> Ok
                    )
                    (parseEntity "CAVE_ENTRANCE.illumination=4.temp=32")
        , test "with one link" <|
            \() ->
                Expect.equal
                    (makeEntity "GOBLIN"
                        |> link "location" "CAVE"
                        |> Ok
                    )
                    (parseEntity "GOBLIN.location=CAVE")
        , test "all together" <|
            \() ->
                Expect.equal
                    (makeEntity "BAG_OF_GOLD"
                        |> tag "item"
                        |> tag "quest_item"
                        |> stat "value" 99
                        |> link "location" "CAVE"
                        |> link "guarded_by" "GOBLIN"
                        |> Ok
                    )
                    (parseEntity "BAG_OF_GOLD.item.quest_item.value=99.location=CAVE.guarded_by=GOBLIN")
        , test "spaced out" <|
            \() ->
                Expect.equal
                    (makeEntity "BAG_OF_GOLD"
                        |> tag "item"
                        |> stat "value" 99
                        |> link "location" "CAVE"
                        |> Ok
                    )
                    (parseEntity "BAG_OF_GOLD      .item  .value=99  .location=CAVE")
        , test "multi line" <|
            \() ->
                Expect.equal
                    (makeEntity "BAG_OF_GOLD"
                        |> tag "item"
                        |> stat "value" 99
                        |> link "location" "CAVE"
                        |> Ok
                    )
                    (parseEntity
                        """BAG_OF_GOLD
                                .item
                                .value=99
                                .location=CAVE"""
                    )
        , todo "ids cannot start with ints"

        -- location=1st_base - should be link, but will be an error (because 1 int
        -- parse matches, unless I make it backtrackable)
        -- location=2 - cannot tell if this is a stat or link, would be
        -- parsed as a stat
        -- remember to test $ in changes and conditionals
        ]


shouldFail message res =
    case res of
        Err _ ->
            Expect.pass

        _ ->
            Expect.fail message



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

   // trigger match in conditional
   trigger: *.location
   conditions: *.enemy.location=$
   narrative: The {$.name} is too dangerous to enter now...
   // note, there is no way to reference the name/description of the enemy matcher


   // moving around
   trigger: *.location
   changes: PLAYER.location=$

   // picking stuff up
   trigger: *.item.!location=PLAYER
   changes: $.location=PLAYER
   narrative: This might be useful.

   nested (PLAYER.location=(*.dark))
-}
