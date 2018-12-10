module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, characters, entity, items, locations, worldModel)

import City exposing (Station(..), stationInfo)
import Dict exposing (Dict)
import Narrative.WorldModel exposing (..)


type alias DisplayComponent a =
    { a | name : String, description : String }


type alias Entity =
    NarrativeComponent (DisplayComponent {})


type alias WorldModel =
    Dict String Entity


type alias ID =
    String


entity : ID -> String -> String -> ( String, Entity )
entity id name description =
    ( id
    , { name = name
      , description = description
      , tags = emptyTags
      , stats = emptyStats
      , links = emptyLinks
      }
    )


worldModel : WorldModel
worldModel =
    Dict.fromList <|
        items
            ++ characters
            ++ locations
            ++ general


station : Station -> String
station station_ =
    -- TODO remove this after removing graph
    station_ |> stationInfo |> .id |> String.fromInt


{-| Simple helper to group items/characters by where they are located.
-}
location : String -> List ( ID, Entity ) -> List ( ID, Entity )
location id =
    List.map (link "location" id)


items : List ( ID, Entity )
items =
    List.map (tag "item") <|
        []
            -- inventory
            ++ location "player"
                [ entity "briefcase"
                    "Briefcase"
                    "The tool of your trade, perfectly organized, and always by your side.  It has papers, pencils, but most importantly, the hard copy of your presentation."
                , entity "redLinePass"
                    "Red Line pass"
                    "This will get you to any station along the Red Line.  Expires in 8 months."
                , entity "cellPhone"
                    "Cellphone"
                    "It's not one of those $800 ones, but it does everything you need.  Unless there's no service.  Down here there's no service, so it's practically useless.."
                ]
            ++ (location <| station TwinBrooks)
                [ entity "safteyWarningPoster"
                    "Safety Message Poster"
                    "A poster that warns you to watch out for pickpockets and report any suspicious activity. "
                , entity "mapPoster"
                    "Map on the wall"
                    "This shows the full map of the subway system."
                ]
            ++ (location <| station FederalTriangle)
                [ entity "policeOffice"
                    "Police Office"
                    "A small police office."
                , entity "ticketMachine"
                    "Ticket Machine"
                    "You can buy tickets and passes here."
                ]


characters : List ( ID, Entity )
characters =
    List.map (tag "character")
        [ entity "securityGuard"
            "Security Guard"
            "He's probably busy, you don't really have any reason to bother him."
            |> link "location" (station TwinBrooks)
        , entity "ticketInspector"
            "Ticket inspector"
            "Ticket inspectors aren't really the nicest people to associate with.  Unless you have a good reason to talk to him, you'd rather keep your distance."
        , entity "largeCrowd"
            "A large crowd"
            "They ignore you for the most part, occupied with the situation at hand."
            |> link "location" (station MetroCenter)
        , entity "securityOfficers"
            "Security officers"
            "Two of them, looking official, but not really all that helpful over all."
        ]


general : List ( ID, Entity )
general =
    [ entity "player"
        "Steve"
        "A guy just trying to get ahead by following the rules."
        |> stat "mainPlot" 1
        |> link "location" (station TwinBrooks)
    ]


{-| The locations are mostly handled through the main code, and are the different stations. The train is hard coded as a psudo-location, it never actually ends up in `currentLocation`
-}
locations : List ( ID, Entity )
locations =
    List.map (tag "location")
        [ entity "train"
            "Train car"
            "The train hurtles through the dark tunnel towards the next stop."
        ]
