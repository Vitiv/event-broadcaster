<script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";

	let subscriberPrincipal = "aaaaa-aa";
	let namespace = "";
	let eventData = "";
	let eventType = "";
	let dataType = "Text";

	const dispatch = createEventDispatcher();

	async function publishEvent() {
		const event = {
			namespace,
			source: Principal.fromText(subscriberPrincipal),
			timestamp: Date.now(),
			data: parseData(eventData, dataType),
			id: 2, // updated event ID
		};
		const response = await backend.handleNewEvent(event);
		dispatch("submit", {
			formData: {
				subscriberPrincipal,
				namespace,
				dataType,
				eventData,
				eventType,
				response,
			},
		});
	}

	function parseData(data, type) {
		switch (type) {
			case "Int":
				return { Int: BigInt(data) };
			case "Nat":
				return { Nat: BigInt(data) };
			case "Bool":
				return { Bool: data.toLowerCase() === "true" };
			case "Float":
				return { Float: parseFloat(data) };
			case "Text":
				return { Text: data };
			default:
				throw new Error("Unsupported data type");
		}
	}

	async function publishEventWithResponse() {
		const event = {
			namespace,
			source: Principal.fromText(subscriberPrincipal),
			timestamp: 0,
			data: eventData,
			id: 2, // updated event ID
		};
		const response = await backend.publishEventWithResponse(event);
		dispatch("submit", {
			formData: {
				subscriberPrincipal,
				namespace,
				eventData,
				eventType,
				response,
			},
		});
	}
</script>

<div>
	<div>
		<label for="event-type">Event Type:</label>
		<select id="event-type" bind:value={eventType}>
			<option disabled selected value=""
				>-- Select an Event Type --</option
			>
			<option value="EthereumEvent">Ethereum</option>
			<option value="NFTCanister">NFT</option>
			<option value="News">News</option>
			<option value="OfficialAnnouncement">Official Announcement</option>
			<option value="Other">Other</option>
		</select>
	</div>

	<div>
		<label for="subscriber-principal">Subscriber Principal:</label>
		<input
			id="subscriber-principal"
			type="text"
			bind:value={subscriberPrincipal}
		/>
	</div>

	<div>
		<label for="namespace">Namespace:</label>
		<input id="namespace" type="text" bind:value={namespace} />
	</div>

	<div>
		<label for="dataType">Event Data Type:</label>
		<select id="dataType" bind:value={dataType}>
			<option value="Text">Text</option>
			<option value="Int">Int</option>
			<option value="Nat">Nat</option>
			<option value="Bool">Bool</option>
			<option value="Float">Float</option>
			<!-- Add data types here -->
		</select>
	</div>
	<div>
		<label for="event-data">Event Data:</label>
		<input type="text" id="event-data" bind:value={eventData} required />
	</div>

	<button on:click={publishEvent}>Publish Event</button>
	<button on:click={publishEventWithResponse}
		>Publish Event with Response</button
	>
</div>
