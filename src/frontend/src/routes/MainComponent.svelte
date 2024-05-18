<script>
	// import { logo } from "$lib/images/logo_hub.svg";
</script>

<main>
	<div class="container">
		<section class="content">
			<h1>EVENT HUB</h1>
			<div class="events">
				<h2>NEARBY EVENTS</h2>
				<ul>
					<!-- <li>24/05/2024 Hackathon</li> -->
					<li>22/06/2024 Motoko Bootcamp</li>
					<!-- <li>24/04/2024 Hackathon</li>
					<li>24/04/2024 Hackathon</li>
					<li>24/04/2024 Hackathon</li> -->
				</ul>
				<a href="https://check.ava.capetown">All Events</a>
			</div>
		</section>
	</div>
</main>

<style>
	.container {
		display: flex;
		flex-direction: column;
		justify-content: flex-start;
		height: 100vh;
		padding: 2rem 1rem;
		color: white;
	}

	.content {
		flex: 1;
		display: flex;
		flex-direction: column;
		justify-content: flex-start;
		align-items: center;
		text-align: center;
		padding-left: 2rem;
	}

	h1 {
		font-family: "Inter", sans-serif;
		font-size: 8em;
		margin: 0;
		/* white-space: nowrap; */
	}

	.events {
		margin-top: 2rem;
		text-align: left;
		width: 100%;
		max-width: 600px;
	}

	.events h2 {
		font-family: "Inter", sans-serif;
		font-size: 2em;
	}

	.events ul {
		list-style: none;
		padding: 0;
	}

	.events li {
		font-family: "Inter", sans-serif;
		font-size: 1.5em;
		margin: 0.5rem 0;
	}

	.events a {
		display: inline-block;
		margin-top: 1rem;
		font-family: "Inter", sans-serif;
		font-size: 1.5em;
		color: white;
		text-decoration: none;
	}

	@media (max-width: 1200px) {
		.content {
			align-items: center;
			text-align: center;
			padding-left: 0;
		}

		h1 {
			font-size: 6em;
		}
	}

	@media (max-width: 1024px) {
		h1 {
			font-size: 5em;
		}

		.events h2 {
			font-size: 1.8em;
		}

		.events li {
			font-size: 1.3em;
		}

		.events a {
			font-size: 1.3em;
		}
	}

	@media (max-width: 768px) {
		h1 {
			font-size: 4em;
		}

		.events h2 {
			font-size: 1.5em;
		}

		.events li {
			font-size: 1.2em;
		}

		.events a {
			font-size: 1.2em;
		}
	}
</style>
