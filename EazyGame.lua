-- 引入必要的库
local utils = require('.utils')

-- 初始化随机数种子
math.randomseed(os.time())

-- 定义随机生成器
function Random_percentage()
    return math.random(100)
end

-- 随机生成牛
function Generate_random_numbers()
    local numbers = {}
    for i = 1, 5 do
        numbers[i] = math.random(1, 5)
    end
    return numbers
end

-- 定义转账函数（直接集成在此脚本中）
function Transfer_funds(Balances, recipient, amount)
    if Balances[ao.id] and tonumber(Balances[ao.id]) >= amount then
        Balances[ao.id] = utils.subtract(Balances[ao.id], tostring(amount))
        Balances[recipient] = utils.add(Balances[recipient] or "0", tostring(amount))
        return true
    end
    return false
end

-- 定义 5 个不同成功率的函数
function Function1(Balances, recipient)
    if Random_percentage() <= 80 then
        return Transfer_funds(Balances, recipient, 1)
    end
    return false
end

function Function2(Balances, recipient)
    if Random_percentage() <= 60 then
        return Transfer_funds(Balances, recipient, 2)
    end
    return false
end

function Function3(Balances, recipient)
    if Random_percentage() <= 40 then
        return Transfer_funds(Balances, recipient, 3)
    end
    return false
end

function Function4(Balances, recipient)
    if Random_percentage() <= 20 then
        return Transfer_funds(Balances, recipient, 4)
    end
    return false
end

function Function5(Balances, recipient)
    if Random_percentage() <= 10 then
        return Transfer_funds(Balances, recipient, 5)
    end
    return false
end



-- 使用 Handlers.add 并提供正确的参数
Handlers.add('get_random_numbers', 
    function(msg)
        -- 这里可以根据消息的某些条件来决定返回 1（处理）、0（跳过）、-1（中止）
        return 1  -- 继续处理消息
    end,
    function(msg)
        msg.reply(Generate_random_numbers())
    end
)

Handlers.add('get_bull_1', 
    function(msg)
        return 1  -- 继续处理
    end,
    function(msg)
        if Function1(Balances, msg.recipient) then
            msg.reply("Transfer successful")
        else
            msg.reply("Transfer failed")
        end
    end
)

Handlers.add('get_bull_2', 
    function(msg)
        return 1  -- 继续处理
    end,
    function(msg)
        if Function2(Balances, msg.recipient) then
            msg.reply("Transfer successful")
        else
            msg.reply("Transfer failed")
        end
    end
)

Handlers.add('get_bull_3', 
    function(msg)
        return 1  -- 继续处理
    end,
    function(msg)
        if Function3(Balances, msg.recipient) then
            msg.reply("Transfer successful")
        else
            msg.reply("Transfer failed")
        end
    end
)

Handlers.add('get_bull_4', 
    function(msg)
        return 1  -- 继续处理
    end,
    function(msg)
        if Function4(Balances, msg.recipient) then
            msg.reply("Transfer successful")
        else
            msg.reply("Transfer failed")
        end
    end
)

Handlers.add('get_bull_5', 
    function(msg)
        return 1  -- 继续处理
    end,
    function(msg)
        if Function5(Balances, msg.recipient) then
            msg.reply("Transfer successful")
        else
            msg.reply("Transfer failed")
        end
    end
)
