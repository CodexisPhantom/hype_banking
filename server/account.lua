local cachedAccounts = {}

---@class AccountProps
---@field id string
---@field name string
---@field type string
---@field frozen boolean
---@field amount number
---@field transactions table
---@field auth table
---@field creator? string

---@class Account : OxClass
---@field data AccountProps
local account = lib.class('Account')

--- Constructor
---@param data AccountProps
function account:constructor(data)
    assert(type(data) == 'table', 'Invalid data type')
    self.amount = data.amount
    self.frozen = data.frozen
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.transactions = data.transactions
    self.auth = data.auth
    self.creator = data.creator
    self.addMoney = self.addMoney
    self.setAccountName = self.setAccountName
    self.removeMoney = self.removeMoney
    self.setMoney = self.setMoney
    return self
end

function account:addMoney(amount)
    assert(type(amount) == 'number', 'Invalid amount type')
    assert(amount > 0, 'Invalid amount')
    self.amount = self.amount + amount
    MySQL.update.await('UPDATE bank_accounts_new SET amount = ? WHERE id = ?', {
        self.amount,
        self.id
    })
    cachedAccounts[self.id].amount = self.amount
    return self.amount
end

function account:setAccountName(name)
    assert(type(name) == 'string', 'Invalid name type')
    if name == self.name then return end
    self.name = name
    cachedAccounts[self.id].name = self.name
    return self.name
end

function account:removeMoney(amount)
    assert(type(amount) == 'number', 'Invalid amount type')
    assert(amount > 0, 'Invalid amount')
    if self.amount < amount then return end
    self.amount = self.amount - amount
    MySQL.update.await('UPDATE bank_accounts_new SET amount =? WHERE id =?', {
        self.amount,
        self.id
    })
    cachedAccounts[self.id].amount = self.amount
    return self.amount
end

function account:setMoney(amount)
    assert(type(amount) == 'number', 'Invalid amount type')
    assert(amount > 0, 'Invalid amount')
    self.amount = amount
    MySQL.update.await('UPDATE bank_accounts_new SET amount =? WHERE id =?', {
        self.amount,
        self.id
    })
    cachedAccounts[self.id].amount = self.amount
    return self.amount
end

local accounts = {}

--- Get All Accounts
---@return table<string, AccountProps>
function accounts.getAllAccounts()
    return cachedAccounts
end exports('GetAllAccounts', accounts.getAllAccounts)

--- Create Account
---@param data AccountProps
---@return Account | nil
function accounts.new(data, insert)
    
    if cachedAccounts[data.id] then
        return end
    local acc = account:new(data)
    cachedAccounts[acc.id] = acc
    if insert ~= 'default' then
        MySQL.insert("INSERT INTO bank_accounts_new (id, amount, transactions, auth, isFrozen, creator) VALUES (?, ?, ?, ?, ?, ?) ",{
            data.id, data.amount, json.encode(data.transactions), json.encode({data.creator}), data.frozen, data.creator
        })
    end
    return acc
end exports('CreateAccount', accounts.new)

function accounts.delete(id, cachedPlayers)
    if not cachedAccounts[id] then
        return false
    end

    -- Remove from database
    local success = MySQL.update.await('DELETE FROM bank_accounts_new WHERE id = ?', {
        id
    })

    if success then
        -- Remove from cache
        cachedAccounts[id] = nil
        
        -- Remove from all cached players
        for _, player in pairs(cachedPlayers) do
            for i = #player.accounts, 1, -1 do
                if player.accounts[i] == id then
                    table.remove(player.accounts, i)
                    break
                end
            end
        end

        return true
    end

    return false
end

--- Get Account
---@param id string
---@return AccountProps
function accounts.getAccount(id)
    return cachedAccounts[id]
end exports('GetAccount', accounts.getAccount)

return accounts