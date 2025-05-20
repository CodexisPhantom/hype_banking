<script>
  import Banking from "./Banking.svelte";
  import Phone from "./components/Phone.svelte";
  import { fetchNui } from "$utils/fetchNui";
  import { onMount } from "svelte";

  $: phoneLoaded = false;
  window.addEventListener("message", (event) => {
    if (event.data === "componentsLoaded") {
      phoneLoaded = true;
    }
  });

  setTimeout(() => {
    fetchNui('appReady', {}).catch((err) => {});
  }, 1000);

</script>

{#if phoneLoaded}
  <Phone />
{:else}
  <Banking />
{/if}