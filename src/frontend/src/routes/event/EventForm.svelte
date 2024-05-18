<script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";

	let publisherPrincipal = "aaaaa-aa";
	let namespace = "";
	let eventData = "";
	let eventType = "";
	let dataType = "Text";

	const dispatch = createEventDispatcher();

	async function publishEvent() {
		console.log("publishEvent: Publisher: ", publisherPrincipal);
		const event = {
			namespace,
			source: Principal.fromText(publisherPrincipal),
			timestamp: Date.now(),
			data: parseData(eventData, dataType),
			id: 2, // updated event ID
		};
		const response = await backend.handleNewEvent(event);
		dispatch("submit", {
			formData: {
				publisherPrincipal,
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
		console.log(
			"publishEventWithResponse: Publisher: ",
			publisherPrincipal,
		);
		const event = {
			namespace,
			source: Principal.fromText(publisherPrincipal),
			timestamp: 0,
			data: eventData,
			id: 2, // updated event ID
		};
		const response = await backend.handleNewEvent(event);
		dispatch("submit", {
			formData: {
				publisherPrincipal,
				namespace,
				eventData,
				eventType,
				response,
			},
		});
	}
</script>

<div class="form-container">
	<div class="form-group">
		<label for="publisher-principal">Publisher</label>
		<input
			id="publisher-principal"
			class="form-input"
			type="text"
			bind:value={publisherPrincipal}
		/>
	</div>

	<div class="form-group">
		<label for="namespace">Namespace</label>
		<input
			id="namespace"
			class="form-input"
			type="text"
			bind:value={namespace}
		/>
	</div>

	<div class="form-group">
		<label for="dataType">Event Data Type</label>
		<select id="dataType" class="form-input" bind:value={dataType}>
			<option value="Text">Text</option>
			<option value="Int">Int</option>
			<option value="Nat">Nat</option>
			<option value="Bool">Bool</option>
			<option value="Float">Float</option>
			<!-- Add data types here -->
		</select>
	</div>

	<div class="form-group filter-group">
		<label for="event-data">Event Data</label>
		<div class="filter-container">
			<input
				id="event-data"
				class="form-input-filter"
				type="text"
				bind:value={eventData}
				required
			/>
			<button class="form-button-filter" on:click={publishEvent}
				>Publish</button
			>
		</div>
	</div>

	<button class="form-button-subscribe" on:click={publishEventWithResponse}>
		Publish Event with Response
	</button>
</div>

<!-- <script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";

	let publisherPrincipal = "aaaaa-aa";
	let namespace = "";
	let eventData = "";
	let eventType = "";
	let dataType = "Text";

	const dispatch = createEventDispatcher();

	async function publishEvent() {
		console.log("publishEvent: Publisher: ", publisherPrincipal);
		const event = {
			namespace,
			source: Principal.fromText(publisherPrincipal),
			timestamp: Date.now(),
			data: parseData(eventData, dataType),
			id: 2, // updated event ID
		};
		const response = await backend.handleNewEvent(event);
		dispatch("submit", {
			formData: {
				publisherPrincipal,
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
		console.log(
			"publishEventWithResponse: Publisher: ",
			publisherPrincipal,
		);
		const event = {
			namespace,
			source: Principal.fromText(publisherPrincipal),
			timestamp: 0,
			data: eventData,
			id: 2, // updated event ID
		};
		const response = await backend.handleNewEvent(event);
		dispatch("submit", {
			formData: {
				publisherPrincipal,
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
		<label for="publisher-principal">Publisher:</label>
		<input
			id="publisher-principal"
			type="text"
			bind:value={publisherPrincipal}
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
</div> -->

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

	.form-button-filter:hover,
	.form-button-subscribe:hover {
		background-color: #24bbe1;
	}
</style>
