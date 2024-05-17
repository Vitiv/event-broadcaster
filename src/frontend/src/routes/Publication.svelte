<script>
    import { backend } from "$lib/canisters";
    import { Principal } from "@dfinity/principal";
    import { createEventDispatcher } from "svelte";

    let subscriberPrincipal = "";
    let namespace = "";
    let statKey = "";
    let statValue = "";
    let stats = [];

    const dispatch = createEventDispatcher();

    function addStat() {
        stats = [...stats, { key: statKey, value: statValue }];
        statKey = "";
        statValue = "";
    }

    async function registerPublication() {
        if (!subscriberPrincipal || !namespace || stats.length === 0) {
            console.log(
                "Please ensure subscriber and namespace fields are filled correctly and at least one stat is added.",
            );
            return;
        }
        const publication = {
            subscriber: Principal.fromText(subscriberPrincipal),
            publications: [
                {
                    namespace,
                    stats: stats.map((stat) => [stat.key, stat.value]),
                },
            ],
        };
        const response = await backend.register_publication(
            publication.subscriber,
            publication.publications,
        );
        dispatch("submit", {
            formData: {
                subscriberPrincipal,
                namespace,
                stats,
                response,
            },
        });
    }
</script>

<div>
    <input
        bind:value={subscriberPrincipal}
        placeholder="Enter Subscriber Principal"
    />
    <input bind:value={namespace} placeholder="Enter Namespace" />

    <div>
        <label for="stat-key">Stat Key:</label>
        <input
            id="stat-key"
            type="text"
            bind:value={statKey}
            placeholder="Enter Stat Key"
        />
    </div>
    <div>
        <label for="stat-value">Stat Value:</label>
        <input
            id="stat-value"
            type="text"
            bind:value={statValue}
            placeholder="Enter Stat Value"
        />
    </div>
    <button on:click={addStat}>Add Stat</button>

    <div>
        <h4>Stats:</h4>
        <ul>
            {#each stats as stat, index}
                <li>{stat.key}: {stat.value}</li>
            {/each}
        </ul>
    </div>

    <button on:click={registerPublication}>Register Publication</button>
</div>
