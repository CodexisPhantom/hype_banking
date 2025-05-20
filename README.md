# 💸 Enhanced Renewed Banking

A custom-enhanced version of [Renewed Banking Revamp](https://github.com/prosir/Renewed-Banking-Revamp) and [Renewed Banking](https://github.com/Renewed-Scripts/Renewed-Banking), featuring a complete backend rewrite, UI improvements, and new features like invoice sending/canceling and LB-phone integration.

## ✨ What's New

- 🔧 **Backend Overhaul**  
  Completely refactored backend for improved performance, maintainability, and extensibility.

- 🧾 **Invoice Management (Basic)**  
  Players can now **send** and **cancel** invoices directly from the banking interface.

- 🧩 **Invoices Tab**  
  A dedicated section in the bank UI to view and manage incoming invoices.

- 📱 **Phone Banking Support (LB-Phone)**  
  Integrated bank app designed specifically for **[LB-phone](https://lbscripts.com/)** users.

- 🎨 **UI Enhancements**  
  Refined and modernized interface for an improved user experience across both PC and mobile.

- 📱 **Added interact support**
  Check this out amazing [interact](https://github.com/darktrovx/interact).

## 🛠 Requirements

* **ESX or QBCore** framework
* **oxmysql**
* **LB-phone** (optional, for mobile app support)

## 📦 Server Exports

### Account Management
- `GetAllAccounts`: Get all bank accounts in the system
  ```lua
  local accounts = exports['hype_banking']:GetAllAccounts()
  ```

- `CreateAccount`: Create a new bank account
  ```lua
  local account = exports['hype_banking']:CreateAccount({
      id = 'unique_id',
      name = 'Account Name',
      type = 'org',
      frozen = false,
      amount = 0,
      transactions = {},
      auth = { [identifier] = true },
      creator = identifier
  })
  ```

- `GetAccount`: Get a specific account by ID
  ```lua
  local account = exports['hype_banking']:GetAccount('account_id')
  ```

### Invoice Management
- `CreateInvoice`: Create a new invoice
  ```lua
  local invoice = exports['hype_banking']:CreateInvoice({
      player = source,
      target = target_id,
      item = 'Service',
      amount = 1000,
      note = 'Payment for services',
      autopay = false
  })
  ```

- `GetPlayerInvoices`: Get all invoices for a specific player
  ```lua
  local invoices = exports['hype_banking']:GetPlayerInvoices(identifier)
  ```

- `GetPlayerPendingInvoices`: Get pending invoices for a specific player
  ```lua
  local pendingInvoices = exports['hype_banking']:GetPlayerPendingInvoices(identifier)
  ```

- `GetInvoiceByJob`: Get all invoices for a specific job
  ```lua
  local jobInvoices = exports['hype_banking']:GetInvoiceByJob('job_name')
  ```

- `PayInvoice`: Pay a specific invoice
  ```lua
  local result = exports['hype_banking']:PayInvoice(source, 'invoice_id')
  ```

- `PayAllPendingInvoices`: Pay all pending invoices for a player
  ```lua
  local result = exports['hype_banking']:PayAllPendingInvoices(source)
  ```

- `CancelInvoice`: Cancel a specific invoice
  ```lua
  local result = exports['hype_banking']:CancelInvoice(source, 'invoice_id')
  ```

### Transaction Management
- `createTransaction`: Create a new transaction record
  ```lua
  local transaction = exports['hype_banking']:createTransaction({
      account = 'account_id',
      title = 'Transaction Title',
      amount = 1000,
      message = 'Transaction description',
      issuer = 'Sender Name',
      receiver = 'Receiver Name',
      trans_type = 'transfer'
  })
  ```

## 🙏 Credits

* [Renewed-Scripts/Renewed-Banking](https://github.com/Renewed-Scripts/Renewed-Banking) – Original banking system
* [prosir/Renewed-Banking-Revamp](https://github.com/prosir/Renewed-Banking-Revamp) – UI and logic improvements

Huge thanks to both teams for their solid foundations and continued community contributions.

## 📃 License
This resource builds on open contributions and is shared for educational and community server use. Please respect the licenses of the original authors when modifying or redistributing.