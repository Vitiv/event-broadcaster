# Motoko Event Hub 

This repository contains the implementation of the **Event Hub** in [Motoko](https://github.com/dfinity/motoko) programming language for [Internet Computer](https://internetcomputer.org/). 

## Summary:

**Event Hub** is a [draft ICRC72](https://github.com/icdevs/ICEventsWG/blob/main/Meetings/20240515/icrc72draft.md) Motoko pub-sub pattern implementation for managing events, subscribers, and sending events to subscribers.

**Event Hub** also provides interoperability with Ethereum RPC methods.
 
## Overview:
![Event_Hub](https://github.com/ava-vs/event_hub/assets/30374212/e29abbbf-2d5f-4bdf-a981-4403f8aedbac)

## Features:
- Subscriber Management: Functions for subscribing (subscribe) and unsubscribing (unsubscribe) to events.
- Publication Managment: Register a new publication and publish events to subscribers.
- Broadcaster: Distribute messages to subscribers 
- Ethereum Interaction: Functions are provided to call Ethereum RPC methods (callEthgetLogs, callEthgetBlockByNumber, callEthsendRawTransaction).

## Usage

Subscriptions and publications can be made through the Event Hub Client frontend ([example](https://mls5s-5qaaa-aaaal-qi6rq-cai.icp0.io)).

## Dependencies
This project depends on [evm_rpc canister](https://github.com/internet-computer-protocol/evm-rpc-canister).

## Deployment

### Mainnet
```bash
cd event_client
dfx deploy --ic
```

#### Local
```bash
dfx start --background
```

#### Locally deploy the `evm_rpc` canister
```bash
dfx deps pull
dfx deps init evm_rpc --argument '(record { nodesInSubnet = 28 })'
dfx deps deploy
dfx deploy
```
### Contributing
Contributions are welcome. Please submit a pull request or open an issue to discuss your ideas.

### License
This project is licensed under the terms of the MIT license.

