<script>
    import { backend } from "$lib/canisters";
    import { parseMultiGetLogsResult } from "$lib/parseEthResponse";
    import { getRpcCost } from "$lib/cost";
    import { createEventDispatcher } from "svelte";
    import { writable } from "svelte/store";

    let selectedNetwork = writable("");
    let selectedProvider = writable("");

    const networks = [
        {
            name: "Eth Sepolia",
            providers: ["Alchemy", "BlockPi", "PublicNode", "Ankr"],
        },
        {
            name: "Eth Mainnet",
            providers: [
                "Alchemy",
                "BlockPi",
                "Cloudflare",
                "PublicNode",
                "Ankr",
            ],
        },
    ];

    function handleNetworkChange(event) {
        selectedNetwork.set(event.target.value);
        selectedProvider.set("");
    }

    function handleProviderChange(event) {
        selectedProvider.set(event.target.value);
    }

    let blockTagFrom = "";
    let blockTagTo = "";
    let fromBlock = "";
    let toBlock = "";
    let addresses = [""];
    let topics = [""];
    let config = { responseSizeEstimate: 1000 };
    let estimatedCost = 0;
    let maxResponseBytes = 1000;

    const dispatch = createEventDispatcher();

    function addAddress() {
        addresses = [...addresses, ""];
    }

    function updateAddress(index, event) {
        addresses[index] = event.target.value;
        handleInput();
    }

    function addTopic() {
        topics = [...topics, ""];
    }

    function updateTopic(index, event) {
        topics[index] = event.target.value;
        handleInput();
    }

    async function callEthGetLogs() {
        let source;
        let provider;
        selectedNetwork.subscribe((value) => {
            source = value;
        });
        selectedProvider.subscribe((value) => {
            provider = value;
        });

        const getLogArgs = {
            blockTagFrom: blockTagFrom || "",
            blockTagTo: blockTagTo || "",
            fromBlock: fromBlock || 1,
            toBlock: toBlock || 1,
            addresses,
            topics: topics.length > 0 ? topics : [],
        };

        const data = {
            source: JSON.stringify(source),
            provider: JSON.stringify(provider),
            config: JSON.stringify(config),
            getLogArgs: JSON.stringify(getLogArgs),
        };
        console.log("Request data ", data);

        // let est_back = await backend.requestCost(
        //     { source: provider },
        //     data.getLogArgs,
        //     maxResponseBytes,
        // );
        // console.log("Estimated cost from RPC: ", est_back);
        // console.log(
        //     "Added cycles ",
        //     estimatedCost > est_back ? estimatedCost : est_back,
        // );

        const response = await backend.getEthLogs(
            source,
            provider,
            config.responseSizeEstimate,
            getLogArgs.addresses,
            getLogArgs.blockTagFrom,
            getLogArgs.fromBlock,
            getLogArgs.blockTagTo,
            getLogArgs.toBlock,
            getLogArgs.topics,
            estimatedCost,
        );
        console.log("Eth Response ", response);
        // const parsedResult = parseMultiGetLogsResult(response);
        // console.log(parsedResult);
        dispatch("submit", {
            formData: { source, provider, config, getLogArgs, response },
        });
    }

    function getTextSize(text) {
        const textEncoder = new TextEncoder();
        return textEncoder.encode(text).length;
    }

    export function calculateCost() {
        let provider;
        selectedProvider.subscribe((value) => {
            provider = value;
        });
        let network;
        selectedNetwork.subscribe((value) => {
            network = value;
        });

        const addressSize = addresses.reduce(
            (acc, address) => acc + getTextSize(address),
            0,
        );
        const topicSize = topics.reduce(
            (acc, topic) => acc + getTextSize(topic),
            0,
        );
        const blockTagSize = 8;
        const service = {
            api: network,
            provider: provider,
        };

        const jsonRequest = JSON.stringify({
            source: network,
            provider: provider,
            config: config,
            getLogArgs: {
                blockTagFrom: blockTagFrom || null,
                blockTagTo: blockTagTo || null,
                fromBlock: fromBlock || null,
                toBlock: toBlock || null,
                addresses,
                topics: topics.length > 0 ? topics : [],
            },
        });
        console.log(jsonRequest);
        estimatedCost = getRpcCost(
            service,
            jsonRequest.length,
            maxResponseBytes,
        );
        console.log(`Estimated cost: ${estimatedCost}`);
    }

    $: calculateCost();

    function handleInput() {
        calculateCost();
    }

    function addCycles() {
        console.log("Adding cycles to request", estimatedCost);
        dispatch("addCycles", { cycles: estimatedCost });
    }
</script>

