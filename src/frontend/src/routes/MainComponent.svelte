<script>
	import SubscriptionForm from "./SubscriptionForm.svelte";
	import EventForm from "./EventForm.svelte";
	// import EthereumForm from "./EthereumForm.svelte";
	// import CostForm from "./CostForm.svelte";
	import Publication from "./Publication.svelte";

	let response = "";

	function handleSubscriptionFormSubmit(event) {
		const { formData } = event.detail;
		console.log("Received subscription form data:", formData);
	}

	function handleEventFormSubmit(event) {
		const { formData } = event.detail;
		console.log("Received event form data:", formData);
	}

	// function handleEthereumFormSubmit(event) {
	// 	const { formData } = event.detail;
	// 	console.log("Received Ethereum form data:", formData);
	// }

	// function handleCostFormSubmit(event) {
	// 	const { formData } = event.detail;
	// 	console.log("Received cost form data:", formData);
	// }

	function handlePublicationFormSubmit(event) {
		const { formData } = event.detail;
		console.log("Received publication form data:", formData);
	}
</script>

<main>
	<h1>Event Hub 2.0</h1>
	<p>Enter your subscription details:</p>
	<SubscriptionForm on:submit={handleSubscriptionFormSubmit} />
	<p>--------------------------------------------------------</p>
	<p>Enter your Event details:</p>
	<EventForm on:submit={handleEventFormSubmit} />
	<p>--------------------------------------------------------</p>
	<!-- <p>Enter your Ethereum Event details:</p>
	<EthereumForm on:submit={handleEthereumFormSubmit} /> -->
	<p>--------------------------------------------------------</p>
	<p>Enter your Publication details for registration:</p>
	<Publication on:submit={handlePublicationFormSubmit} />
	<div>Response: {response}</div>
	<p>--------------------------------------------------------</p>
	<!-- <p>Estimate cost:</p>
	<CostForm on:submit={handleCostFormSubmit} /> -->
	<p>--------------------------------------------------------</p>
</main>
