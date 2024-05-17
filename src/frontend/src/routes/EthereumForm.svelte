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

	let source = "";
	let blockTagFrom = "";
	let blockTagTo = "";
	let fromBlock = "";
	let toBlock = "";
	let addresses = [""];
	let topics = [""];
	let responseSizeEstimate = null;
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

	let provider = selectedProvider;

	async function callEthGetLogs() {
		source = selectedNetwork;

		const config = responseSizeEstimate ? responseSizeEstimate : 0;
		const getLogArgs = {
			blockTagFrom: blockTagFrom || null,
			blockTagTo: blockTagTo || null,
			fromBlock: fromBlock || null,
			toBlock: toBlock || null,
			addresses,
			topics: topics.length > 0 ? topics : [],
		};

		const data = {
			source: JSON.stringify(source),
			provider: JSON.stringify(provider),
			config: JSON.stringify(config),
			getLogArgs: JSON.stringify(getLogArgs),
		};
		console.log(data);

		response = await backend.getEthLogs(
			source,
			provider,
			config,
			getLogArgs.addresses,
			getLogArgs.blockTagFrom,
			getLogArgs.fromBlock,
			getLogArgs.blockTagTo,
			getLogArgs.toBlock,
			getLogArgs.topics,
		);
		const parsedResult = parseMultiGetLogsResult(response);
		console.log(parsedResult);
		dispatch("submit", {
			formData: { source, provider, config, getLogArgs, response },
		});
	}

	function getTextSize(text) {
		const textEncoder = new TextEncoder();
		return textEncoder.encode(text).length;
	}

	export function calculateCost() {
		const addressSize = addresses.reduce(
			(acc, address) => acc + getTextSize(address),
			0,
		);
		const topicSize = topics.reduce(
			(acc, topic) => acc + getTextSize(topic),
			0,
		);
		const blockTagSize = 8;
		const payloadSizeBytes = addressSize + topicSize + 2 * blockTagSize;
		const service = {
			api: selectedNetwork,
			provider: provider,
		};

		estimatedCost = getRpcCost(service, payloadSizeBytes, maxResponseBytes);
		console.log(`Estimated cost: ${estimatedCost}`);
	}

	$: calculateCost();

	function handleInput() {
		calculateCost();
	}

	function addCycles() {
		dispatch("addCycles", { cycles: estimatedCost });
	}
</script>

<div>
	<label for="network">Select Network</label>
	<select id="network" on:change={handleNetworkChange}>
		<option value="">Select a network</option>
		{#each networks as network}
			<option value={network.name}>{network.name}</option>
		{/each}
	</select>

	{#if $selectedNetwork}
		<label for="provider">Select Provider</label>
		<select
			id="provider"
			on:change={handleProviderChange}
			bind:value={$selectedProvider}
		>
			<option value="">Select a provider</option>
			{#each networks.find((n) => n.name === $selectedNetwork).providers as provider}
				<option value={provider}>{provider}</option>
			{/each}
		</select>
	{/if}

	<p>Selected Network: {$selectedNetwork}</p>
	<p>Selected Provider: {$selectedProvider}</p>
	<!-- <label for="eth-sepolia-service">Eth Sepolia Service</label>
	<select
		id="eth-sepolia-service"
		on:change={handleInput}
		bind:value={providerSepolia}
	>
		<option value="">None</option>
		<option value="Alchemy">Alchemy</option>
		<option value="BlockPi">BlockPi</option>
		<option value="PublicNode">PublicNode</option>
		<option value="Ankr">Ankr</option>
	</select>
	<label for="eth-mainnet-service">Eth Mainnet Service</label>
	<select
		id="eth-mainnet-service"
		on:change={handleInput}
		bind:value={providerMainnet}
	>
		<option value="">None</option>
		<option value="Alchemy">Alchemy</option>
		<option value="BlockPi">BlockPi</option>
		<option value="Cloudflare">Cloudflare</option>
		<option value="PublicNode">PublicNode</option>
		<option value="Ankr">Ankr</option>
	</select> -->
	<div>
		<label for="block-tag-from">Block Tag From</label>
		<select
			id="block-tag-from"
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
		<div>
			<label for="from-block">From Block</label>
			<input
				type="number"
				id="from-block"
				on:change={handleInput}
				bind:value={fromBlock}
				placeholder="From Block"
			/>
		</div>
	{/if}
	<div>
		<label for="block-tag-to">Block Tag To</label>
		<select id="block-tag-to" bind:value={blockTagTo}>
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
		<div>
			<label for="to-block">To Block</label>
			<input
				type="number"
				id="to-block"
				on:change={handleInput}
				bind:value={toBlock}
				placeholder="To Block"
			/>
		</div>
	{/if}
	<div>
		<h3>Addresses</h3>
		{#each addresses as address, index}
			<input
				type="text"
				bind:value={addresses[index]}
				on:input={(e) => updateAddress(index, e)}
				placeholder={`Address ${index + 1}`}
			/>
		{/each}
		<button on:click={addAddress}>Add Address</button>
	</div>
	<div>
		<h3>Topics</h3>
		{#each topics as topic, index}
			<input
				type="text"
				bind:value={topics[index]}
				on:input={(e) => updateTopic(index, e)}
				placeholder={`Topic ${index + 1}`}
			/>
		{/each}
		<button on:click={addTopic}>Add Topic</button>
	</div>
	<div>
		<label for="max-response-size">Max Response Size (Bytes)</label>
		<input
			type="number"
			id="max-response-size"
			bind:value={maxResponseBytes}
			on:input={calculateCost}
			placeholder="Max Response Size (Bytes)"
		/>
	</div>

	<div>
		<label for="estimate-cost">Estimate Cost (Cycles)</label>
		<input
			type="number"
			id="estimate-cost"
			bind:value={estimatedCost}
			placeholder="${estimatedCost}"
		/>
		<button on:click={addCycles}>Add Cycles to Request</button>
	</div>

	<button on:click={callEthGetLogs}>Call eth_getLogs</button>
</div>
