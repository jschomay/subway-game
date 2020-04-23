module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, initialWorldModel)

import Dict exposing (Dict)
import NarrativeContent exposing (t)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Syntax.EntityParser exposing (..)
import NarrativeEngine.Syntax.Helpers exposing (..)
import Subway exposing (Station)


type alias DisplayComponent a =
    { a | name : String }


type alias ExtraFields =
    DisplayComponent {}


type alias Entity =
    NarrativeComponent ExtraFields


type alias WorldModel =
    Dict ID Entity


type alias ID =
    String


initialWorldModel : Result ParseErrors WorldModel
initialWorldModel =
    parseMany addExtraFields entities


{-| This is the `ExtendFn a` function for the parser to "merge in" the extra fields (name).
-}
addExtraFields : ExtraFields -> NarrativeComponent {} -> Entity
addExtraFields { name } { tags, stats, links } =
    { tags = tags
    , stats = stats
    , links = links
    , name = name
    }


{-| A simple helper to easily define entities that builds the extra fiields record.
-}
entity : String -> String -> ( String, ExtraFields )
entity entityString name =
    ( entityString, { name = name } )


entities : List ( String, ExtraFields )
entities =
    [ entity "PLAYER.chapter=0.day=1.location=EAST_MULBERRY.destination=BROADWAY_STREET"
        "Steve"

    -- inventory options
    , entity "BRIEFCASE.item.location=PLAYER"
        "Briefcase"
    , entity "RED_LINE_PASS.pass.item.location=PLAYER.valid_on=RED_LINE"
        "Red Line metro pass"
    , entity "ORANGE_LINE_PASS.pass.item.valid_on=ORANGE_LINE"
        "Orange Line metro pass"
    , entity "CELL_PHONE.item.location=PLAYER.new"
        "Cell phone"
    , entity "MAP.item.map.silent"
        "Subway map"
    , entity "NOTEBOOK.item.new"
        "I keep track of my daily plans in this."
    , entity "DOLLAR_BILL.item.location=offscreen"
        "Dollar bill"
    , entity "CHANGE.item.location=offscreen.amount=0"
        "Loose change"
    , entity "SODA.item.location=offscreen"
        "Soda"

    -- other locations
    , entity "CENTRAL_GUARD_OFFICE.location"
        "Central Guard Office"
    , entity "LOBBY.location"
        "Station Lobby"

    -- offscreen
    , entity "COFFEE.item.location=offscreen"
        "Coffee"
    , entity "TRASH_DIGGER.character.location=offscreen"
        "Man digging in the trash"
    , entity "SKATER_DUDE.character.location=offscreen"
        "Skater dude"
    , entity "BENCH_BUM.character.location=offscreen"
        "Guy sleeping on a bench"

    -- EAST_MULBERRY
    , entity "COFFEE_CART.character.location=EAST_MULBERRY"
        "Coffee cart"
    , entity "COMMUTER_1.character.location=EAST_MULBERRY"
        "Woman in a maroon jacket"
    , entity "LOUD_PAYPHONE_LADY.character.location=EAST_MULBERRY"
        "Loud woman on payphone"
    , entity "GRAFFITI.item.location=EAST_MULBERRY"
        "Graffiti on the wall"
    , entity "SODA_MACHINE.item.broken.location=EAST_MULBERRY"
        "Soda vending machine"

    -- WEST_MULBERRY
    , entity "SOGGY_JACKET.item.location=WEST_MULBERRY"
        "Soggy looking jacket"
    , entity "BULLETIN_BOARD.item.location=WEST_MULBERRY"
        "Bulletin board"
    , entity "TRASH_CAN_WEST_MULBERRY.item.location=WEST_MULBERRY"
        "Trash can"
    , entity "DRINKING_FOUNTAIN.item.location=WEST_MULBERRY"
        "Rusty drinking fountain"

    -- CHURCH_STREET
    , entity "WOMAN_IN_ODD_HAT.character.location=CHURCH_STREET"
        "A woman with an odd hat"
    , entity "SCHOOL_CHILDREN.character.location=CHURCH_STREET"
        "A group of school children"
    , entity "MOTHER.character.screaming_child_quest=0.location=CHURCH_STREET"
        "Mother and child"
    , entity "MISSIONARIES.character.location=CHURCH_STREET"
        "Missionaries"

    --  TWIN_BROOKS
    , entity "SAFETY_WARNING_POSTER.item.location=TWIN_BROOKS"
        "Safety message poster"
    , entity "MAP_POSTER.item.map.location=TWIN_BROOKS"
        "Map on the wall"
    , entity "MAINTENANCE_MAN.character.location=TWIN_BROOKS"
        "Maintenance man"

    --  BROADWAY_STREET
    , entity "EXIT.item.location=BROADWAY_STREET"
        "Exit"
    , entity "SECURITY_OFFICERS.character.location=BROADWAY_STREET"
        "Security officers"
    , entity "ANGRY_CROWD.character.location=BROADWAY_STREET"
        "A large crowd of people"
    , entity "GIRL_IN_YELLOW.character.location=BROADWAY_STREET"
        "Girl in yellow"

    -- CONVENTION_CENTER
    , entity "MUSICIAN.character.location=CONVENTION_CENTER"
        "Man playing violin"
    , entity "MAN_IN_RATTY_HAT.character.location=CONVENTION_CENTER"
        "Man in a ratty brown hat"
    , entity "BROKEN_PAYPHONE.item.location=CONVENTION_CENTER"
        "Broken payphone"
    , entity "BUSTLING_CROWD.character.location=CONVENTION_CENTER"
        "Bustling crowds of people"
    , entity "MARCYS_PIZZA.item.fixed.location=CONVENTION_CENTER"
        "Marcy's Pizza"

    -- SPRING HILL
    , entity "SECURITY_DEPOT_SPRING_HILL_STATION.item.location=SPRING_HILL"
        "Security Depot"

    -- CAPITOL_HEIGHTS
    , entity "TRASH_CAN_CAPITOL_HEIGHTS.item.location=CAPITOL_HEIGHTS"
        "Trash can"
    , entity "ODD_KEY.item"
        "Odd key"
    , entity "SHIFTY_MAN.character.location=CAPITOL_HEIGHTS"
        "Shifty looking man"
    , entity "MARK.character.location=CAPITOL_HEIGHTS"
        "{PLAYER.find_briefcase>2?Mark|Guy with cardboard sign}"
    , entity "SPIKY_HAIR_GUY.character.location=CAPITOL_HEIGHTS"
        "Guy with Spiky Hair"
    , entity "GREEN_SUIT_MAN.character.location=CAPITOL_HEIGHTS"
        "Man in a fancy green suit"

    -- SEVENTY_THIRD_STREET
    , entity "BROOM_CLOSET.item.location=SEVENTY_THIRD_STREET"
        "Broom closet"
    , entity "DISTRESSED_WOMAN.character.location=SEVENTY_THIRD_STREET"
        "Woman in a Pink Poncho"
    , entity "PAYPHONE_SEVENTY_THIRD_STREET.item.location=SEVENTY_THIRD_STREET"
        "Payphone"
    , entity "TRASH_CAN_THIRD_STREET.item.location=SEVENTY_THIRD_STREET"
        "Trash can"
    , entity "BUSINESS_MAN.character.location=SEVENTY_THIRD_STREET"
        "Slick Looking Business Man"

    -- CENTRAL_GUARD_OFFICE
    , entity "TICKET_INSPECTOR.character.location=CENTRAL_GUARD_OFFICE"
        "Ticket inspector"
    , entity "INFRACTIONS_INSTRUCTIONS_POSTER.item"
        "\"Infractions Instructions\" poster"
    , entity "INFRACTIONS_COMPUTER.item"
        "Computer"
    , entity "INFRACTIONS_PRINTER.item"
        "Printer"
    , entity "INFRACTIONS_GREEN_BUTTON.item"
        "Green button"
    , entity "INFRACTIONS_ROOM_DOOR.item"
        "Solid door"
    , entity "INFRACTIONS_CARD_READER.item"
        "Card reader"
    , entity "GRIZZLED_SECURITY_GUARD.character"
        "Grizzled security guard"

    -- Stations
    , entity "ONE_HUNDRED_FORTH_STREET.station" "104th Street"
    , entity "FORTY_SECOND_STREET.station" "42nd Street"
    , entity "SEVENTY_THIRD_STREET.station" "73rd Street"
    , entity "BROADWAY_STREET.station" "Broadway Street"
    , entity "BURLINGTON.station" "Burlington"
    , entity "CAPITOL_HEIGHTS.station" "Capitol Heights"
    , entity "CHURCH_STREET.station" "Church Street"
    , entity "CONVENTION_CENTER.station" "Convention Center"
    , entity "EAST_MULBERRY.station" "East Mulberry"
    , entity "FAIRVIEW.station" "Fairview"
    , entity "HIGHLAND.station" "Highland"
    , entity "IRIS_LAKE.station" "Iris Lake"
    , entity "MACARTHURS_PARK.station" "MacArthur's Park"
    , entity "MUSEUM.station" "Museum"
    , entity "NORWOOD.station" "Norwood"
    , entity "PARK_AVE.station" "Park Street"
    , entity "RIVERSIDE.station" "Riverside"
    , entity "SAMUAL_STREET.station" "Samual Street"
    , entity "SPRING_HILL.station" "Spring Hill"
    , entity "ST_MARKS.station" "St. Mark's"
    , entity "TWIN_BROOKS.station" "Twin Brooks"
    , entity "UNIVERSITY.station" "University"
    , entity "WALTER_HILL.station" "Walter Hill"
    , entity "WESTGATE.station" "Westgate"
    , entity "WEST_MULBERRY.station" "West Mulberry"

    -- Lines
    , entity "RED_LINE.line" "Red line"
    , entity "YELLOW_LINE.line" "Yellow line"
    , entity "GREEN_LINE.line" "Green line"
    , entity "ORANGE_LINE.line" "Orange line"
    , entity "BLUE_LINE.line" "Blue line"
    , entity "PURPLE_LINE.line" "Purple line"
    ]



-- lines and stations are easier to build from the data at the moment


lines : List ( String, ExtraFields )
lines =
    Subway.fullMap
        |> List.map Tuple.first
        |> List.map
            (Subway.lineInfo
                >> (\info ->
                        entity (info.id ++ ".line") info.name
                   )
            )
