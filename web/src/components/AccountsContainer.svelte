<script lang="ts">
  import AccountsList from "./Accounts/AccountsList.svelte";
  import AccountTransactionsList from "./Accounts/AccountTransactionsList.svelte";
  import AccountManagementPanel from "./AccountManagement/AccountManagementPanel.svelte";
  import { visibility, atm, accounts } from "../store/stores";
  import { fetchNui } from "../utils/fetchNui";
  import { onMount } from "svelte";
  import { activeTab } from '../store/stores'
  import InvoicesList from "./InvoicesList.svelte";
  import { fly } from "svelte/transition";
  import { useNuiEvent } from "$utils/useNuiEvent";
  let showAccountManagement = false;
  let canManageAccounts = false;
  let canCreateAccounts = false;

  useNuiEvent('setManagementConfig', (data: boolean) => {
    canManageAccounts = data;
    canCreateAccounts = data;
  })

  function refreshBankData() {
    fetchNui("hype_banking:client:getBankData").then((resp) => {
      if (resp) {
        accounts.set(resp);
      }
    });
  }
</script>

<div
  class="absolute w-[90%] h-[90%] bottom-[5%] left-[5%] overflow-hidden animate-fadeIn"
  transition:fly={{ y: 500, duration: 500 }}
>
  <div
    class="w-full h-full bg-fleeca-bg rounded-xl shadow-card overflow-hidden relative"
  >
    <div class="relative z-10 w-full h-full p-6 flex flex-col">
      <div class="flex justify-between items-center mb-6">
        <div class="flex items-center">
          <div class="w-10 h-10 flex items-center justify-center mr-3">
            <i class="fas fa-university text-fleeca-green text-2xl"></i>
          </div>
          <div>
            <h1 class="text-2xl font-bold text-fleeca-text font-display">
              Fleeca
            </h1>
            <p class="text-fleeca-green text-sm font-medium">Online Banking</p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          {#if canCreateAccounts && !$atm}
            <button
              class="py-2 px-4 bg-fleeca-card hover:bg-fleeca-hover flex items-center justify-center transition-colors border border-fleeca-border rounded-md"
              on:click={() => (showAccountManagement = !showAccountManagement)}
            >
              <i class="fas fa-users-cog text-fleeca-green mr-2"></i>
              <span class="text-fleeca-text text-sm">Manage Accounts</span>
            </button>
          {/if}

          <button
            aria-label="Close"
            class="w-10 h-10 rounded-full bg-fleeca-card hover:bg-fleeca-hover flex items-center justify-center transition-colors border border-fleeca-border"
            on:click={() => {
              fetchNui("closeInterface");
              visibility.set(false);
            }}
          >
            <i class="fa-solid fa-xmark text-fleeca-text-secondary"></i>
          </button>
        </div>
      </div>

      <div class="flex gap-6 h-[calc(100%-4rem)] overflow-hidden">
        <AccountsList/>
        {#if $activeTab === "banking"}
          <AccountTransactionsList />
        {:else}
          <InvoicesList/>
        {/if}
      </div>
    </div>
  </div>
</div>

{#if showAccountManagement && !$atm}
  <AccountManagementPanel
    isVisible={true}
    canCreateAccounts={canCreateAccounts}
    onClose={() => (showAccountManagement = false)}
    onAccountChange={refreshBankData}
  />
{/if}
