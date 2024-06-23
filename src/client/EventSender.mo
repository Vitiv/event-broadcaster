import Evm "canister:evm_rpc";

import Cycles "mo:base/ExperimentalCycles";

import T "./EthTypes";

module {
    type RpcConfig = T.RpcConfig;
    type GetLogsArgs = T.GetLogsArgs;
    type Result<Ok, Err> = { #ok : Ok; #err : Err };
    let default_fee = 2_000_000_000;

    public func requestCost(source : T.RpcService, jsonRequest : Text, maxResponseBytes : Nat64) : async Nat {
        let response = await Evm.requestCost(source, jsonRequest, maxResponseBytes);
        let res = switch (await Evm.requestCost(source, jsonRequest, maxResponseBytes)) {
            case (#ok(cost)) { cost };
            case (#err(_)) { 0 };
        };
        return res;
    };

    public func eth_getLogs(source : T.RpcSources, config : ?T.RpcConfig, getLogArgs : T.GetLogsArgs, cycles : Nat) : async T.MultiGetLogsResult {
        Cycles.add<system>(cycles);
        let response = await Evm.eth_getLogs(source, config, getLogArgs);
        // parse response before return
        // let parsedResponse : [T.LogEntry] = await _parseMultiGetLogsResult(response);
        return response;
    };

    func _parseMultiGetLogsResult(result : T.MultiGetLogsResult) : async [T.LogEntry] {
        switch (result) {
            case (#Consistent(#Ok(logs))) { logs };
            case (#Consistent(#Err(_))) { [] };
            case (#Inconsistent(_)) { [] };
        };
    };

    public func eth_getBlockByNumber(source : T.RpcSources, config : ?T.RpcConfig, blockTag : T.BlockTag, cycles : Nat) : async T.MultiGetBlockByNumberResult {
        Cycles.add<system>(cycles);
        let response = await Evm.eth_getBlockByNumber(source, config, blockTag);
        return response;
    };

    public func eth_sendRawTransaction(source : T.RpcSources, config : ?T.RpcConfig, rawTx : Text, cycles : Nat) : async T.MultiSendRawTransactionResult {
        Cycles.add<system>(cycles);
        let response = await Evm.eth_sendRawTransaction(source, config, rawTx);
        return response;
    };
};