<div class="form-container">
    <div class="form-group">
        <label for="network">Select Network</label>
        <select id="network" class="form-input" on:change={handleNetworkChange}>
            <option value="">Select a network</option>
            {#each networks as network}
                <option value={network.name}>{network.name}</option>
            {/each}
        </select>
    </div>

    {#if $selectedNetwork}
        <div class="form-group">
            <label for="provider">Select Provider</label>
            <select
                id="provider"
                class="form-input"
                on:change={handleProviderChange}
                bind:value={$selectedProvider}
            >
                <option value="">Select a provider</option>
                {#each networks.find((n) => n.name === $selectedNetwork).providers as provider}
                    <option value={provider}>{provider}</option>
                {/each}
            </select>
        </div>
    {/if}

    <div class="form-group">
        <label for="block-tag-from">Block Tag From</label>
        <select
            id="block-tag-from"
            class="form-input"
            bind:value={blockTagFrom}
            on:change={handleInput}
        >
            <option value="">None</option>
            <option value="Earliest">Earliest</option>
            <option value="Safe">Safe</option>
            <option value="Finalized">Finalized</option>
            <option value="Latest">Latest</option>
            <option value="Pending">Pending</option>
            <option value="Number">Number</option>
        </select>
    </div>

    {#if blockTagFrom === "Number"}
        <div class="form-group">
            <label for="from-block">From Block</label>
            <input
                type="number"
                id="from-block"
                class="form-input"
                on:change={handleInput}
                bind:value={fromBlock}
                placeholder="From Block"
            />
        </div>
    {/if}

    <div class="form-group">
        <label for="block-tag-to">Block Tag To</label>
        <select
            id="block-tag-to"
            class="form-input"
            bind:value={blockTagTo}
            on:change={handleInput}
        >
            <option value="">None</option>
            <option value="Earliest">Earliest</option>
            <option value="Safe">Safe</option>
            <option value="Finalized">Finalized</option>
            <option value="Latest">Latest</option>
            <option value="Pending">Pending</option>
            <option value="Number">Number</option>
        </select>
    </div>

    {#if blockTagTo === "Number"}
        <div class="form-group">
            <label for="to-block">To Block</label>
            <input
                type="number"
                id="to-block"
                class="form-input"
                on:change={handleInput}
                bind:value={toBlock}
                placeholder="To Block"
            />
        </div>
    {/if}

    <div class="form-group filter-group">
        <label for="address">Addresses</label>
        <div class="filter-container">
            {#each addresses as address, index}
                <input
                    id="address"
                    type="text"
                    class="form-input-filter"
                    bind:value={addresses[index]}
                    on:input={(e) => updateAddress(index, e)}
                    placeholder={`Address ${index + 1}`}
                />
            {/each}
            <button class="form-button-filter" on:click={addAddress}>Add</button
            >
        </div>
    </div>

    <div class="form-group filter-group">
        <label for="topic">Topics</label>
        <div class="filter-container">
            {#each topics as topic, index}
                <input
                    id="topic"
                    type="text"
                    class="form-input-filter"
                    bind:value={topics[index]}
                    on:input={(e) => updateTopic(index, e)}
                    placeholder={`Topic ${index + 1}`}
                />
            {/each}
            <button class="form-button-filter" on:click={addTopic}>Add</button>
        </div>
    </div>

    <div class="form-group">
        <label for="max-response-size">Max Response Size (Bytes)</label>
        <input
            type="number"
            id="max-response-size"
            class="form-input"
            bind:value={maxResponseBytes}
            on:input={calculateCost}
            placeholder="Max Response Size (Bytes)"
        />
    </div>

    <div class="form-group">
        <label for="estimate-cost">Estimate Cost (Cycles)</label>
        <div class="filter-container">
            <input
                type="number"
                id="estimate-cost"
                class="form-input-filter"
                bind:value={estimatedCost}
                placeholder="${estimatedCost}"
            />
            <button class="form-button-filter" on:click={addCycles}>Add</button>
        </div>
    </div>

    <button class="form-button-subscribe" on:click={callEthGetLogs}>
        Call eth_getLogs
    </button>
</div>

<style>
    .form-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;
    }

    .form-group {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        width: 100%;
        max-width: 400px;
    }

    .form-group label {
        font-family: "Lexend Zetta", sans-serif;
        margin-bottom: 0.5rem;
        font-weight: bold;
        font-size: 0.8rem;
        color: white;
    }

    .filter-group {
        display: flex;
        flex-direction: column;
    }

    .filter-container {
        display: flex;
        align-items: center;
        width: 100%;
    }

    #network,
    #provider,
    #block-tag-from,
    #block-tag-to,
    #from-block,
    #to-block,
    #address,
    #topic,
    #max-response-size,
    #estimate-cost {
        color: aquamarine;
    }

    .form-input {
        width: 100%;
        max-width: 400px;
        padding: 0.5rem;
        font-size: 1rem;
        border: 1px solid #ccc;
        border-radius: 4px;
        background-color: transparent;
        box-shadow: -5px -5px 15px rgba(158, 246, 244, 0.5);
    }

    .form-input-filter {
        width: calc(100% - 80px);
        margin-right: 10px;
        padding: 0.5rem;
        font-size: 1rem;
        border: 1px solid #ccc;
        border-radius: 4px;
        background-color: transparent;
        box-shadow: -5px -5px 15px rgba(158, 246, 244, 0.5);
    }

    .form-input::placeholder,
    .form-input-filter::placeholder {
        font-family: "Lexend Zetta", sans-serif;
        font-size: 0.7rem;
        color: white;
        opacity: 1;
    }

    .form-input:focus,
    .form-input-filter:focus {
        border-color: #06636c;
        box-shadow: 0 0 15px rgba(0, 123, 255, 0.5);
        outline: none;
    }

    .form-button-filter,
    .form-button-subscribe {
        font-family: "Lexend Zetta", sans-serif;
        border: white 1px solid;
        border-radius: 10px;
        background-color: transparent;
        color: white;
        cursor: pointer;
        transition: background-color 0.3s;
    }

    .form-button-filter {
        padding: 0.4rem;
        max-width: 60px;
        font-size: 0.9rem;
    }

    .form-button-subscribe {
        padding: 0.5rem;
        width: 100%;
        max-width: 200px;
        margin-top: 1.5rem;
        font-size: 1rem;
    }
    #from-block,
    #to-block,
    #max-response-size {
        width: 100%;
        max-width: 380px;
    }

    .form-button-filter:hover,
    .form-button-subscribe:hover {
        background-color: #24bbe1;
    }

    .form-input option {
        background-color: #333;
        color: white;
    }
</style>
