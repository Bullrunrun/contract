local json = require('json')

-- 工具函数，帮助减少bignumber的复杂性。
local utils = {
  add = function(a, b)
    return tostring(tonumber(a) + tonumber(b))
  end,
  subtract = function(a, b)
    return tostring(tonumber(a) - tonumber(b))
  end,
  toBalanceValue = function(a)
    return tostring(a)
  end,
  toNumber = function(a)
    return tonumber(a)
  end
}

-- 初始化状态
Variant = "0.0.3"
Denomination = Denomination or 12
Balances = Balances or { [ao.id] = utils.toBalanceValue(100000 * 10 ^ Denomination) }
TotalSupply = TotalSupply or utils.toBalanceValue(100000 * 10 ^ Denomination)
Name = Name or 'Bull Coin'
Ticker = Ticker or 'Bull Ticker'
Logo = Logo or 'Bull'

-- 添加处理程序

-- Info 处理器
Handlers.add('info', function(msg)
  return 1 -- 匹配消息，继续处理
end, function(msg)
  msg.reply({
    Name = Name,
    Ticker = Ticker,
    Logo = Logo,
    Denomination = tostring(Denomination)
  })
end)

-- Balance 处理器
Handlers.add('balance', function(msg)
  return 1
end, function(msg)
  local bal = '0'

  if (msg.Tags.Recipient) then
    if (Balances[msg.Tags.Recipient]) then
      bal = Balances[msg.Tags.Recipient]
    end
  elseif msg.Tags.Target and Balances[msg.Tags.Target] then
    bal = Balances[msg.Tags.Target]
  elseif Balances[msg.From] then
    bal = Balances[msg.From]
  end

  msg.reply({
    Balance = bal,
    Ticker = Ticker,
    Account = msg.Tags.Recipient or msg.From,
    Data = bal
  })
end)

-- Balances 处理器
Handlers.add('balances', function(msg)
  return 1
end, function(msg)
  msg.reply({ Data = json.encode(Balances) })
end)

-- Transfer 处理器
Handlers.add('transfer', function(msg)
  return 1
end, function(msg)
  assert(type(msg.Recipient) == 'string', 'Recipient is required!')
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(tonumber(msg.Quantity) > 0, 'Quantity must be greater than 0')

  if not Balances[msg.From] then Balances[msg.From] = "0" end
  if not Balances[msg.Recipient] then Balances[msg.Recipient] = "0" end

  if tonumber(msg.Quantity) <= tonumber(Balances[msg.From]) then
    Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
    Balances[msg.Recipient] = utils.add(Balances[msg.Recipient], msg.Quantity)

    if not msg.Cast then
      local debitNotice = {
        Action = 'Debit-Notice',
        Recipient = msg.Recipient,
        Quantity = msg.Quantity,
        Data = "You transferred " .. msg.Quantity .. " to " .. msg.Recipient
      }
      local creditNotice = {
        Target = msg.Recipient,
        Action = 'Credit-Notice',
        Sender = msg.From,
        Quantity = msg.Quantity,
        Data = "You received " .. msg.Quantity .. " from " .. msg.From
      }

      for tagName, tagValue in pairs(msg) do
        if string.sub(tagName, 1, 2) == "X-" then
          debitNotice[tagName] = tagValue
          creditNotice[tagName] = tagValue
        end
      end

      msg.reply(debitNotice)
      Send(creditNotice)
    end
  else
    msg.reply({
      Action = 'Transfer-Error',
      ['Message-Id'] = msg.Id,
      Error = 'Insufficient Balance!'
    })
  end
end)

-- Mint 处理器
Handlers.add('mint', function(msg)
  return 1
end, function(msg)
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(tonumber(msg.Quantity) > 0, 'Quantity must be greater than zero!')

  if not Balances[ao.id] then Balances[ao.id] = "0" end

  if msg.From == ao.id then
    Balances[msg.From] = utils.add(Balances[msg.From], msg.Quantity)
    TotalSupply = utils.add(TotalSupply, msg.Quantity)
    msg.reply({
      Data = "Successfully minted " .. msg.Quantity
    })
  else
    msg.reply({
      Action = 'Mint-Error',
      ['Message-Id'] = msg.Id,
      Error = 'Only the Process Id can mint new ' .. Ticker .. ' tokens!'
    })
  end
end)

-- Total Supply 处理器
Handlers.add('totalSupply', function(msg)
  return 1
end, function(msg)
  assert(msg.From ~= ao.id, 'Cannot call Total-Supply from the same process!')

  msg.reply({
    Action = 'Total-Supply',
    Data = TotalSupply,
    Ticker = Ticker
  })
end)

-- Burn 处理器
Handlers.add('burn', function(msg)
  return 1
end, function(msg)
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(tonumber(msg.Quantity) <= tonumber(Balances[msg.From]), 'Quantity must be less than or equal to the current balance!')

  Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
  TotalSupply = utils.subtract(TotalSupply, msg.Quantity)

  msg.reply({
    Data = "Successfully burned " .. msg.Quantity
  })
end)
