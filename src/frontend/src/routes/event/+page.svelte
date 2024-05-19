<script>
    import "../../index.scss";
    import back from "$lib/images/back_sub.svg";
    import NavMenu from "../Header.svelte";
    import EventForm from "./EventForm.svelte";
    import EthereumForm from "./EthereumForm.svelte";

    const menuItems = [
        { name: "Home", href: "/" },
        { name: "Subscription", href: "/subscription" },
        { name: "Publication", href: "/publication" },
    ];

    function handleEventFormSubmit(event) {
        const { formData } = event.detail;
        console.log("Received event form data:", formData);
    }

    function handleEthereumFormSubmit(event) {
        const { formData } = event.detail;
        console.log("Received Ethereum form data:", formData);
    }
    let eventType = "";
</script>

<main
    style="background-image: url({back}); background-size: cover; background-repeat: no-repeat; background-position: center center; height: 190vh;"
>
    <NavMenu items={menuItems} />
    <div class="form-wrapper">
        <p class="form-title">Publish Event</p>

        <label for="event-type">Event Type:</label>
        <select id="event-type" bind:value={eventType}>
            <option disabled selected value="">- Select Event Type -</option>
            <option value="EthereumEvent">Ethereum</option>
            <option value="NFTCanister">NFT</option>
            <option value="News">News</option>
            <option value="OfficialAnnouncement">Official Announcement</option>
            <option value="Other">Other</option>
        </select>
    </div>

    {#if eventType === "EthereumEvent"}
        <EthereumForm on:submit={handleEthereumFormSubmit} />
    {:else}
        <EventForm on:submit={handleEventFormSubmit} />
    {/if}
</main>

<style>
    main {
        justify-content: flex-start;
    }

    .form-wrapper {
        background: transparent;
        border-radius: 8px;
        text-align: center;
        max-width: 600px;
        margin: auto;
    }

    .form-title {
        font-size: 1.5rem;
        font-family: "Lexend Zetta", sans-serif;
        margin-bottom: 2rem;
        color: white;
    }

    .form-wrapper label {
        font-family: "Lexend Zetta", sans-serif;
        font-weight: bold;
        font-size: 1rem;
        color: white;
        margin-left: 15px;
    }

    #event-type {
        font-family: "Lexend Zetta", sans-serif;
        font-weight: bold;
        font-size: 0.75rem;
        color: rgb(33, 203, 175);
        margin-bottom: 2rem;
    }
    #event-type option {
        background-color: #333;
        color: white;
    }
</style>
