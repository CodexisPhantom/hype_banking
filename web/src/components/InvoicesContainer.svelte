<script lang="ts">
  import { fetchNui } from "$utils/fetchNui";
  import { onMount } from "svelte";
  import { fly } from "svelte/transition";
  import { invoices, visibility } from "../store/stores";
  import { formatMoney } from "$utils/misc";
  import type { InvoiceProps } from "src/types/invoices";
  import { useNuiEvent } from "$utils/useNuiEvent"
  import { translations } from "../store/stores";
  import { get } from "svelte/store";
  $: translationsValue = get(translations) || {};
  useNuiEvent("setInvoices", (data: InvoiceProps[]) => {
    invoices.set(data || []);
  });

  const cancelInvoice = async (args: InvoiceProps) => {
    const resp = await fetchNui("hype_banking:client:cancelInvoice", args);
    if (resp && resp.status === "success") {
      invoices.update((invoices) => {
        return invoices.map((invoice) => {
          if (invoice.invoice_id === args.invoice_id) {
            invoice.status = "canceled";
          }
          return invoice;
        });
      });
    }
  };

  $: totalPaidInvoices = $invoices.filter(
    (invoice) => invoice.status === "paid"
  ).length;

  $: totalUnpaidInvoices = $invoices.filter(
    (invoice) => invoice.status === "unpaid"
  ).length;

  $: totalEarnings = $invoices.reduce((acc, invoice) => {
    return invoice.status === 'paid' ? acc + invoice.total : acc;
  }, 0);

  let searchQuery = "";

  $: filteredInvoices = $invoices.filter((invoice) => {
    const searchLower = searchQuery.toLowerCase();
    return (
      invoice.invoice_id?.toLowerCase().includes(searchLower) ||
      invoice.note?.toLowerCase().includes(searchLower) ||
      invoice.receiver_name?.toLowerCase().includes(searchLower) ||
      invoice.receiver_citizenid?.toLowerCase().includes(searchLower) ||
      invoice.author_name?.toLowerCase().includes(searchLower) ||
      invoice.author_citizenid?.toLowerCase().includes(searchLower) ||
      invoice.status?.toLowerCase().includes(searchLower) ||
      formatMoney(invoice.total).includes(searchLower)
    );
  });

  let selectedInvoice: InvoiceProps | null = null;
  let showDetailsModal = false;
  let currentPage = 1;
  const itemsPerPage = 6;

  function toggleDetailsModal(invoice: InvoiceProps | null) {
    selectedInvoice = invoice;
    showDetailsModal = !showDetailsModal;
  }

  $: paginatedInvoices = filteredInvoices.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  $: totalPages = Math.ceil(filteredInvoices.length / itemsPerPage);

  function goToPage(page: number) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
    }
  }


  type InvoiceStatus = 'paid' | 'pending' | 'canceled';
  type BadgeTemplate = {
    [key in InvoiceStatus]: {
      background: string;
      text: string;
      icon: string;
    }
  };
  const badgeTemplate: BadgeTemplate = {
    paid: {
      background: 'bg-green-800',
      text: 'text-green-100',
      icon: 'fa-check-circle'
    },
    pending: {
      background: 'bg-yellow-800',
      text: 'text-yellow-100',
      icon: 'fa-clock'
    },
    canceled: {
      background: 'bg-gray-800',
      text: 'text-gray-100',
      icon: 'fa-ban'
    }
  };

  function getBadgeStyles(status: string) {
    return badgeTemplate[status as InvoiceStatus] || badgeTemplate.paid;
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
            <i class="fas fa-receipt text-fleeca-green text-2xl"></i>
          </div>
          <div>
            <h1 class="text-2xl font-bold text-fleeca-text font-display">
              {translationsValue.invoices || "Invoices"}
            </h1>
            <p class="text-fleeca-green text-sm font-medium">
              {translationsValue.invoices_management || "Invoices Management"}
            </p>
          </div>
        </div>

        <div class="flex items-center gap-3">
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
      <div class="flex gap-6 h-[calc(100%-4rem)] flex-col overflow-hidden">
        <div
          class="bg-fleeca-card rounded-xl mb-6 shadow-lg overflow-hidden border-fleeca-border"
        >
          <div class="grid grid-cols-3 gap-3 p-4 bg-fleeca-card">
            <button
              class="flex items-center justify-center py-3 px-2 bg-fleeca-hover text-white rounded-lg font-medium hover:bg-fleeca-dark-green transition-all shadow-sm"
            >
              <i class="fas fa-arrow-down text-white mr-2"></i>
              <span>{(translationsValue.paid_invoices || "%s Paid Invoices").replace("%s", totalPaidInvoices.toString())}</span>
            </button>
            <button
              class="flex items-center justify-center py-3 px-2 bg-fleeca-hover text-white rounded-lg font-medium hover:bg-fleeca-dark-green transition-all shadow-sm"
            >
              <i class="fas fa-arrow-down text-white mr-2"></i>
              <span>{(translationsValue.unpaid_invoices || "%s Unpaid Invoices").replace("%s", totalUnpaidInvoices.toString())}</span>
            </button>
            <button
              class="flex items-center justify-center py-3 px-2 bg-fleeca-hover text-white rounded-lg font-medium hover:bg-fleeca-dark-green transition-all shadow-sm"
            >
              <i class="fas fa-arrow-down text-white mr-2"></i>
              <span>{(translationsValue.total_earning || "%s Total Earning").replace("%s", formatMoney(totalEarnings))}</span>
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

          <button
            aria-label="Export"
            class="py-1 px-3 bg-fleeca-hover text-fleeca-text rounded-md text-xs font-medium hover:bg-fleeca-bg transition-colors border border-fleeca-border flex items-center"
          >
            <i class="fa-solid fa-file-export mr-1"></i>
          </button>
        </div>

        <div class="relative mb-4">
          <input
            type="text"
            class="w-full rounded-lg border border-fleeca-border p-3 pl-10 bg-fleeca-card text-fleeca-text focus:border-fleeca-green transition-all"
            placeholder={translationsValue.search_invoices || "Search invoices..."}
            bind:value={searchQuery}
          />
          <i
            class="fa-solid fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-fleeca-text-secondary"
          ></i>
        </div>

        <div
          class="overflow-hidden flex-1 pr-2 bg-fleeca-bg rounded-lg p-4 border border-fleeca-border h-full"
        >
          <div
            class="min-w-full divide-y divide-fleeca-border h-full flex flex-col"
          >
            <!-- Table Header -->
            <div class="bg-fleeca-card rounded-t-lg">
              <div
                class="grid grid-cols-9 gap-4 px-4 py-3 text-sm font-medium text-fleeca-text"
              >
              <div>{translationsValue.invoice_id || "Invoice ID"}</div>
              <div>{translationsValue.status || "Status"}</div>
              <div>{translationsValue.total || "Total"}</div>
              <div>{translationsValue.author || "Author"}</div>
              <div>{translationsValue.author_id || "Author ID"}</div>
              <div>{translationsValue.receiver || "Receiver"}</div>
              <div>{translationsValue.receiver_id || "Receiver ID"}</div>
              <div>{translationsValue.date || "Date"}</div>
              <div>{translationsValue.actions || "Actions"}</div>
              </div>
            </div>

            <!-- Table Body with Fixed Height -->
            <div
              class="flex-1 flex flex-col bg-fleeca-card divide-y divide-fleeca-border rounded-b-lg"
            >
              <div class="flex-1 overflow-y-auto">
                {#if paginatedInvoices.length > 0}
                  {#each paginatedInvoices as invoice}
                  {@const badge = getBadgeStyles(invoice.status)}
                    <div
                      class="grid grid-cols-9 gap-4 px-4 py-3 text-sm hover:bg-fleeca-hover transition-colors"
                    >
                      <div class="text-fleeca-text font-medium">
                        {invoice.invoice_id}
                      </div>
                      <div>
                        <span
                          class="px-2 py-1 rounded-full text-xs font-medium flex items-center gap-1 w-fit {badge.background} {badge.text}"
                        >
                          <i class="fas {badge.icon}"></i>
                          {invoice.status}
                        </span>
                      </div>
                      <div class="text-fleeca-text">
                        {formatMoney(invoice.total)}
                      </div>
                      <div class="text-fleeca-text">{invoice.author_name}</div>
                      <div class="text-fleeca-text">{invoice.author_citizenid}</div>
                      <div class="text-fleeca-text">{invoice.receiver_name}</div>
                      <div class="text-fleeca-text">{invoice.receiver_citizenid}</div>
                      <div class="text-fleeca-text-secondary">
                        {new Date(invoice.created_date * 1000).toLocaleDateString()}
                      </div>
                      <div class="flex items-center space-x-2">
                        <button
                          aria-label="Details"
                          on:click={() => toggleDetailsModal(invoice)}
                          class="p-2 text-fleeca-text hover:text-fleeca-green transition-colors"
                        >
                          <i class="fas fa-eye"></i>
                        </button>
                      </div>
                    </div>
                  {/each}
                {:else}
                  <div
                    class="text-center py-8 h-full flex flex-col items-center justify-center"
                  >
                    <div
                      class="w-16 h-16 mx-auto bg-fleeca-bg rounded-full flex items-center justify-center mb-4"
                    >
                      <i
                        class="fa-solid fa-receipt text-fleeca-text-secondary text-2xl"
                      ></i>
                    </div>
                    <h3 class="text-fleeca-text font-medium">
                      {translationsValue.no_invoices_found || "No invoices found"}
                    </h3>
                  </div>
                {/if}
              </div>

              <!-- Pagination (Fixed at Bottom) -->
              {#if paginatedInvoices.length > 0}
                <div
                  class="flex items-center justify-between px-4 py-3 bg-fleeca-card border-t border-fleeca-border"
                >
                  <div
                    class="flex items-center text-sm text-fleeca-text-secondary"
                  >
                  {(translationsValue.showing_invoices || "Showing %s to %s of %s invoices")
                  .replace("%s", ((currentPage - 1) * itemsPerPage + 1).toString())
                  .replace("%s", Math.min(currentPage * itemsPerPage, filteredInvoices.length).toString())
                  .replace("%s", filteredInvoices.length.toString())}
                  </div>
                  <div class="flex items-center space-x-2">
                    <button
                      aria-label="Previous page"
                      on:click={() => goToPage(currentPage - 1)}
                      class="p-2 rounded-lg text-fleeca-text hover:bg-fleeca-hover disabled:opacity-50 disabled:cursor-not-allowed"
                      disabled={currentPage === 1}
                    >
                      <i class="fas fa-chevron-left"></i>
                    </button>
                    {#each Array(totalPages) as _, i}
                      <button
                        on:click={() => goToPage(i + 1)}
                        class="p-2 rounded-lg text-fleeca-text hover:bg-fleeca-hover"
                        class:bg-fleeca-green={currentPage === i + 1}
                        class:text-white={currentPage === i + 1}
                      >
                        {i + 1}
                      </button>
                    {/each}
                    <button
                      aria-label="Next page"
                      on:click={() => goToPage(currentPage + 1)}
                      class="p-2 rounded-lg text-fleeca-text hover:bg-fleeca-hover disabled:opacity-50 disabled:cursor-not-allowed"
                      disabled={currentPage === totalPages}
                    >
                      <i class="fas fa-chevron-right"></i>
                    </button>
                  </div>
                </div>
              {/if}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Details Modal -->
{#if showDetailsModal && selectedInvoice}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
    <div class="bg-fleeca-card rounded-xl p-6 max-w-lg w-full mx-4 shadow-xl">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-bold text-fleeca-text">{translationsValue.invoice_details || "Invoice Details"}</h3>
        <button
          aria-label="Close"
          on:click={() => toggleDetailsModal(null)}
          class="p-2 text-fleeca-text-secondary hover:text-fleeca-text transition-colors"
        >
          <i class="fas fa-times"></i>
        </button>
      </div>

      <div class="space-y-4">
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div class="text-fleeca-text-secondary">{translationsValue.invoice_id || "Invoice ID"}</div>
          <div class="text-fleeca-text font-medium">
            {selectedInvoice.invoice_id}
          </div>

          <div class="text-fleeca-text-secondary">{translationsValue.status || "Status"}</div>
          <div>
            <span
            class="px-2 py-1 rounded-full text-xs font-medium flex items-center gap-1 w-fit {getBadgeStyles(selectedInvoice.status).background} {getBadgeStyles(selectedInvoice.status).text}"
          >
            <i class="fas {getBadgeStyles(selectedInvoice.status).icon}"></i>
            {selectedInvoice.status}
          </span>
          </div>

          <div class="text-fleeca-text-secondary">{translationsValue.total || "Total"}</div>
          <div class="text-fleeca-text">
            {formatMoney(selectedInvoice.total)}
          </div>

          <div class="text-fleeca-text-secondary">{translationsValue.receiver || "Receiver"}</div>
          <div class="text-fleeca-text">{selectedInvoice.receiver_name}</div>

          <div class="text-fleeca-text-secondary">{translationsValue.receiver_id || "Receiver Id"}</div>
          <div class="text-fleeca-text">{selectedInvoice.receiver_citizenid}</div>

          <div class="text-fleeca-text-secondary">{translationsValue.author || "Author"}</div>
          <div class="text-fleeca-text">{selectedInvoice.author_name}</div>

          <div class="text-fleeca-text-secondary">{translationsValue.author_id || "Author Id"}</div>
          <div class="text-fleeca-text">{selectedInvoice.author_citizenid}</div>
          
          <div class="text-fleeca-text-secondary">{translationsValue.date || "Date"}</div>
          <div class="text-fleeca-text">
            {new Date(selectedInvoice.created_date * 1000).toLocaleDateString()}
          </div>

          <div class="text-fleeca-text-secondary">{translationsValue.note || "Note"}</div>
          <div class="text-fleeca-text">{selectedInvoice.note}</div>
        </div>

        <div class="flex justify-end space-x-3 mt-6">
          <button
            on:click={() => toggleDetailsModal(null)}
            class="px-4 py-2 bg-fleeca-hover text-fleeca-text rounded-lg hover:bg-fleeca-bg transition-colors"
          >
            {translationsValue.close || "Close"}
          </button>
          {#if selectedInvoice.status === "pending"}
            <button
              on:click={() => {
                cancelInvoice(selectedInvoice as InvoiceProps);
                toggleDetailsModal(null);
              }}
              class="px-4 py-2 bg-red-900/90 text-white rounded-lg hover:bg-red-800/90 transition-colors"
            >
              {translationsValue.cancel_invoice || "Cancel Invoice"}
            </button>
          {/if}
        </div>
      </div>
    </div>
  </div>
{/if}
