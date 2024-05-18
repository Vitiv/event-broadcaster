<script>
    import "../../index.scss";
    import back from "$lib/images/back_sub.svg";
    import NavMenu from "../Header.svelte";
    import Publication from "./Publication.svelte";

    function handlePublicationFormSubmit(event) {
        const { formData } = event.detail;
        console.log("Received publication form data:", formData);
    }

    const menuItems = [
        { name: "Home", href: "/" },
        { name: "Subscription", href: "/subscription" },
        { name: "Event", href: "/event" },
    ];
</script>

<main
    style="background-image: url({back}); background-size: cover; background-repeat: no-repeat; background-position: center center; height: 100vh;"
>
    <NavMenu items={menuItems} />
    <div class="form-wrapper">
        <p class="form-title">Register Publication</p>
        <Publication on:submit={handlePublicationFormSubmit} />
    </div>
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
</style>
