<script>
    import { backend } from "$lib/canisters";
    import { Principal } from "@dfinity/principal";
    import { createEventDispatcher } from "svelte";
    import { writable } from "svelte/store";

    let publisher = "";
    let namespace = "";

    let message = writable(""); // for storing the message to be displayed
    let messageType = writable(""); // for storing the type of message to be displayed (success or error)

    const dispatch = createEventDispatcher();

    async function registerPublication() {
        if (!publisher || !namespace) {
            console.log(
                "Please ensure publisher and namespace fields are filled correctly and at least one stat is added.",
            );
            return;
        }
        const publication = {
            publisher: Principal.fromText(publisher),
            namespace: namespace,
        };
        console.log("Publication ready to registration: ", publication);
        try {
            const response = await backend.register_publication(
                publication.publisher,
                namespace,
            );
            // response =  Bool
            console.log("Publication registration response: ", response);
            const success = response;
            if (success) {
                message.set("Publication registered successfully.");
                messageType.set("success");
            } else {
                message.set(
                    "Failed to register publication for some namespaces.",
                );
                messageType.set("error");
            }
        } catch (error) {
            message.set("An error occurred during registration.");
            messageType.set("error");
        }

        dispatch("submit", {
            formData: {
                publisher,
                namespace,
                response,
            },
        });
    }
</script>

<div class="form-container">
    <div class="form-group">
        <label for="publisher">Publisher</label>
        <input
            id="publisher"
            class="form-input"
            bind:value={publisher}
            placeholder="Enter publisher"
        />
    </div>
    <div class="form-group">
        <label for="namespace">Namespace</label>
        <input
            id="namespace"
            class="form-input"
            bind:value={namespace}
            placeholder="Enter Namespace"
        />
    </div>
    <button class="form-button-register" on:click={registerPublication}
        >Register Publication</button
    >
    <div
        class="message"
        class:success={$messageType === "success"}
        class:error={$messageType === "error"}
    >
        {$message}
    </div>
</div>

<style>
    .form-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;
    }

    .form-group {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        width: 100%;
        max-width: 400px;
    }

    .form-group label {
        font-family: "Lexend Zetta", sans-serif;
        margin-bottom: 0.5rem;
        font-weight: bold;
        font-size: 0.8rem;
        color: white;
    }

    /* .filter-group {
        display: flex;
        flex-direction: column;
    }

    .filter-container {
        display: flex;
        align-items: center;
        width: 100%;
    } */

    .form-input {
        width: 100%;
        max-width: 400px;
    }

    .form-input {
        padding: 0.5rem;
        font-size: 1rem;
        border: 1px solid #ccc;
        border-radius: 4px;
        background-color: transparent;
        box-shadow: -5px -5px 15px rgba(158, 246, 244, 0.5);
    }

    /* .form-input-filter {
        width: calc(100% - 80px);
        margin-right: 10px;
    } */

    .form-input::placeholder {
        font-family: "Lexend Zetta", sans-serif;
        font-size: 0.7rem;
        color: white;
        opacity: 1;
    }

    .form-input:focus {
        border-color: #06636c;
        box-shadow: 0 0 15px rgba(0, 123, 255, 0.5);
        outline: none;
    }

    .form-button-register {
        font-family: "Lexend Zetta", sans-serif;
        border: white 1px solid;
        border-radius: 10px;
        background-color: transparent;
        color: white;
        cursor: pointer;
        transition: background-color 0.3s;
    }

    /* .form-button-filter {
        padding: 0.4rem;
        max-width: 60px;
        font-size: 0.9rem;
    } */

    .form-button-register {
        padding: 0.5rem;
        width: 100%;
        max-width: 200px;
        margin-top: 2.5rem;
        font-size: 1rem;
    }

    .form-button-register:hover {
        background-color: #24bbe1;
    }

    .message {
        margin-top: 1rem;
        padding: 0.5rem;
        border-radius: 5px;
        font-family: "Lexend Zetta", sans-serif;
    }

    .success {
        color: #1cd41c;
        background-color: #d4edda;
        border-color: #c3e6cb;
    }

    .error {
        color: #721c24;
        background-color: #f8d7da;
        border-color: #f5c6cb;
    }
</style>
