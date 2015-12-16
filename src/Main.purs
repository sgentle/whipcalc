module Main where

import qualified Whipcalc as W

import Prelude
import Halogen
import Halogen.Util (appendToBody)
import Control.Monad.Aff (runAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (throwException)

main :: Eff (HalogenEffects ()) Unit
main = runAff throwException (const (pure unit)) $ do
    node <- runUI W.ui W.initialState
    appendToBody node.node


