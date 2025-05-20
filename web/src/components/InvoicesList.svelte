<script lang="ts">
  import { phoneData, translations } from "../store/stores";
  import { onMount } from "svelte";
  import { fetchNui } from "$utils/fetchNui";
  import { invoices, notify } from "../store/stores";
  import type { InvoiceProps } from "src/types/invoices";
  import InvoiceItem from "./Invoices/InvoiceItem.svelte";
  import { fly } from "svelte/transition";
  import { formatMoney } from "$utils/misc";
  import { get } from "svelte/store";
  $: translationsValue = get(translations);

  onMount(() => {
    fetchNui<InvoiceProps[]>("hype_banking:client:getInvoices").then((data) => {
      invoices.set(data);
    });
  });

  function payInvoice(args: InvoiceProps) {
    fetchNui("hype_banking:client:payInvoice", args).then((resp) => {
      if (resp && resp.status === "success") {
        invoices.update((invoices) => {
          return invoices.map((invoice) => {
            if (invoice.invoice_id === args.invoice_id) {
              invoice.status = "paid";
            }
            return invoice;
          });
        });

        phoneData.update((prev) => ({
          ...prev,
          balance: resp.balance,
        }));

      } else if (resp && resp.status === "nobalance") {
        notify.set({
          message: "Not enough balance",
          title: "Error",
          type: "error",
        });
      }
    });
  }

  let transSearch = "";
  $: paidInvoices = $invoices.filter(
    (invoice) => invoice.status === "paid"
  ).length;
  $: unpaidInvoices = $invoices.filter(
    (invoice) => invoice.status === "unpaid"
  ).length;
  $: pendingInvoices = $invoices.filter(
    (invoice) => invoice.status === "pending"
  ).length;
  $: totalPendingInvoices = $invoices
    .filter((invoice) => invoice.status === "pending")
    .reduce((acc, invoice) => acc + invoice.total, 0);

  let showPendingPopup = false;
  
  function payAllPendingInvoices() {
    fetchNui("hype_banking:client:payAllPendingInvoices").then((resp) => {
      if (resp && resp.status === "success") {
        invoices.update((invoices) => {
          return invoices.map((invoice) => {
            if (invoice.status === "pending") {
              invoice.status = "paid";
            }
            return invoice;
          });
        });
      }
    })
    showPendingPopup = false;
  }
</script>

<section
  transition:fly={{
    y: 500,
    duration: 500,
  }}
  class="flex-1 overflow-hidden flex flex-col"
>
  <div
    class="bg-fleeca-card rounded-xl mb-6 shadow-lg overflow-hidden border border-fleeca-border"
  >
    <div
      class="p-6 bg-gradient-to-r from-fleeca-green/90 to-fleeca-dark-green text-white"
    >
      <div class="flex justify-between items-start mb-4">
        <div>
          <h2
            class="text-xs uppercase tracking-wider text-white/80 font-medium mb-1"
          >
            {translationsValue.invoices || "Invoices"}
          </h2>
        </div>
      </div>

      <div class="mb-4">
        <div class="text-4xl font-bold" style="transition: none;">
          {translationsValue.personal_invoices || "Personal Invoices"}
        </div>
      </div>
      <div class="flex justify-between items-start mb-4">
        <div>
          <h2
            class="text-xs uppercase tracking-wider text-white/80 font-medium mb-1"
          >
            {(translationsValue.total_pending || "%s Total Pending").replace("%s", formatMoney(totalPendingInvoices))}
          </h2>
        </div>
      </div>
    </div>

    <div class="border-t border-b border-fleeca-border"></div>

    <div class="grid grid-cols-3 gap-3 p-4 bg-fleeca-card">
      <button
        class="flex items-center justify-center py-3 px-2 bg-fleeca-green text-white rounded-lg font-medium hover:bg-fleeca-dark-green transition-all shadow-sm"
      >
        <i class="fas fa-money-check text-white mr-2"></i>
        <span>{paidInvoices} {translationsValue.paid || "Paid"}</span>
      </button>
      <button
        class="flex items-center justify-center py-3 px-2 bg-fleeca-hover text-fleeca-text rounded-lg font-medium hover:bg-fleeca-bg transition-all border border-fleeca-border shadow-sm"
      >
        <i class="fas fa-money-bill-transfer mr-2"></i>
        <span>{pendingInvoices} {translationsValue.pending || "Pending"}</span>
      </button>
      <button
        on:click={() => showPendingPopup = true}
        class="flex items-center justify-center py-3 px-2 bg-fleeca-hover text-fleeca-text rounded-lg font-medium hover:bg-fleeca-bg transition-all border border-fleeca-border shadow-sm"
      >
        <i class="fas fa-exchange-alt mr-2"></i>
        <span>{translationsValue.pay_pending || "Pay Pending Invoices"}</span>
      </button>
    </div>
  </div>

  <div class="mb-4 flex justify-between items-center">
    <h3
      class="text-xl font-semibold text-fleeca-text flex items-center font-display"
    >
      <div
        class="w-8 h-8 rounded-lg bg-fleeca-green/10 flex items-center justify-center mr-3 border border-fleeca-green/20"
      >
        <i class="fa-solid fa-receipt text-fleeca-green"></i>
      </div>
      {translationsValue.invoices || "Invoices"}
    </h3>
  </div>

  <div class="relative mb-4">
    <input
      type="text"
      class="w-full rounded-lg border border-fleeca-border p-3 pl-10 bg-fleeca-card focus:border-none text-fleeca-text focus:border-fleeca-green transition-all"
      placeholder={translationsValue.search_invoices || "Search invoices..."}
      bind:value={transSearch}
    />
    <i
      class="fa-solid fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-fleeca-text-secondary"
    ></i>
  </div>

  <div
    class="overflow-y-auto custom-scrollbar flex-1 pr-2 hide-scrollbar bg-fleeca-bg rounded-lg p-4 border border-fleeca-border"
  >
    {#if $invoices.length > 0}
      {#if $invoices.filter((item) => item && item.note && typeof item.note === "string" && (item.note
            .toLowerCase()
            .includes((transSearch || "").toLowerCase()) || (item.invoice_id && typeof item.invoice_id === "string" && item.invoice_id
                .toLowerCase()
                .includes((transSearch || "").toLowerCase())) || (item.author_job && typeof item.author_job === "string" && item.author_job
                .toLowerCase()
                .includes((transSearch || "").toLowerCase())))).length > 0}
        <div class="space-y-3 animate-fadeIn">
          {#each $invoices
            .filter((item) => item && item.note && typeof item.note === "string" && (item.note
                  .toLowerCase()
                  .includes((transSearch || "").toLowerCase()) || (item.invoice_id && typeof item.invoice_id === "string" && item.invoice_id
                      .toLowerCase()
                      .includes((transSearch || "").toLowerCase())) || (item.author_job && typeof item.author_job === "string" && item.author_job
                      .toLowerCase()
                      .includes((transSearch || "").toLowerCase()))))
            .sort((a, b) => {
              if (a.status === "pending" && b.status !== "pending") return -1;
              if (a.status !== "pending" && b.status === "pending") return 1;
              return 0;
            }) as transaction (transaction.invoice_id)}
            <InvoiceItem invoice={transaction} {payInvoice} />
          {/each}
        </div>
      {:else}
        <div
          class="text-center py-8 bg-fleeca-card rounded-lg border border-fleeca-border animate-fadeIn shadow-sm"
        >
          <div
            class="w-16 h-16 mx-auto bg-fleeca-bg rounded-full flex items-center justify-center mb-4"
          >
            <i class="fa-solid fa-receipt text-fleeca-text-secondary text-2xl"
            ></i>
          </div>
          <h3 class="text-fleeca-text font-medium">
            {translationsValue.no_invoices_found || "No invoices found"}
          </h3>
        </div>
      {/if}
    {:else}
      <div
        class="text-center py-8 bg-fleeca-card rounded-lg border border-fleeca-border animate-fadeIn shadow-sm"
      >
        <div
          class="w-16 h-16 mx-auto bg-fleeca-bg rounded-full flex items-center justify-center mb-4"
        >
          <i class="fa-solid fa-receipt text-fleeca-text-secondary text-2xl"
          ></i>
        </div>
        <h3 class="text-fleeca-text font-medium">
          {translationsValue.no_invoices_found || "No invoices found"}
        </h3>
      </div>
    {/if}
  </div>
