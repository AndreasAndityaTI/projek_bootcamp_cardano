{-# LANGUAGE OverloadedStrings #-}

module Main where

import Cardano.Api
import Cardano.Api.Shelley
import SimpleValidator (validator)

main :: IO ()
main = do
    let dummyPKH = "00000000000000000000000000000000000000000000000000000000" 
    case deserialiseFromRawBytesHex AsPaymentKeyHash dummyPKH of
      Nothing   -> putStrLn "Invalid PubKeyHash"
      Just pkh  -> do
          let script = validator pkh
          result <- writeFileTextEnvelope "simple-validator.plutus" Nothing script
          case result of
            Left err -> print $ displayError err
            Right () -> putStrLn "Plutus script successfully written to simple-validator.plutus"