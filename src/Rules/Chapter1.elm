module Rules.Chapter1 exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "askMaintenanceManForDirections"
            """
            ON: MAINTENANCE_MAN
            IF: PLAYER.destination=BROADWAY_STREET.chapter=1
            """
        |> rule_______________________ "getMap"
            """
            ON: MAP_POSTER
            IF: MAP.!location=PLAYER
            DO: MAP.location=PLAYER
            """
        |> rule_______________________ "delaysAtBroadwayStreetStation"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.destination=BROADWAY_STREET.chapter=1
            DO: PLAYER.location=BROADWAY_STREET.destination=xxx
                BROADWAY_STREET.out_of_service
                COMMUTER_1.location=BROADWAY_STREET
            """
        |> rule_______________________ "notGoingToWorkAgain"
            """
            ON: *.station
            IF: PLAYER.destination=BROADWAY_STREET.chapter=1
            """
        |> rule_______________________ "leavingBroadwayStationPrematurely"
            """
            ON: *.line
            IF: PLAYER.location=BROADWAY_STREET
                BROADWAY_STREET.leaving_broadway_street_station_plot<1
            """
        |> rule_______________________ "askOfficersAboutDelay"
            """
            ON: SECURITY_OFFICERS
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<2
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=1
                PLAYER.present_proposal+1
            """
        |> rule_______________________ "askCommuter1AboutDelay"
            """
            ON: COMMUTER_1
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<2
                PLAYER.chapter=1
            """
        |> rule_______________________ "noticeGirlInYellow"
            """
            ON: GIRL_IN_YELLOW
            IF: PLAYER.chapter=1
            DO: GIRL_IN_YELLOW.who_was_girl_in_yellow_quest=1
                GIRL_IN_YELLOW.location=offscreen
            """
        |> rule_______________________ "briefcaseStolen"
            """
            ON: *.line
            IF: PLAYER.chapter=1
                BROADWAY_STREET.leaving_broadway_street_station_plot=1
            DO: BRIEFCASE.location=THIEF
                BROADWAY_STREET.leaving_broadway_street_station_plot=2
                GIRL_IN_YELLOW.location=offscreen
                PLAYER.find_briefcase=1.present_proposal+1
            """
        |> rule_______________________ "tellOfficersAboutStolenBriefcase"
            """
            ON: SECURITY_OFFICERS
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=2
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=3
            """
        |> rule_______________________ "tellCommuter1AboutStolenBriefcase"
            """
            ON: COMMUTER_1
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot>1
            """
        |> rule_______________________ "followGuardsAdvice"
            """
            ON: SPRING_HILL
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=3
                PLAYER.chapter=1
            DO: PLAYER.location=SPRING_HILL
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "ignoreGuardsAdvice"
            """
            ON: *.station
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=3
                PLAYER.chapter=1
            DO: PLAYER.location=$
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "panic"
            """
            ON: *.station
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=2
                PLAYER.chapter=1
            DO: PLAYER.location=$
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "findingSecurityDepotClosed"
            """
            ON: SECURITY_DEPOT_SPRING_HILL_STATION
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<5
                PLAYER.chapter=1
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=5
                SKATER_DUDE.location=SPRING_HILL
            """
        |> rule_______________________ "helpFromSkaterDude"
            """
            ON: SKATER_DUDE
            IF: PLAYER.chapter=1.location=SPRING_HILL
            DO: SKATER_DUDE.help_steve=1
                PLAYER.destination=CAPITOL_HEIGHTS
            """
        |> rule_______________________ "forcePlayerToFollowSkaterDudeOntoOrangeLine"
            """
            ON: RED_LINE
            IF: PLAYER.chapter=1.location=SPRING_HILL
                SKATER_DUDE.help_steve=1
            """
        |> rule_______________________ "forcePlayerToFollowSkaterDudeToCapitolHeights"
            """
            ON: *.station
            IF: PLAYER.chapter=1.location=SPRING_HILL
                SKATER_DUDE.help_steve=1
            """
        |> rule_______________________ "followSkaterDudeToOrangeLine"
            """
            ON: ORANGE_LINE
            IF: PLAYER.chapter=1.location=SPRING_HILL
                SKATER_DUDE.help_steve=1
            DO: PLAYER.line=ORANGE_LINE.at_turnstile
            """
        |> rule_______________________ "jumpTurnstileWithSkaterDude"
            """
            ON: ORANGE_LINE
            IF: PLAYER.chapter=1.location=SPRING_HILL.at_turnstile
                SKATER_DUDE.help_steve=1
            DO: PLAYER.line=ORANGE_LINE.-at_turnstile
            """
        |> rule_______________________ "followSkaterDudeToCapitalHeights"
            """
            ON: CAPITOL_HEIGHTS
            IF: PLAYER.chapter=1.location=SPRING_HILL
                SKATER_DUDE.help_steve=1
            DO: PLAYER.destination=xxx.location=CAPITOL_HEIGHTS.find_briefcase=2
                SKATER_DUDE.location=ONE_HUNDRED_FORTH_STREET
            """
        -- orange line
        |> rule_______________________ "findKeyInTrashCan"
            """
            ON: TRASH_CAN_CAPITOL_HEIGHTS.!empty
            DO: ODD_KEY.location=PLAYER
                TRASH_CAN_CAPITOL_HEIGHTS.empty
            """
        |> rule_______________________ "markTellsAboutBroomCloset"
            """
            ON: MARK
            IF: PLAYER.find_briefcase=2
            DO: PLAYER.find_briefcase=3
            """
        |> rule_______________________ "pleasantriesWithMark"
            """
            ON: MARK
            IF: PLAYER.find_briefcase>2
            """
        |> rule_______________________ "jumpTurnstileAfterTaklingToMark"
            """
            ON: ORANGE_LINE
            IF: PLAYER.chapter=1.location=CAPITOL_HEIGHTS.find_briefcase=3.at_turnstile
            DO: PLAYER.line=ORANGE_LINE.-at_turnstile
            """
        |> rule_______________________ "caughtOnOrangeLineHeadingTo73rd"
            """
            ON: SEVENTY_THIRD_STREET
            IF: PLAYER.chapter=1.location=CAPITOL_HEIGHTS.find_briefcase=3
            DO: PLAYER.location=ST_MARKS
            """
        |> rule_______________________ "caughtOnOrangeLineHeadingToOther"
            """
            ON: *.station
            IF: PLAYER.chapter=1.location=CAPITOL_HEIGHTS.find_briefcase=3
            DO: PLAYER.location=ST_MARKS
            """
        |> rule_______________________ "TICKET_INSPECTOR"
            """
            ON: TICKET_INSPECTOR
            DO: INFRACTIONS_INSTRUCTIONS_POSTER.location=CENTRAL_GUARD_OFFICE
                INFRACTIONS_COMPUTER.location=CENTRAL_GUARD_OFFICE
                INFRACTIONS_PRINTER.location=CENTRAL_GUARD_OFFICE
                INFRACTIONS_GREEN_BUTTON.location=CENTRAL_GUARD_OFFICE
                INFRACTIONS_ROOM_DOOR.location=CENTRAL_GUARD_OFFICE
                INFRACTIONS_CARD_READER.location=CENTRAL_GUARD_OFFICE
                $.location=offscreen
            """
        |> rule_______________________ "infractionAutomationStep1"
            """
            ON: INFRACTIONS_CARD_READER
            IF: INFRACTIONS_ROOM_DOOR.infraction_step=0
            DO: INFRACTIONS_ROOM_DOOR.infraction_step=1
            """
        |> rule_______________________ "infractionAutomationStep2"
            """
            ON: INFRACTIONS_COMPUTER
            IF: INFRACTIONS_ROOM_DOOR.infraction_step=1
            DO: INFRACTIONS_ROOM_DOOR.infraction_step=2
            """
        |> rule_______________________ "infractionAutomationStep3"
            """
            ON: INFRACTIONS_PRINTER
            IF: INFRACTIONS_ROOM_DOOR.infraction_step>1
            DO: INFRACTIONS_ROOM_DOOR.infraction_step=3
            """
        |> rule_______________________ "breakInfractionAutomationSystem"
            """
            ON: INFRACTIONS_GREEN_BUTTON
            IF: INFRACTIONS_ROOM_DOOR.infraction_step<3
            DO: INFRACTIONS_ROOM_DOOR.infraction_step=3
            """
        |> rule_______________________ "escapingInfractionRoom"
            """
            ON: INFRACTIONS_ROOM_DOOR.infraction_step=3
            DO: INFRACTIONS_INSTRUCTIONS_POSTER.location=offscreen
                INFRACTIONS_COMPUTER.location=offscreen
                INFRACTIONS_PRINTER.location=offscreen
                INFRACTIONS_GREEN_BUTTON.location=offscreen
                INFRACTIONS_ROOM_DOOR.location=offscreen
                INFRACTIONS_CARD_READER.location=offscreen
                GRIZZLED_SECURITY_GUARD.location=CENTRAL_GUARD_OFFICE
            """
