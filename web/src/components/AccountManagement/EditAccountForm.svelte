<script lang="ts">
  import { translations } from '../../store/stores';
  import { notify } from '../../store/stores';
  
  export let account = {};
  export let onSubmit = (data) => {};
  
  let newName = '';
  let isValid = true;
  
  function validateName(value: string) {
    return /^[a-zA-Z\s]*$/.test(value) && value.length <= 20;
  }

  function handleInput(event: Event) {
    const input = event.target as HTMLInputElement;
    if (!validateName(input.value)) {
      if (input.value.length > 20) {
        input.value = input.value.slice(0, 20);
        notify.set({
          type: 'error',
          message: $translations.name_too_long || 'Name cannot exceed 20 characters'
        });
      } else {
        input.value = input.value.replace(/[^a-zA-Z\s]/g, '');
        notify.set({
          type: 'error',
          message: $translations.only_letters || 'Only letters and spaces are allowed'
        });
      }
    }
    newName = input.value;
  }
  
  function handleSubmit() {
    if (newName && validateName(newName)) {
      onSubmit({ newName });
    } else {
      notify.set({
        type: 'error',
        message: $translations.invalid_name || 'Please enter a valid name using only letters and spaces (max 20 characters)'
      });
    }
  }
</script>

<div class="space-y-4">
  <h3 class="text-lg font-medium text-fleeca-text">{$translations.edit_acc_name || 'Change Account Name'}</h3>
  <p class="text-fleeca-text-secondary">{$translations.edit_acc_name_txt || 'Transactions wont update old names'}</p>
  <p class="text-fleeca-text">{$translations.account_id || 'Account ID'}: {account.id}</p>
  
  <div class="bg-fleeca-card rounded-lg border border-fleeca-border p-4">
    <div class="space-y-4">
      <div>
        <label for="newName" class="block text-fleeca-text font-medium mb-1">
          {$translations.account_label || 'Account Label'}
        </label>
        <input 
          type="text" 
          id="newName"
          bind:value={newName}
          on:input={handleInput}
          placeholder={account.name}
          maxlength="20"
          class="w-full rounded-lg border border-fleeca-border p-3 bg-fleeca-bg text-fleeca-text focus:border-fleeca-green transition-all"
        />
        <p class="text-fleeca-text-secondary text-sm mt-1">
          {$translations.account_label || 'Displayed in the banking app'} (max 20 characters)
        </p>
      </div>
      
      <button 
        class="w-full py-3 px-4 bg-fleeca-green text-white rounded-md text-sm font-medium hover:bg-fleeca-dark-green transition-colors"
        on:click={handleSubmit}
      >
        <i class="fas fa-save mr-1"></i> {$translations.change_account_name || 'Change Account Name'}
      </button>
    </div>
  </div>
</div>
