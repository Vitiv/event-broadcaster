<script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";
	import { writable } from "svelte/store";

	let subscriberPrincipal = "";
	let namespace = "";
	let filters = [""];
	let active = false;

	let message = writable(""); // for storing the message to be displayed
	let messageType = writable("");

	const dispatch = createEventDispatcher();

	async function subscribe() {
		const subscription = {
			subscriber: Principal.fromText(subscriberPrincipal),
			namespace,
			filters,
			active,
		};
		const response = await backend.createSubscription(subscription);
		console.log("Subscription registration response: ", response);
		if (response) {
			message.set("Subscription successful");
			messageType.set("success");
			setTimeout(() => {
				message.set("");
				messageType.set("");
			}, 5000);
		} else {
			message.set("Failed to create subscription");
			messageType.set("error");
			setTimeout(() => {
				message.set("");
				messageType.set("");
			}, 6000);
		}
		dispatch("submit", {
			formData: { subscriberPrincipal, namespace, filters, response },
		});
	}

	function addFilter() {
		filters = [...filters, ""];
	}
</script>

<div class="form-container">
	<div class="form-group">
		<label for="subscriberPrincipal">Subscriber</label>
		<input
			id="subscriberPrincipal"
			class="form-input"
			bind:value={subscriberPrincipal}
			placeholder="Enter Subscriber Principal"
		/>
	</div>
	<div class="form-group">
		<label for="namespace">Namespace</label>
		<input
			id="namespace"
			class="form-input"
			bind:value={namespace}
			placeholder="Enter Namespace"
		/>
	</div>
	{#each filters as filter, index}
		<div class="form-group filter-group">
			<label for={`filter-${index}`}>Filter {index + 1}</label>
			<div class="filter-container">
				<input
					id={`filter-${index}`}
					type="text"
					class="form-input-filter"
					bind:value={filters[index]}
					on:input={(e) => (filters[index] = e.target.value)}
					placeholder={`Filter ${index + 1}`}
				/>
				<button class="form-button-filter" on:click={addFilter}
					>Add</button
				>
			</div>
		</div>
	{/each}
	<div
		class="message"
		class:success={$messageType === "success"}
		class:error={$messageType === "error"}
	>
		{$message}
	</div>

	<button class="form-button-subscribe" on:click={subscribe}>Subscribe</button
	>
</div>

<style>
	.form-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1rem;
		/* margin-top: 2rem; */
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
	}

	.form-input,
	.form-input-filter {
		padding: 0.5rem;
		font-size: 1rem;
		border: 1px solid #ccc;
		border-radius: 4px;
		background-color: transparent;
		box-shadow: -5px -5px 15px rgba(158, 246, 244, 0.5);
	}

	.form-input-filter {
		width: 100%;
		margin-right: 20px;
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
		margin-top: 6rem;
		font-size: 1rem;
	}

	.form-button-filter:hover,
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
