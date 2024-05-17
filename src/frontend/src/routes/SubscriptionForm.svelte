<script>
	import { backend } from "$lib/canisters";
	import { Principal } from "@dfinity/principal";
	import { createEventDispatcher } from "svelte";

	let subscriberPrincipal = "";
	let namespace = "";
	let filters = [""];
	let active = false;

	const dispatch = createEventDispatcher();

	async function subscribe() {
		const subscription = {
			subscriber: Principal.fromText(subscriberPrincipal),
			namespace,
			filters,
			active,
		};
		const response = await backend.createSubscription(subscription);
		dispatch("submit", {
			formData: { subscriberPrincipal, namespace, filters, response },
		});
	}

	function addFilter() {
		filters = [...filters, ""];
	}
</script>

<div>
	<input
		bind:value={subscriberPrincipal}
		placeholder="Enter Subscriber Principal"
	/>
	<input bind:value={namespace} placeholder="Enter Namespace" />
	{#each filters as filter, index}
		<input
			type="text"
			bind:value={filters[index]}
			on:input={(e) => (filters[index] = e.target.value)}
			placeholder={`Filter ${index + 1}`}
		/>
	{/each}
	<button on:click={addFilter}>Add Filter</button>
	<button on:click={subscribe}>Subscribe</button>
</div>
