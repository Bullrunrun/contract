-- 引入必要的库
local json = require('json')
local token = require('token')
local bint = require('.bint')(256)
local utils = require('utils') 

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

-- 定义转账函数
function Transfer_funds(recipient, amount)
    -- 使用 token.lua 中的转账函数
    if token.TransferBullCoin(ao.id, recipient, amount) then
        return true
    end
    return false
end

-- 定义 5 个不同成功率的函数
-- 成功率 80%
function Function1(recipient)
    if Random_percentage() <= 80 then
        Transfer_funds(recipient, 1)
        return true
    end
    return false
end

-- 成功率 60%
function Function2(recipient)
    if Random_percentage() <= 60 then
        Transfer_funds(recipient, 2)
        return true
    end
    return false
end

-- 成功率 40%
function Function3(recipient)
    if Random_percentage() <= 40 then
        Transfer_funds(recipient, 3)
        return true
    end
    return false
end

-- 成功率 20%
function Function4(recipient)
    if Random_percentage() <= 20 then
        Transfer_funds(recipient, 4)
        return true
    end
    return false
end

-- 成功率 10%
function Function5(recipient)
    if Random_percentage() <= 10 then
        Transfer_funds(recipient, 5)
        return true
    end
    return false
end



-- 随机生成牛的 handler
handler('get_random_numbers', function()
    return Generate_random_numbers()
end)

handler('get_bull_1', function(msg)
    return Function1(msg.recipient)
end)

handler('get_bull_2', function(msg)
    return Function2(msg.recipient)
end)


handler('get_bull_3', function(msg)
    return Function3(msg.recipient)
end)

handler('get_bull_4', function(msg)
    return Function4(msg.recipient)
end)

handler('get_bull_5', function(msg)
    return Function5(msg.recipient)
end)
