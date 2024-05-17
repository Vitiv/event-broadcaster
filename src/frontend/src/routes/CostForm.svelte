<script>
	import { getRpcCost } from "$lib/cost";
	import { createEventDispatcher } from "svelte";

	let selectedEthMainnetService = "";
	let selectedEthSepoliaService = "";
	let addresses = [""];
	let topics = [""];
	let fromBlockTag = "";
	let fromBlockNumber = "";
	let toBlockTag = "";
	let toBlockNumber = "";
	let maxResponseBytes = 1000;
	let estimatedCost = 0;

	const dispatch = createEventDispatcher();

	function getTextSize(text) {
		const textEncoder = new TextEncoder();
		return textEncoder.encode(text).length;
	}

	function estimatePayloadSize() {
		const addressSize = addresses.reduce(
			(acc, address) => acc + getTextSize(address),
			0,
		);
		const topicSize = topics.reduce(
			(acc, topic) => acc + getTextSize(topic),
			0,
		);
		const blockTagSize = 8;
		return addressSize + topicSize + 2 * blockTagSize;
	}

	function calculateCost() {
		const payloadSizeBytes = estimatePayloadSize();
		const service = {
			api: selectedEthMainnetService ? "EthMainnet" : "EthSepolia",
			provider: selectedEthMainnetService
				? selectedEthMainnetService
				: selectedEthSepoliaService,
		};
		estimatedCost = getRpcCost(service, payloadSizeBytes, maxResponseBytes);
		console.log(`Estimated cost: ${estimatedCost}`);
	}

	$: calculateCost();

	function handleInput() {
		calculateCost();
	}
</script>

<div>
	<h2>Calculate Cost</h2>
	<label for="max-response-bytes">Max Response Bytes:</label>
	<input
		type="number"
		id="max-response-bytes"
		bind:value={maxResponseBytes}
		on:input={handleInput}
	/>
	<div>
		<h3>Addresses</h3>
		{#each addresses as address, index}
			<input
				type="text"
				bind:value={addresses[index]}
				on:input={handleInput}
				placeholder={`Address ${index + 1}`}
			/>
		{/each}
	</div>
	<div>
		<h3>Topics</h3>
		{#each topics as topic, index}
			<input
				type="text"
				bind:value={topics[index]}
				on:input={handleInput}
				placeholder={`Topic ${index + 1}`}
			/>
		{/each}
	</div>
	<label for="fromBlock">From Block:</label>
	<select id="fromBlock" bind:value={fromBlockTag}>
		<option value="">Select Block Tag</option>
		<option value="Earliest">Earliest</option>
		<option value="Safe">Safe</option>
		<option value="Finalized">Finalized</option>
		<option value="Latest">Latest</option>
		<option value="Number">Number</option>
		<option value="Pending">Pending</option>
	</select>

	{#if fromBlockTag === "Number"}
		<input
			type="number"
			bind:value={fromBlockNumber}
			placeholder="Enter Block Number"
		/>
	{/if}

	<label for="toBlock">To Block:</label>
	<select id="toBlock" bind:value={toBlockTag}>
		<option value="">Select Block Tag</option>
		<option value="Earliest">Earliest</option>
		<option value="Safe">Safe</option>
		<option value="Finalized">Finalized</option>
		<option value="Latest">Latest</option>
		<option value="Number">Number</option>
		<option value="Pending">Pending</option>
	</select>

	{#if toBlockTag === "Number"}
		<input
			type="number"
			bind:value={toBlockNumber}
			placeholder="Enter Block Number"
		/>
	{/if}

	<p>Estimated cost: {estimatedCost} cycles</p>
</div>
