<script>
    import "../../index.scss";
    import back from "$lib/images/back_sub.svg";
    import NavMenu from "../Header.svelte";
    import SubscriptionForm from "./SubscriptionForm.svelte";

    function handleSubscriptionFormSubmit(event) {
        const { formData } = event.detail;
        console.log("Received subscription form data:", formData);
    }

    const menuItems = [
        { name: "Home", href: "/" },
        { name: "Subscription", href: "/subscription" },
        { name: "Publication", href: "/publication" },
        { name: "Event", href: "/event" },
    ];
</script>

<main
    style="background-image: url({back}); background-size: cover; background-repeat: no-repeat; background-position: center center; height: 100vh; "
>
    <NavMenu items={menuItems} />
    <div class="form-wrapper">
        <p class="form-title">Subscribe to event</p>
        <SubscriptionForm on:submit={handleSubscriptionFormSubmit} />
    </div>
</main>

<style>
    main {
        justify-content: flex-start;
    }

    .form-wrapper {
        background: transparent;
        /* padding: 1rem; */
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
</style>
