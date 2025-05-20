<script lang="ts">
  import { translations } from '../../store/stores';
  import { notify } from '../../store/stores';

  export let onSubmit: (data: { accountId: string; label: string }) => void;

  let accountId = '';
  let label = '';

  function validateAccountId(value: string): boolean {
    return /^[a-z0-9_-]+$/.test(value) && value.length <= 20;
  }

  function validateLabel(value: string): boolean {
    return /^[a-zA-Z\s]*$/.test(value) && value.length <= 20;
  }

  function handleAccountIdInput(event: Event) {
    const input = event.target as HTMLInputElement;
    const sanitizedValue = input.value.toLowerCase().replace(/[^a-z0-9_-]/g, '');
    
    if (input.value !== sanitizedValue) {
      input.value = sanitizedValue;
      notify.set({
        type: 'error',
        message: $translations.invalid_id || 'Use only letters, numbers, dashes and underscores'
      });
    }
    if (sanitizedValue.length > 20) {
      input.value = sanitizedValue.slice(0, 20);
      notify.set({
        type: 'error',
        message: $translations.id_too_long || 'Account ID cannot exceed 20 characters'
      });
    }
    accountId = input.value;
  }

  function handleLabelInput(event: Event) {
    const input = event.target as HTMLInputElement;
    if (!validateLabel(input.value)) {
      if (input.value.length > 20) {
        input.value = input.value.slice(0, 20);
        notify.set({
          type: 'error',
          message: $translations.label_too_long || 'Label cannot exceed 20 characters'
        });
      } else {
        input.value = input.value.replace(/[^a-zA-Z\s]/g, '');
        notify.set({
          type: 'error',
          message: $translations.invalid_label || 'Use only letters and spaces'
        });
      }
    }
    label = input.value;
  }

  function handleSubmit() {
    if (!accountId || !validateAccountId(accountId)) {
      notify.set({
        type: 'error',
        message: $translations.invalid_id || 'Please enter a valid Account ID (letters, numbers, dashes and underscores only)'
      });
      return;
    }
    if (!label || !validateLabel(label)) {
      notify.set({
        type: 'error',
        message: $translations.invalid_label || 'Please enter a valid Label'
      });
      return;
    }
    onSubmit({ accountId, label });
  }
</script>

<div class="space-y-4">
  <h3 class="text-lg font-medium text-fleeca-text">{$translations.create_account || 'Create New Account'}</h3>
  <p class="text-fleeca-text-secondary">{$translations.create_account_txt || 'Create a new sub bank account!'}</p>
  
  <div class="bg-fleeca-card rounded-lg border border-fleeca-border p-4">
    <div class="space-y-4">
      <div>
        <label for="accountId" class="block text-fleeca-text font-medium mb-1">
          {$translations.account_id || 'Account ID'}
        </label>
        <input 
          type="text" 
          id="accountId"
          bind:value={accountId}
          on:input={handleAccountIdInput}
          placeholder="business-account_1"
          maxlength="20"
          class="w-full rounded-lg border border-fleeca-border p-3 bg-fleeca-bg text-fleeca-text focus:border-fleeca-green transition-all"
        />
        <p class="text-fleeca-text-secondary text-sm mt-1">
          {$translations.account_id_hint || 'Use letters, numbers, dashes and underscores'} (max 20 characters)
        </p>
      </div>
      <div>
        <label for="label" class="block text-fleeca-text font-medium mb-1">
          {$translations.account_label || 'Account Label'}
        </label>
        <input 
          type="text" 
          id="label"
          bind:value={label}
          on:input={handleLabelInput}
          placeholder="Business Account"
          maxlength="20"
          class="w-full rounded-lg border border-fleeca-border p-3 bg-fleeca-bg text-fleeca-text focus:border-fleeca-green transition-all"
        />
        <p class="text-fleeca-text-secondary text-sm mt-1">
          {$translations.account_label_hint || 'Displayed in the banking app'} (max 20 characters)
        </p>
      </div>
      
      <button 
        class="w-full py-3 px-4 bg-fleeca-green text-white rounded-md text-sm font-medium hover:bg-fleeca-dark-green transition-colors"
        on:click={handleSubmit}
      >
        <i class="fas fa-plus-circle mr-1"></i> {$translations.create_account || 'Create Account'}
      </button>
    </div>
  </div>
</div>
