// Constants
const BASE_COST = 3_000_000; // 3M cycles
const NODE_COST_PER_REQUEST = 60_000; // 60K cycles
const BYTE_COST_REQUEST = 400; // 400 cycles per byte for the request
const BYTE_COST_RESPONSE = 800; // 800 cycles per byte for the response

// Subnet sizes
const NODES_IN_STANDARD_SUBNET = 13;
const NODES_IN_FIDUCIARY_SUBNET = 34;

function getSubnetSize(subnet) {
    if (subnet === "fiduciary") {
        return NODES_IN_FIDUCIARY_SUBNET;
    }
    return NODES_IN_STANDARD_SUBNET;
}

// Get HTTP request cost
function getHttpRequestCost(api, payloadSizeBytes, maxResponseBytes, nodesInSubnet) {
    const ingressBytes = payloadSizeBytes + Math.max(100, api.length) + 100; // Overhead for ingress message

    const costPerNode = BASE_COST +
        NODE_COST_PER_REQUEST +
        BYTE_COST_REQUEST * ingressBytes +
        BYTE_COST_RESPONSE * maxResponseBytes;

    return costPerNode * nodesInSubnet; // Total cost for all nodes in the subnet
}

// Get RPC cost
function getRpcCost(service, payloadSizeBytes, maxResponseBytes) {
    const nodesInSubnet = getSubnetSize(service.subnetType); // Assume subnetType is provided in the service object

    if (service.api) {
        return getHttpRequestCost(service.api, payloadSizeBytes, maxResponseBytes, nodesInSubnet);
    } else if (service.provider) {
        const providerCost = service.provider.cyclesPerCall + service.provider.cyclesPerMessageByte * payloadSizeBytes;
        const httpCost = getHttpRequestCost("", payloadSizeBytes, maxResponseBytes, nodesInSubnet);
        return httpCost + providerCost * nodesInSubnet; // Assuming provider cost needs to be multiplied by number of nodes
    }
}

// Sample usage
const service = {
    api: "https://example.com/rpc",
    subnetType: "standard" // or "fiduciary"
};

const payloadSizeBytes = 100;
const maxResponseBytes = 1000;

const cost = getRpcCost(service, payloadSizeBytes, maxResponseBytes);
console.log(`Estimated cost: ${cost} cycles`);

export { getRpcCost, cost };
