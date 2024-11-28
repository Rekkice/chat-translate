<script>
  import { alertStore } from "./AlertStore.js";
  import { onDestroy } from "svelte";

  let alert = null;

  const unsubscribe = alertStore.subscribe((value) => {
    alert = value;
    if (alert) {
      setTimeout(() => {
        alertStore.set(null);
      }, 5000);
    }
  });

  onDestroy(() => {
    unsubscribe();
  });
</script>

{#if alert}
  <div
    class={`absolute top-8 left-0 right-0 sm:left-auto sm:right-16 z-50 p-4 mb-4 rounded-md shadow flex items-center justify-between bg-base border-2
               ${alert.type === "info" ? "border-lavender/50" : ""} 
               ${alert.type === "success" ? "border-sky" : ""} 
               ${alert.type === "warning" ? "border-yellow" : ""} 
               ${alert.type === "error" ? "border-red" : ""}`}
  >
    <span class="flex-1">{alert.message}</span>
    <button
      on:click={() => alertStore.set(null)}
      class="ml-4 text-xl font-bold text-text hover:text-subtext0"
      >&times;</button
    >
  </div>
{/if}