</section>

<style>
  :global(.text-4xl) {
    transition: none !important;
    animation: none !important;
  }

  :global(.money-counter),
  :global(.digit) {
    transition: none !important;
    animation: none !important;
  }

  /* Custom Scrollbar Styles */
  :global(.custom-scrollbar) {
    scrollbar-width: thin;
    scrollbar-color: theme("colors.fleeca.border") theme("colors.fleeca.card");
  }

  :global(.custom-scrollbar::-webkit-scrollbar) {
    width: 6px;
  }

  :global(.custom-scrollbar::-webkit-scrollbar-track) {
    background: theme("colors.fleeca.card");
    border-radius: 3px;
  }

  :global(.custom-scrollbar::-webkit-scrollbar-thumb) {
    background-color: theme("colors.fleeca.border");
    border-radius: 3px;
  }

  :global(.custom-scrollbar::-webkit-scrollbar-thumb:hover) {
    background-color: theme("colors.fleeca.hover");
  }
</style>

{#if showPendingPopup}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
    <div 
      class="bg-fleeca-card rounded-xl p-6 max-w-md w-full mx-4 border border-fleeca-border shadow-lg"
      transition:fly={{ y: 20, duration: 200 }}
    >
      <h3 class="text-xl font-semibold text-fleeca-text mb-4">Confirm Payment</h3>
      
      <div class="mb-6">
        <p class="text-fleeca-text-secondary mb-2">{translationsValue.confirm_pay_pending || "You are about to pay all pending invoices:"}</p>
        <div class="bg-fleeca-bg rounded-lg p-4 border border-fleeca-border">
          <div class="flex justify-between items-center">
            <span class="text-fleeca-text">{translationsValue.total_amount || "Total Amount:"}</span>
            <span class="text-fleeca-text font-semibold">{formatMoney(totalPendingInvoices)}</span>
          </div>
          <div class="flex justify-between items-center mt-2">
            <span class="text-fleeca-text">{translationsValue.number_of_invoices || "Number of Invoices:"}</span>
            <span class="text-fleeca-text font-semibold">{pendingInvoices}</span>
          </div>
        </div>
      </div>

      <div class="flex gap-3">
        <button
          on:click={payAllPendingInvoices}
          class="flex-1 bg-fleeca-green text-white py-2 px-4 rounded-lg font-medium hover:bg-fleeca-dark-green transition-all"
        >
          {translationsValue.confirm_payment || "Confirm Payment"}
        </button>
        <button
          on:click={() => showPendingPopup = false}
          class="flex-1 bg-fleeca-hover text-fleeca-text py-2 px-4 rounded-lg font-medium hover:bg-fleeca-bg transition-all border border-fleeca-border"
        >
          {translationsValue.cancel || "Cancel"}
        </button>
      </div>
    </div>
  </div>
{/if}
