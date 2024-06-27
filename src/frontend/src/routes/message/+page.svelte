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
        // let m = {
        //     data: { Text: "Third message" },
        // };

        // messages = [
        //     { data: { Text: "First message" } },
        //     { data: { Text: "Second message" } },
        //     m,
        // ];
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
    <div class="content">
        <p class="form-title">Received Messages</p>
        <div class="message-box">
            {#if messages.length === 0}
                <p>No messages received yet.</p>
            {:else}
                <ul>
                    {#each messages as message}
                        <li>Message data: {message.data.Text}</li>
                    {/each}
                </ul>
            {/if}
        </div>
        <button on:click={getMessages}>Get Messages</button>
    </div>
</main>

<style>
  

    .content {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        width: 100%;
        max-width: 600px;
        margin-left: 30%;
    }

    .form-title {
        font-size: 1.5rem;
        font-weight: bold;
        color: white;
        margin-bottom: 1rem;
    }

    .message-box {
        margin: 1rem;
        padding: 1rem;
        background: white;
        border-radius: 8px;
        width: 100%;
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
    @media (max-width: 1024px) {
        .content {
            margin-left: 25%;
        }
    }
    @media (max-width: 768px) {
        .content {
            margin-left: 20px;
        }
    }
</style>
