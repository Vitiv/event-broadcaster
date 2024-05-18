<script>
  import "../index.scss";
  import MainComponent from "./MainComponent.svelte";
  import NavMenu from "./Header.svelte";
  import back from "$lib/images/back_client.svg";

  const menuItems = [
    { name: "Home", href: "/" },
    { name: "Subscription", href: "/subscription" },
    { name: "Publication", href: "/publication" },
    { name: "Event", href: "/event" },
  ];
</script>

<svelte:head>
  <title>Event Hub</title>
  <meta name="description" content="Combine pub-sub app" />
</svelte:head>
<main
  style="background-image: url({back}); background-size: cover; background-repeat: no-repeat; background-position: center center; height: 100vh;"
>
  <NavMenu items={menuItems} />
  <MainComponent />
</main>
