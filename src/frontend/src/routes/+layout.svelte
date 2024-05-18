<script>
	import { browser } from "$app/environment";
	import { page } from "$app/stores";
	// import { back } from "$lib/images/back_client.svg";
	// import './styles.css';

	/** @type {import('./$types').LayoutServerData} */
</script>

<div class="app">
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
	<link
		href="https://fonts.googleapis.com/css2?family=Lexend+Zetta:wght@100..900&display=swap"
		rel="stylesheet"
	/>

	<main>
		<slot />
	</main>

	<!-- <footer>
		<p>
			Visit <a
				href="https://github.com/ava-vs/reputation/wiki"
				target="_blank">our Wiki</a
			> to learn more about aVa
		</p>
	</footer> -->
</div>

<style>
	.app {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	main {
		flex: 1;
		display: flex;
		flex-direction: column;
		padding: 1rem;
		width: 100%;
		margin: 0 auto;
		box-sizing: border-box;
	}

	/* footer {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding: 12px;
	}

	footer a {
		font-weight: bold;
	} */

	@media (min-width: 480px) {
		/* footer {
			padding: 12px 0;
		} */
	}
</style>
