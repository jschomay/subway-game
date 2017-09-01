module Tests exposing (all)

import ElmTest.Extra
import Tests.Subway


all : ElmTest.Extra.Test
all =
    Tests.Subway.all
