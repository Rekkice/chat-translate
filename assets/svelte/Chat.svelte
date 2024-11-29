<script lang="ts">
  // TODO add actual i18n, where each UI component shows lang1 | lang2 instead of hardcoded spanish | english
  import { onMount, tick } from "svelte";

  import QRCode from "easyqrcodejs";

  import { alertStore } from "./AlertStore.js";
  import Alert from "./Alert.svelte";

  interface Message {
    sender: string;
    content_lang1: string;
    content_lang2: string;
    timestamp: Date;
  }

  export let initialMessages: any[];
  export let lang1: string;
  export let lang2: string;
  export let live;

  let node;
  let chatInput;
  let createdQR = false;

  export let username: string;

  let messages: Message[] = [];
  messages = initialMessages.map((message) => {
    return {
      sender: message.username,
      content_lang1: message.content_lang1,
      content_lang2: message.content_lang2,
      timestamp: new Date(message.inserted_at),
    };
  });


  async function scrollToBottom(_value: any) {
    if (typeof window == "undefined") return;
    let chatbox = document.getElementById("chatbox");
    await tick();
    if (chatbox) chatbox.scrollTop = chatbox.scrollHeight;
  }

  function sendMessage(e) {
    const input = e.srcElement[0] || e.target;
    live.pushEvent("send_message", {
      content: input.value,
      username: username,
    });
    input.value = "";
  }

  function enterUsername(e) {
    const input = e.srcElement[0];
    username = input.value;
    setTimeout(() => {
      createQR()
    }, 15);
  }

  onMount(() => {
    scrollToBottom(null);

    if (live) {
      live.handleEvent("received_message", (data) => {
        const message: Message = {
          content_lang1: data.message.content_lang1,
          content_lang2: data.message.content_lang2,
          sender: data.message.username,
          timestamp: new Date(data.message.inserted_at),
        };
        messages = [...messages, message];
      });

      live.handleEvent("received_alert", ({ message, type }) => {
        triggerAlert(message, type);
      });
    }
  });

  function createQR() {
    if (typeof window == "undefined" || !node) return;
    const options = {
      text: window.location.href,
      width: 512,
      height: 512,
      quietZone: 10,
      colorDark: "#4c4f69",
      colorLight: "#eff1f5",
    };
    createdQR = true;
    new QRCode(node, options);
  }

  function handleKeyDown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      sendMessage(event);
    }
  }

  function getLocaleDate(date: Date) {
    return date.toLocaleString(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "numeric",
      hour12: false,
    });
  }

  function triggerAlert(message: string, type = "info") {
    alertStore.set({ message, type });
  }

  $: scrollToBottom(messages);
</script>

<Alert />

