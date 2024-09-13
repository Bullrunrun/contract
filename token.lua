local bint = require('.bint')(256)
--[[
  此模块实现了ao标准代币规范。

  术语:
    Sender: 发送消息的钱包或进程

  它将首先初始化内部状态，然后根据ao标准代币规范API附加处理程序:

    - Info(): 返回代币参数，如名称、代号、徽标和计量单位

    - Balance(Target?: string): 返回目标的代币余额。如果未提供目标，则默认发送者为目标

    - Balances(): 返回所有参与者的代币余额

    - Transfer(Target: string, Quantity: number): 如果发送者有足够的余额，则将指定数量的代币发送给目标。
        还会向目标发送信用通知，并向发送者发送借记通知

    - Mint(Quantity: number): 如果发送者匹配进程所有者，则铸造所需数量的代币，并将其添加到进程的余额中
]]
--
local json = require('json')

--[[
  工具函数，帮助减少bint的复杂性。
]]
--


local utils = {
  add = function(a, b)
    return tostring(bint(a) + bint(b))
  end,
  subtract = function(a, b)
    return tostring(bint(a) - bint(b))
  end,
  toBalanceValue = function(a)
    return tostring(bint(a))
  end,
  toNumber = function(a)
    return bint.tonumber(a)
  end
}


--[[
     初始化状态

     ao.id 等于进程的 Id
]]
--
Variant = "0.0.3"

-- 代币应保持幂等，不改变先前的状态更新
Denomination = Denomination or 12
Balances = Balances or { [ao.id] = utils.toBalanceValue(100000 * 10 ^ Denomination) }
TotalSupply = TotalSupply or utils.toBalanceValue(100000 * 10 ^ Denomination)
Name = Name or 'Bull Coin'
Ticker = Ticker or 'Bull Ticker'
Logo = Logo or 'Bull'

--[[
     为每个由ao标准代币规范定义的传入操作添加处理程序
]]
--

--[[
     Info
]]
--

--返回代币的信息，包括名称、代号、徽标和计量单位。
Handlers.add('info', "Info", function(msg)
  msg.reply({
    Name = Name,
    Ticker = Ticker,
    Logo = Logo,
    Denomination = tostring(Denomination)
  })
end)

--[[
     Balance
]]
--

--供用户查询余额
Handlers.add('balance', "Balance", function(msg)
  local bal = '0'

  -- 如果没有提供目标，则返回发送者的余额
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

--[[
     Balances
]]
--

--获取所有人的余额
Handlers.add('balances', "Balances",
  function(msg) msg.reply({ Data = json.encode(Balances) }) end)

--[[
     Transfer
]]
--

--  可以通过这个接口向用户转账
Handlers.add('transfer', "Transfer", function(msg)
  assert(type(msg.Recipient) == 'string', 'Recipient is required!')
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(bint.__lt(0, bint(msg.Quantity)), 'Quantity must be greater than 0')

  if not Balances[msg.From] then Balances[msg.From] = "0" end
  if not Balances[msg.Recipient] then Balances[msg.Recipient] = "0" end

  if bint(msg.Quantity) <= bint(Balances[msg.From]) then
    Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
    Balances[msg.Recipient] = utils.add(Balances[msg.Recipient], msg.Quantity)

    --[[
         只有在传输消息上未设置 Cast 标签时才发送通知给发送者和接收者
    ]]
    --
    if not msg.Cast then
      -- 借记通知消息模板，发送给转账的发送者
      local debitNotice = {
        Action = 'Debit-Notice',
        Recipient = msg.Recipient,
        Quantity = msg.Quantity,
        Data = Colors.gray ..
            "You transferred " ..
            Colors.blue .. msg.Quantity .. Colors.gray .. " to " .. Colors.green .. msg.Recipient .. Colors.reset
      }
      -- 信用通知消息模板，发送给转账的接收者
      local creditNotice = {
        Target = msg.Recipient,
        Action = 'Credit-Notice',
        Sender = msg.From,
        Quantity = msg.Quantity,
        Data = Colors.gray ..
            "You received " ..
            Colors.blue .. msg.Quantity .. Colors.gray .. " from " .. Colors.green .. msg.From .. Colors.reset
      }

      -- 将转发标签添加到信用和借记通知消息中
      for tagName, tagValue in pairs(msg) do
        -- 以 "X-" 开头的标签会被转发
        if string.sub(tagName, 1, 2) == "X-" then
          debitNotice[tagName] = tagValue
          creditNotice[tagName] = tagValue
        end
      end

      -- 发送借记通知和信用通知
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

--[[
    Mint
]]
--

--铸造新的代币并将其添加到发起者的余额中。只有合约所有者（ao.id）才能铸造代币
Handlers.add('mint', "Mint", function(msg)
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(bint(0) < bint(msg.Quantity), 'Quantity must be greater than zero!')

  if not Balances[ao.id] then Balances[ao.id] = "0" end

  if msg.From == ao.id then
    -- 根据数量向代币池中添加代币
    Balances[msg.From] = utils.add(Balances[msg.From], msg.Quantity)
    TotalSupply = utils.add(TotalSupply, msg.Quantity)
    msg.reply({
      Data = Colors.gray .. "Successfully minted " .. Colors.blue .. msg.Quantity .. Colors.reset
    })
  else
    msg.reply({
      Action = 'Mint-Error',
      ['Message-Id'] = msg.Id,
      Error = 'Only the Process Id can mint new ' .. Ticker .. ' tokens!'
    })
  end
end)

--[[
     Total Supply
]]
--

--返回代币总供应量
Handlers.add('totalSupply', "Total-Supply", function(msg)
  assert(msg.From ~= ao.id, 'Cannot call Total-Supply from the same process!')

  msg.reply({
    Action = 'Total-Supply',
    Data = TotalSupply,
    Ticker = Ticker
  })
end)

--[[
  Burn
]]

--销毁指定数量的代币，从账户余额中扣除，并减少总供应量。
Handlers.add('burn', 'Burn', function(msg)
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(bint(msg.Quantity) <= bint(Balances[msg.From]), 'Quantity must be less than or equal to the current balance!')

  Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
  TotalSupply = utils.subtract(TotalSupply, msg.Quantity)

  msg.reply({
    Data = Colors.gray .. "Successfully burned " .. Colors.blue .. msg.Quantity .. Colors.reset
  })
end)
