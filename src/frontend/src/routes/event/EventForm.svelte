<script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";
	import { writable } from "svelte/store";

	let message = writable("");
	let messageType = writable(""); // for storing the type of message to be displayed (success or error)

	let publisherPrincipal = "mmt3g-qiaaa-aaaal-qi6ra-cai";
	let namespace = "";
	let eventData = "";
	let eventType = "";
	let dataType = "Text";

	const dispatch = createEventDispatcher();

	let number = 0;

	function addRandomNumber() {
		const randomNum = Math.floor(Math.random() * 1000);
		number += randomNum;
	}

	async function publishEvent() {
		console.log("publishEvent: Publisher: ", publisherPrincipal);
		addRandomNumber();
		const event = {
			id: number, // new event ID
			namespace,
			source: Principal.fromText(publisherPrincipal),
			data: eventData,
			dataType: dataType,
		};
		const response = await backend.createEvent(event);
		console.log("Publish Response: ", response);
		if (response) {
			message.set("Event published successfully.");
			messageType.set("success");
		} else {
			message.set("Failed to published event");
			messageType.set("error");
		}

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

	async function publishEventWithResponse() {
		console.log(
			"publishEventWithResponse: Publisher: ",
			publisherPrincipal,
		);
		addRandomNumber();
		const event = {
			id: 2 + number, // new event ID
			namespace,
			source: Principal.fromText(publisherPrincipal),
			data: eventData,
			dataType: dataType,
		};
		const response = await backend.createEvent(event);
		if (response) {
			message.set("Event published successfully.");
			messageType.set("success");
		} else {
			message.set("Failed to published event");
			messageType.set("error");
		}
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
		<label for="data-type">Event Data Type</label>
		<select id="data-type" class="form-input" bind:value={dataType}>
			<option value="Text">Text</option>
			<option value="Int">Int</option>
			<option value="Nat">Nat</option>
			<option value="Bool">Bool</option>
			<option value="Float">Float</option>
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
			<button class="form-button-data" on:click={publishEvent}
				>Publish</button
			>
		</div>
	</div>
	<div
		class="message"
		class:success={$messageType === "success"}
		class:error={$messageType === "error"}
	>
		{$message}
	</div>

	<button class="form-button-subscribe" on:click={publishEventWithResponse}>
		Publish Event with Response
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

	.form-input {
		color: rgb(58, 244, 216);
	}

	#data-type {
		font-family: "Lexend Zetta", sans-serif;
		margin-bottom: 0.5rem;
		font-weight: bold;
		font-size: 1rem;
		color: rgb(58, 244, 216);
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
		color: rgb(58, 244, 216);
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

	.form-button-data,
	.form-button-subscribe {
		font-family: "Lexend Zetta", sans-serif;
		border: white 1px solid;
		border-radius: 10px;
		background-color: transparent;
		color: white;
		cursor: pointer;
		transition: background-color 0.3s;
	}

	.form-button-data {
		padding: 0.4rem;
		max-width: 120px;
		font-size: 0.9rem;
	}

	.form-button-subscribe {
		padding: 0.5rem;
		width: 100%;
		max-width: 200px;
		margin-top: 1.5rem;
		font-size: 1rem;
	}

	.form-button-data:hover,
	.form-button-subscribe:hover {
		background-color: #24bbe1;
	}

	.message {
		margin-top: 1rem;
		padding: 0.5rem;
		border-radius: 5px;
		font-family: "Lexend Zetta", sans-serif;
	}

	.success {
		color: #1cd41c;
		background-color: #d4edda;
		border-color: #c3e6cb;
	}

	.error {
		color: #721c24;
		background-color: #f8d7da;
		border-color: #f5c6cb;
	}
</style>
