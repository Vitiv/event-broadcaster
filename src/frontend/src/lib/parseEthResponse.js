export function parseMultiGetLogsResult(result) {
    if ("Consistent" in result) {
        return parseGetLogsResult(result.Consistent);
    } else if ("Inconsistent" in result) {
        return result.Inconsistent.map(([rpcService, getLogsResult]) => ({
            rpcService: parseRpcService(rpcService),
            getLogsResult: parseGetLogsResult(getLogsResult),
        }));
    }
}

function parseGetLogsResult(result) {
    if ("Ok" in result) {
        return result.Ok.map(parseLogEntry);
    } else if ("Err" in result) {
        return parseRpcError(result.Err);
    }
}

function parseLogEntry(entry) {
    return {
        transactionHash: entry.transactionHash,
        blockNumber: entry.blockNumber,
        data: entry.data,
        blockHash: entry.blockHash,
        transactionIndex: entry.transactionIndex,
        topics: entry.topics,
        address: entry.address,
        logIndex: entry.logIndex,
        removed: entry.removed,
    };
}

function parseRpcError(error) {
    if ("JsonRpcError" in error) {
        return { type: "JsonRpcError", ...error.JsonRpcError };
    } else if ("ProviderError" in error) {
        return { type: "ProviderError", ...parseProviderError(error.ProviderError) };
    } else if ("ValidationError" in error) {
        return { type: "ValidationError", ...parseValidationError(error.ValidationError) };
    } else if ("HttpOutcallError" in error) {
        return { type: "HttpOutcallError", ...parseHttpOutcallError(error.HttpOutcallError) };
    }
}

function parseRpcService(service) {
    if ("EthSepolia" in service) {
        return { type: "EthSepolia", service: service.EthSepolia };
    } else if ("Custom" in service) {
        return { type: "Custom", ...parseRpcApi(service.Custom) };
    } else if ("EthMainnet" in service) {
        return { type: "EthMainnet", service: service.EthMainnet };
    } else if ("Chain" in service) {
        return { type: "Chain", chainId: service.Chain };
    } else if ("Provider" in service) {
        return { type: "Provider", providerId: service.Provider };
    }
}

function parseRpcApi(api) {
    return {
        url: api.url,
        headers: api.headers,
    };
}

function parseProviderError(error) {
    if ("TooFewCycles" in error) {
        return { type: "TooFewCycles", ...error.TooFewCycles };
    } else if ("MissingRequiredProvider" in error) {
        return { type: "MissingRequiredProvider" };
    } else if ("ProviderNotFound" in error) {
        return { type: "ProviderNotFound" };
    } else if ("NoPermission" in error) {
        return { type: "NoPermission" };
    }
}

function parseValidationError(error) {
    if ("CredentialPathNotAllowed" in error) {
        return { type: "CredentialPathNotAllowed" };
    } else if ("HostNotAllowed" in error) {
        return { type: "HostNotAllowed", host: error.HostNotAllowed };
    } else if ("CredentialHeaderNotAllowed" in error) {
        return { type: "CredentialHeaderNotAllowed" };
    } else if ("UrlParseError" in error) {
        return { type: "UrlParseError", message: error.UrlParseError };
    } else if ("Custom" in error) {
        return { type: "Custom", message: error.Custom };
    } else if ("InvalidHex" in error) {
        return { type: "InvalidHex", message: error.InvalidHex };
    }
}

function parseHttpOutcallError(error) {
    if ("IcError" in error) {
        return { type: "IcError", ...error.IcError };
    } else if ("InvalidHttpJsonRpcResponse" in error) {
        return { type: "InvalidHttpJsonRpcResponse", ...error.InvalidHttpJsonRpcResponse };
    }
}

// export default {
//     parseMultiGetLogsResult,
// };
