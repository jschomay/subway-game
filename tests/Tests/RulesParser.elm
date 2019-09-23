module Tests.RulesParser exposing (all)

import Expect
import Narrative.WorldModel exposing (..)
import Result
import Rules.Parser exposing (parseEntity, parseMatcher)
import Test exposing (..)


all =
    describe "parsing narrative"
        [ worldDefinition
        , matchers
        ]


makeEntity id =
    ( id
    , { tags = emptyTags
      , stats = emptyStats
      , links = emptyLinks
      }
    )


{-| WORLD DEFINITION

CAVE\_ENTRANCE.location
CAVE.location.dark

GOBLIN.character.sleeping.location=CAVE

PLAYER
.character
.fear=0
.treasure\_hunt\_plot=1
.location=CAVE\_ENTRANCE

LIGHTER.item.illumination=2.location=PLAYER
TORCH.item.illumination=7.location=CAVE\_ENTRANCE
BAG\_OF\_GOLD.item.quest\_item.location=CAVE.guarded\_by=GOBLIN

-}
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
        , test "ids cannot start with ints" <|
            \() ->
                shouldFail "should fail because starts with int"
                    (parseEntity "1ST_BASE.location")
        , test "ids cannot start with ints (in links)" <|
            \() ->
                shouldFail "should fail because starts with int"
                    (parseEntity "PLAYER.location=1ST_BASE")
        , test "single letter id ok" <|
            \() ->
                Expect.equal
                    (makeEntity "A" |> Ok)
                    (parseEntity "A")
        ]


{-| Matchers

TODO:

-- not
CAVE.!dark
PLAYER.!fear>9
PLAYER.!location=CAVE

-- reciprocal links (might not work in engine currently
trigger: _.seeking->(_.avoiding->$)

-- trigger matching (keeps "$")
PLAYER.location=$

-- multiline
PLAYER
.location=(\*.dark)
.fear>2
.!blinded

-}
matchers =
    describe "matchers"
        [ test "any" <|
            \() ->
                Expect.equal
                    (Ok <| MatchAny [])
                    (parseMatcher "*")
        , test "id" <|
            \() ->
                Expect.equal
                    (Ok <| Match "cave" [])
                    (parseMatcher "cave")
        , test "uses full input" <|
            \() ->
                shouldFail "didn't parse full input"
                    (parseMatcher "cave asdf*=$")
        , test "tag" <|
            \() ->
                Expect.equal
                    (Ok <| MatchAny [ HasTag "dark" ])
                    (parseMatcher "*.dark")
        , test "stat =" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasStat "fear" EQ 5 ])
                    (parseMatcher "PLAYER.fear=5")
        , test "stat >" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasStat "fear" GT 5 ])
                    (parseMatcher "PLAYER.fear>5")
        , test "stat <" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasStat "fear" LT 5 ])
                    (parseMatcher "PLAYER.fear<5")
        , test "link just id" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasLink "location" (Match "CAVE" []) ])
                    (parseMatcher "PLAYER.location=CAVE")
        , test "link missing parens" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasTag "dark", HasLink "location" (Match "CAVE" []) ])
                    (parseMatcher "PLAYER.location=CAVE.dark")
        , test "link with subquery" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasLink "location" (Match "CAVE" [ HasTag "dark" ]) ])
                    (parseMatcher "PLAYER.location=(CAVE.dark)")
        , test "link with nested subquery" <|
            \() ->
                Expect.equal
                    (Ok <| Match "PLAYER" [ HasLink "location" (Match "CAVE" [ HasTag "dark" ]) ])
                    (parseMatcher "PLAYER.location=(CAVE.dark)")

        -- more nested queries to test
        --     PLAYER.location=(*.dark).blinded -- Player is in anything dark and PLAYER is blinded
        --     PLAYER.location=(*.location.dark) -- Player is in any dark location
        --     PLAYER.location=(*.location.homeTo=GOBLIN) -- Player is in goblins home
        --     PLAYER.location=(*.location.homeTo=(*.enemy)) -- Player is in any enemy location
        , test "all together" <|
            \() ->
                Expect.equal
                    (Ok <|
                        Match "A"
                            [ HasTag "tag3"
                            , HasLink "link2" (Match "C" [])
                            , HasLink "link1" (Match "B" [])
                            , HasStat "stat2" GT 2
                            , HasStat "stat1" EQ 1
                            , HasTag "tag2"
                            , HasTag "tag1"
                            ]
                    )
                    (parseMatcher "A.tag1.tag2.stat1=1.stat2>2.link1=B.link2=C.tag3")
        ]


shouldFail message res =
    case res of
        Err _ ->
            Expect.pass

        _ ->
            Expect.fail message



{-
       Updates

      `Update "Player" [ AddTag "happy" ]`
      `UpdateAll [ HasTag "happy" ] [ RemoveTag "happy" ]`


      "PLAYER.happy"
      "(*.happy).-happy" // kind of annoying, but can't think of another way

   --  updates
   CAVE.explored
   GOBLIN.-sleeping
   PLAYER.location=CAVE
   PLAYER.fear=9
   PLAYER.fear-1

   -- generic
   CAVE.explored -- shortcut
   (CAVE).explored -- same
   (\*.suspect).-suspect -- clears suspect tag from all entities with suspect tag

   -- multiline
   player
   .location=cave
   .fear+2
   .blinded

   -- trigger matching (keeps "$")
   $.explored
   PLAYER.location=$

-}
{-

   ## QUERY exmaples (lists of matching entities)

   // Get a list of all of the locations:

       *.location

   // Get all items in the player's inventory:

       *.item.location=PLAYER

   // Test if the player has any item with enough illumination (if matches is not empty):

       *.item.location=PLAYER.illumination>5

   // Test if any characters in the cave are afraid (if matches is not empty):

       *.character.location=CAVE.fear>5

   // Test if the player is in the cave and afraid (either an empty query results, or the player entity)
   // TODO this requires new matcher based query instead of asset

       PLAYER.location=CAVE.fear>5

   RULES examples

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
