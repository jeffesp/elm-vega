port module FillStrokeTests exposing (elmToJS)

import Html exposing (Html, div, pre)
import Html.Attributes exposing (id)
import Json.Encode
import VegaLite exposing (..)


-- defChart : Spec


encChart : (List a -> List LabelledSpec) -> Spec
encChart extraEnc =
    let
        data =
            dataFromColumns []
                << dataColumn "x" (Numbers [ 10, 20, 30, 36 ])
                << dataColumn "y" (Numbers [ 1, 2, 3, 4 ])
                << dataColumn "val" (Numbers [ 1, 2, 3, 4 ])
                << dataColumn "cat" (Strings [ "a", "b", "c", "d" ])

        enc =
            encoding
                << position X [ PName "x", PmType Quantitative ]
                << position Y [ PName "y", PmType Quantitative ]
                << color [ MName "cat", MmType Nominal ]
                << size [ MNumber 2000 ]
                << extraEnc
    in
    toVegaLite [ width 200, height 200, data [], enc [], mark Circle [ MStroke "black" ] ]


defChart : Spec
defChart =
    encChart (always [])


fill1 : Spec
fill1 =
    encChart (fill [])


fill2 : Spec
fill2 =
    encChart (fill [ MName "y", MmType Ordinal ])


fill3 : Spec
fill3 =
    encChart (fill [ MString "red" ])


stroke1 : Spec
stroke1 =
    encChart (stroke [])


stroke2 : Spec
stroke2 =
    encChart (stroke [ MName "y", MmType Ordinal ])


stroke3 : Spec
stroke3 =
    encChart (stroke [ MString "red" ])


combined1 : Spec
combined1 =
    encChart (stroke [] << fill [])


combined2 : Spec
combined2 =
    encChart (stroke [ MName "y", MmType Ordinal ] << fill [ MString "red" ])


combined3 : Spec
combined3 =
    encChart (stroke [ MString "red" ] << fill [ MName "y", MmType Ordinal ])


geo1 : Spec
geo1 =
    let
        geojson =
            geoFeatureCollection
                [ geometry (GeoPolygon [ [ ( -2, 58 ), ( 3, 58 ), ( 3, 53 ), ( -2, 53 ), ( -2, 58 ) ] ]) []
                , geometry (GeoLine [ ( 4, 52 ), ( 4, 59 ), ( -3, 59 ) ]) []
                ]
    in
    toVegaLite
        [ width 300
        , height 300
        , dataFromJson geojson []
        , mark Geoshape []
        ]


geo2 : Spec
geo2 =
    let
        geojson =
            geoFeatureCollection
                [ geometry (GeoPolygon [ [ ( -2, 58 ), ( 3, 58 ), ( 3, 53 ), ( -2, 53 ), ( -2, 58 ) ] ]) []
                , geometry (GeoLine [ ( 4, 52 ), ( 4, 59 ), ( -3, 59 ) ]) []
                ]

        -- NOTE: There is a bug in Vega-Lite that prevents accessing items nested in arrays, so this does not yet work.
        enc =
            encoding << color [ MName "features.geometry.type", MmType Nominal ]
    in
    toVegaLite
        [ width 300
        , height 300
        , enc []
        , dataFromJson geojson []
        , mark Geoshape []
        ]


sourceExample : Spec
sourceExample =
    defChart



{- This list comprises the specifications to be provided to the Vega-Lite runtime. -}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "default", defChart )
        , ( "fill1", fill1 )
        , ( "fill2", fill2 )
        , ( "fill3", fill3 )
        , ( "stroke1", stroke1 )
        , ( "stroke2", stroke2 )
        , ( "stroke3", stroke3 )
        , ( "combined1", combined1 )
        , ( "combined2", combined2 )
        , ( "combined3", combined3 )
        , ( "geo1", geo1 )

        --  , ( "geo2", geo2 )
        ]



{- ---------------------------------------------------------------------------
   The code below creates an Elm module that opens an outgoing port to Javascript
   and sends both the specs and DOM node to it.
   This is used to display the generated Vega specs for testing purposes.
-}


main : Program Never Spec msg
main =
    Html.program
        { init = ( mySpecs, elmToJS mySpecs )
        , view = view
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }



-- View


view : Spec -> Html msg
view spec =
    div []
        [ div [ id "specSource" ] []
        , pre []
            [ Html.text (Json.Encode.encode 2 sourceExample) ]
        ]


port elmToJS : Spec -> Cmd msg
