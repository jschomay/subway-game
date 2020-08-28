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
    , entity "MISSING_DOG_POSTER_1.item.missing_dog_poster"
        "Missing dog poster"
    , entity "MISSING_DOG_POSTER_2.item.missing_dog_poster"
        "Missing dog poster"
    , entity "MISSING_DOG_POSTER_3.item.missing_dog_poster"
        "Missing dog poster"
    , entity "MISSING_DOG_POSTER_4.item.missing_dog_poster"
        "Missing dog poster"
    , entity "MISSING_DOG_POSTER_5.item.missing_dog_poster"
        "Missing dog poster"

    -- EAST_MULBERRY
    , entity "COFFEE_CART.character.location=EAST_MULBERRY"
        "Coffee cart"
    , entity "COMMUTER_1.character.location=EAST_MULBERRY"
        "Woman in a maroon jacket"
    , entity "LOUD_PAYPHONE_LADY.character.location=EAST_MULBERRY"
        "Loud woman on payphone"
    , entity "GRAFFITI_EAST_MULBERRY.item.location=EAST_MULBERRY"
        "Graffiti on the wall"
    , entity "SODA_MACHINE.item.broken.location=EAST_MULBERRY"
        "Soda vending machine"

    -- WEST_MULBERRY
    , entity "SOGGY_JACKET.item.location=WEST_MULBERRY"
        "Soggy looking jacket"
    , entity "BULLETIN_BOARD.item.location=WEST_MULBERRY"
        "Bulletin board"
    , entity "TRASH_CAN_WEST_MULBERRY.item.trashcan.location=WEST_MULBERRY"
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
    , entity "MAN_IN_HOT_DOG_SUIT.character"
        "Man in a hot dog suit"
    , entity "MASCOT_PAPERS.item"
        "Mascot papers"

    --  BROADWAY_STREET
    , entity "EXIT.item.location=BROADWAY_STREET"
        "Exit"
    , entity "SECURITY_OFFICERS.character.location=BROADWAY_STREET"
        "Security officers"
    , entity "ANGRY_CROWD.character.location=BROADWAY_STREET"
        "A large crowd of people"
    , entity "GIRL_IN_YELLOW.character.location=BROADWAY_STREET"
        "Girl in yellow dress"

    -- CONVENTION_CENTER
    , entity "MUSICIAN.character.location=CONVENTION_CENTER"
        "Man playing violin"
    , entity "MAN_IN_RATTY_HAT.character.location=CONVENTION_CENTER"
        "Man in a ratty brown hat"
    , entity "BUSTLING_CROWD.character.location=CONVENTION_CENTER"
        "Bustling crowds of people"
    , entity "MARCYS_PIZZA.item.fixed.location=CONVENTION_CENTER"
        "Marcy's Pizza"

    -- SPRING HILL
    , entity "SECURITY_DEPOT_SPRING_HILL_STATION.item.location=SPRING_HILL"
        "Security Depot"
    , entity "MISSING_DOG_POSTER_0.item.missing_dog_poster.location=SPRING_HILL"
        "Missing dog poster"
    , entity "OVERTURNED_TRASHCAN.item.location=SPRING_HILL"
        "Overturned trashcan"
    , entity "NEWSPAPER_VENDING_MACHINE.item.location=SPRING_HILL"
        "Newspaper vending machine"
    , entity "CUSTODIAN.character.location=SPRING_HILL"
        "Custodian"

    -- CAPITOL_HEIGHTS
    , entity "TRASH_CAN_CAPITOL_HEIGHTS.item.trashcan.location=CAPITOL_HEIGHTS"
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
    , entity "TROPICAL_T_SHIRT_MAN.character.location=CAPITOL_HEIGHTS"
        "Man in a bright tropical T-shirt"

    -- SEVENTY_THIRD_STREET
    , entity "BROOM_CLOSET.item.location=SEVENTY_THIRD_STREET"
        "Broom closet"
    , entity "DISTRESSED_WOMAN.character.location=SEVENTY_THIRD_STREET"
        "Woman in a pink poncho"
    , entity "PAYPHONE_SEVENTY_THIRD_STREET.item.location=SEVENTY_THIRD_STREET"
        "Payphone"
    , entity "TRASH_CAN_SEVENTY_THIRD_STREET.item.trashcan.location=SEVENTY_THIRD_STREET"
        "Trash can"
    , entity "BUSINESS_MAN.character.location=SEVENTY_THIRD_STREET"
        "Slick looking business man"
    , entity "ABANDONED_JACKET.item.location=SEVENTY_THIRD_STREET"
        "Abandoned jacket"
    , entity "MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET.item.passage_to=FORTY_SECOND_STREET.location=SEVENTY_THIRD_STREET.hidden"
        "Maintenance door"

    -- FORTY_SECOND_STREET
    , entity "MAINTENANCE_DOOR_FORTY_SECOND_STREET_SEVENTY_THIRD_STREET_TO.item.passage_to=SEVENTY_THIRD_STREET.location=FORTY_SECOND_STREET"
        "Maintenance door"
    , entity "GRIZZLED_REPAIRMAN.character.location=FORTY_SECOND_STREET"
        "Grizzled repairman"
    , entity "ELECTRIC_PANEL.item.hidden.location=FORTY_SECOND_STREET"
        "Electric panel"
    , entity "SECURITY_CAMERA_FORTY_SECOND_STREET.item.security_camera.location=FORTY_SECOND_STREET"
        "Security camera"

    -- UNIVERSITY
    , entity "FRANKS_FRANKS.item.fixed.location=UNIVERSITY"
        "Frank's Franks hot dog stand"
    , entity "SECRET_SERVICE_TYPE_GUY.character.location=UNIVERSITY"
        "Man in sunglasses and suit"
    , entity "MAGAZINE_STAND.item.location=UNIVERSITY"
        "Magazine stand"
    , entity "FAKE_COP.character.location=UNIVERSITY"
        "Police officer"
    , entity "ADVERTISEMENT.item.location=UNIVERSITY"
        "Advertisement poster"

    -- ST_MARKS
    , entity "BROKEN_PAYPHONE.item.location=ST_MARKS"
        "Broken payphone"
    , entity "CENTRAL_GUARD_OFFICE_ENTRANCE.item.location=ST_MARKS"
        "Guard Station Entrance"
    , entity "MURAL.item.location=ST_MARKS"
        "Mural"
    , entity "BIRD.item.location=ST_MARKS"
        "A bird!"
    , entity "COMMUTERS_ST_MARKS.character.location=ST_MARKS"
        "Commuters"

    -- ONE_HUNDRED_FORTH_STREET
    , entity "VENDING_MACHINE.item.location=ONE_HUNDRED_FORTH_STREET"
        "Snack machine"
    , entity "CONSTRUCTION_AREA.item.location=ONE_HUNDRED_FORTH_STREET"
        "Roped off area"
    , entity "FLUORESCENT_LIGHTS.item.location=ONE_HUNDRED_FORTH_STREET"
        "Flickering fluorescent lights"
    , entity "TRASH_CAN_ONE_HUNDRED_FOURTH_STREET.item.trashcan.location=ONE_HUNDRED_FORTH_STREET"
        "Trash can"

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

    -- IRIS_LAKE
    , entity "CONCERT_POSTER.item.location=IRIS_LAKE"
        "Poster"
    , entity "GRAFFITI_IRIS_LAKE.item.location=IRIS_LAKE"
        "Graffiti"
    , entity "MAINTENANCE_DOOR_IRIS_LAKE_TO_WEST_MULBERRY.item.passage_to=WEST_MULBERRY.location=IRIS_LAKE.locked"
        "Maintenance door"
    , entity "TRASHED_NEWSPAPERS.item.location=IRIS_LAKE"
        "Pile of crumpled newspapers "

    -- NORWOOD
    , entity "OLD_LADIES.character.location=NORWOOD"
        "Old women in floral dresses"
    , entity "TRASH_CAN_NORWOOD.item.trashcan.location=NORWOOD"
        "Trash can"
    , entity "LIVING_STATUE.character.location=NORWOOD"
        "Living statue"
    , entity "SLEEPING_MAN.character.location=NORWOOD"
        "Man sleeping on ground"

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
