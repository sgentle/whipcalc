module Whipcalc where

import Prelude
import Halogen
import Global (readFloat, isFinite, nan)
import Math (round, pow)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import qualified Halogen.HTML.Indexed as H
import qualified Halogen.HTML.Properties.Indexed as P
import qualified Halogen.HTML.Events.Indexed as E
import Halogen.HTML.Core (prop, propName)

type State = { on :: Boolean, mhz :: Number, adjustment :: Number, adjustmentString :: String }

initialState :: State
initialState = { on: true, mhz: nan, adjustment: 1.00, adjustmentString: "1.00" }

-- "Query algebra" aka operations
data Query a
  = UpdateMhz String a
  | UpdateAdjustment String a


-- Some helper functions

fmt :: Number -> String
fmt n = if isFinite n then show n else ""

roundTo :: Int -> Number -> Number
roundTo digits n =
  (round (n * mult)) / mult
  where mult = pow 10.0 (toNumber digits)

calcLength :: Number -> Number
calcLength mhz =
  speedOfLight / (mhz * 1000000.0)
  where
  speedOfLight = 299792458.0


-- This nonsense brought to you by type safety :(

unsafeProp :: forall r i. String -> String -> P.IProp r i
unsafeProp name val = P.IProp $ prop (propName name) Nothing val


-- Sub-components for rendering rows and individual unit results

resultUnit :: forall a b. String -> Number -> Int -> Number -> HTML a b
resultUnit unitName multiplier digits result =
  H.span_
    [ H.input [ P.inputType P.InputText
              , P.disabled true
              , P.value $ fmt $ roundTo digits $ result * multiplier
              , unsafeProp "size" "8"
              ]
    , H.text ("" ++ unitName ++ " ")
    ]

resultRow :: forall a b. String -> Number -> State -> HTML a b
resultRow title multiplier state =
  H.div_
    [ H.span_ [ H.text (title ++ ": ") ]
    , resultUnit "metres" 1.0 3 val
    , resultUnit "cm" 100.0 2 val
    , resultUnit "feet" 3.28084 3 val
    , resultUnit "inches" 39.3701 2 val
    ]
  where
  val = (calcLength state.mhz) * multiplier * state.adjustment


-- Gory definition of the component itself
ui :: forall g. (Functor g) => Component State Query g
ui = component render eval
  where

  render :: State -> ComponentHTML Query
  render state =
    H.div_
      [ H.h1_
          [ H.text "Whip Antenna Calculator"]

      , H.text "Frequency: "
      , H.input [ P.inputType P.InputText
                , P.placeholder "433"
                , P.autofocus true
                , unsafeProp "size" "8"
                , E.onValueInput (E.input UpdateMhz)
                ]
      , H.text " MHz"
      , H.br []
      , H.text "Adjustment factor: "
      , H.input [ P.inputType P.InputText
                , P.value state.adjustmentString
                , unsafeProp "size" "8"
                , E.onValueInput (E.input UpdateAdjustment)
                ]
      , H.br []
      , H.br []

      , resultRow "Wavelength" 1.0 state
      , resultRow "5/8 Wave" (5.0/8.0) state
      , resultRow "1/2 Wave" (1.0/2.0) state
      , resultRow "1/4 Wave" (1.0/4.0) state

      ]

  eval :: Natural Query (ComponentDSL State Query g)
  eval (UpdateMhz mhz next) = do
    modify (_ { mhz = readFloat mhz } )
    pure next

  eval (UpdateAdjustment adjustment next) = do
    modify (_ { adjustment = readFloat adjustment, adjustmentString = adjustment } )
    pure next