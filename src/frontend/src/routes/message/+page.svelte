<script>
    import "../../index.scss";
    import back from "$lib/images/back_sub.svg";
    import NavMenu from "../Header.svelte";
    import { backend } from "$lib/canisters";

    const menuItems = [
        { name: "Home", href: "/" },
        { name: "Subscription", href: "/subscription" },
        { name: "Publication", href: "/publication" },
        { name: "Event", href: "/event" },
    ];

    let messages = [];
    function getMessages() {
        // messages = ["First message", "Second message", "Third message"];
        backend.getReceivedMessages().then((response) => {
            messages = response;
            console.log("Received messages:", response);
        });
    }
</script>

<main
    style="background-image: url({back}); background-size: cover; background-repeat: no-repeat; background-position: center center; height: 160vh;"
>
    <NavMenu items={menuItems} />
    <p class="form-title" on>Received Messages</p>

    {#if messages.length === 0}
        <p>No messages received yet.</p>
    {:else}
        <ul>
            {#each messages as message}
                <li>Message data: {message.data}</li>
            {/each}
        </ul>
    {/if}
    <button on:click={getMessages}>Get Messages</button>
</main>

<style>
    main {
        justify-content: flex-start;
    }

    .form-title {
        font-size: 1.5rem;
        font-weight: bold;
        color: white;
    }

    ul {
        list-style-type: none;
        padding: 0;
    }

    li {
        margin: 0.5rem 0;
        padding: 0.5rem;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 8px;
    }

    button {
        padding: 0.5rem 1rem;
        background: rgb(58, 244, 216);
        color: black;
        border: none;
        border-radius: 8px;
        cursor: pointer;
    }

    button:hover {
        background: #24bbe1;
    }
</style>
