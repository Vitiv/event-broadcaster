#!/usr/bin/env bash

dfx stop

echo "Starting dfx..."

dfx start --background --clean

echo "Deploying canisters..."

dfx deploy

echo "Running tests..."

dfx canister call test runAllTests

echo "Stopping dfx..."

dfx stop