<div class="mx-auto sm:grid sm:grid-cols-2 mt-14 sm:px-4 justify-center gap-4">
  {#if username}
    <div
      class="h-full justify-center items-center hidden sm:flex flex-col gap-8"
    >
      <h2
        class="text-2xl bg-mantle px-8 py-8 rounded-xl text-text w-4/6 text-center"
      >
        Únete al grupo escaneando este código
        <hr class="border-teal my-2" />
        Join the groupchat by scanning this code
      </h2>

      <div
        class="bg-mantle rounded-xl w-4/6 aspect-square relative border-2 border-crust"
        bind:this={node}
      >
        {#if !createdQR}
          <button class="size-full text-3xl" on:click={() => createQR()}
            >Mostrar | Show</button
          >
        {/if}
      </div>
    </div>
    <section
      class="max-w-2xl bg-mantle sm:border-crust border-2 sm:rounded-xl w-full sm:p-4 pt-2 relative"
    >
      <div
        class="overflow-y-auto h-[calc(100vh-9.5rem)] sm:h-[calc(100vh-13.5rem)] text-seagull-800 flex flex-col gap-0 mb-2 px-2"
        id="chatbox"
      >
        {#each messages as message}
          <div class="w-full gap-1 px-2 rounded-xl flex flex-col">
            <div
              class="relative font-medium whitespace-nowrap text-xl bg-base w-fit px-2 py-0 pb-3 rounded-t-xl translate-y-4 {message.sender ==
              username
                ? 'text-peach'
                : 'text-sapphire'}"
            >
              {message.sender}
              <span
                class="text-overlay2 text-xs absolute bottom-0 top-0 h-fit translate-x-4 translate-y-1.5"
                >{getLocaleDate(message.timestamp)}</span
              >
            </div>
            <div class="w-full h-full bg-base rounded-xl px-2 z-10">
              <div class="break-all text-text relative py-4 pt-2">
                {message.content_lang1}
                <div
                  class="absolute bg-white -top-3 right-0 h-6 p-1 rounded-lg flex flex-row items-center justify-center gap-1 border border-crust"
                >
                  <svg
                    class="size-[14px] fill-teal aspect-square"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 -960 960 960"
                    ><path
                      d="m476-80 182-480h84L924-80h-84l-43-122H603L560-80h-84ZM160-200l-56-56 202-202q-35-35-63.5-80T190-640h84q20 39 40 68t48 58q33-33 68.5-92.5T484-720H40v-80h280v-80h80v80h280v80H564q-21 72-63 148t-83 116l96 98-30 82-122-125-202 201Zm468-72h144l-72-204-72 204Z"
                    /></svg
                  >
                  <div class="text-subtext0 text-xs text-nowrap">{lang1}</div>
                </div>
              </div>
              <hr class="border-teal" />
              <div class="break-all text-text relative py-4 pb-2">
                {message.content_lang2}
                <div
                  class="absolute bg-white -top-1 right-0 h-6 p-1 rounded-lg flex flex-row items-center justify-center gap-1 border border-crust"
                >
                  <svg
                    class="size-[14px] fill-teal"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 -960 960 960"
                    ><path
                      d="m476-80 182-480h84L924-80h-84l-43-122H603L560-80h-84ZM160-200l-56-56 202-202q-35-35-63.5-80T190-640h84q20 39 40 68t48 58q33-33 68.5-92.5T484-720H40v-80h280v-80h80v80h280v80H564q-21 72-63 148t-83 116l96 98-30 82-122-125-202 201Zm468-72h144l-72-204-72 204Z"
                    /></svg
                  >
                  <div class="text-subtext0 text-xs text-nowrap">{lang2}</div>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
      <form
        on:submit|preventDefault={sendMessage}
        bind:this={chatInput}
        class="flex gap-4 px-2 pb-2 sm:pb-0 sm:px-0"
      >
        <textarea
          class="w-full resize-none h-fit rounded-lg border-crust"
          minlength="1"
          maxlength="300"
          required
          on:keydown={handleKeyDown}
        />
        <button class="w-16 p-2 fill-peach flex justify-center items-center">
          <svg
            class="size-12"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 -960 960 960"
            ><path
              d="M120-160v-640l760 320-760 320Zm80-120 474-200-474-200v140l240 60-240 60v140Zm0 0v-400 400Z"
            /></svg
          >
        </button>
      </form>
    </section>
  {:else}
    <div
      class="absolute left-0 top-0 w-full h-full flex justify-center items-center"
    >
      <div
        class="w-fit h-fit bg-base shadow-lg border-2 border-rosewater py-8 px-12 rounded-2xl flex flex-col gap-8 items-center justify-center"
      >
        <h1 class="text-2xl text-text text-center">
          Introduce tu nombre | Enter your name
        </h1>
        <form on:submit|preventDefault={enterUsername}>
          <input
            class="w-full border-crust bg-mantle border-2"
            type="text"
            minlength="1"
            maxlength="16"
            required
          />
        </form>
      </div>
    </div>
  {/if}
</div>

<style>
  div :global(canvas) {
    /* fit QR to wrapper */
    width: 100%;
    height: 100%;
    position: absolute;
    left: 0;
    top: 0;
    border-radius: 0.75rem;
  }
</style>
