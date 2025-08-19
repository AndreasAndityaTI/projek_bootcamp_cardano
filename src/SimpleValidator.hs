{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings   #-}

module SimpleValidator where

import PlutusTx
import PlutusTx.Prelude
import Ledger
import Ledger.Typed.Scripts as Scripts
import Ledger.Contexts as V
import Prelude (IO)
import Plutus.V1.Ledger.Scripts

-- Validator sederhana: hanya mengecek kalau redeemer == datum
{-# INLINABLE mkValidator #-}
mkValidator :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mkValidator datum redeemer _ =
    if datum == redeemer
        then ()
        else traceError "Datum dan Redeemer tidak cocok!"

validator :: Validator
validator = mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator mkValidator

-- Script serialisation (untuk menghasilkan file .plutus)
validatorScript :: Script
validatorScript = unValidatorScript validator

validatorSBS :: SBS.ShortByteString
validatorSBS = SBS.toShort . LBS.toStrict $ serialise validatorScript

validatorHash :: ValidatorHash
validatorHash = validatorHash validator

scriptAddress :: Ledger.Address
scriptAddress = scriptAddress validator