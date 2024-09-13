local json = require('json')
local token = require('token')
local bint = require('.bint')(256)
local utils = require('utils')

math.randomseed(os.time())

-- 定义随机生成器
function Random_percentage()
    return math.random(100)
end

-- 随机生成牛
function Generate_random_numbers()
    local numbers = {}
    for i = 1,5 do
        numbers[i] = math.random(1,5)
    end
    return numbers
end

-- 定义转账函数
function Transfer_funds(recipient, amount)
    if token.TransferBullCoin(ao.id, recipient, amount) then
        return true
    end
    return false
end

-- 定义 5 个不同成功率的函数
function Function1(recipient)
    if Random_percentage() <= 50 then
        Transfer_funds(recipient, 1)
        return true
    end
    return false
end

function Function2(recipient)
    if Random_percentage() <= 25 then
        Transfer_funds(recipient, 2)
        return true
    end
    return false
end

function Function3(recipient)
    if Random_percentage() <= 14 then
        Transfer_funds(recipient, 3)
        return true
    end
    return false
end

function Function4(recipient)
    if Random_percentage() <= 10 then
        Transfer_funds(recipient, 4)
        return true
    end
    return false
end

function Function5(recipient)
    if Random_percentage() <= 1 then
        Transfer_funds(recipient, 5)
        return true
    end
    return false
end


--获取随机牛
handler('get_random_numbers', function()
    return Generate_random_numbers()
end)
--套中牛后获得的概率
handler('get_bull_1', function(recipient)
    return Function1(recipient)
end)

handler('get_bull_2', function(recipient)
    return Function2(recipient)
end)

handler('get_bull_3', function(recipient)
    return Function3(recipient)
end)

handler('get_bull_4', function(recipient)
    return Function4(recipient)
end)

handler('get_bull_5', function(recipient)
    return Function5(recipient)
end)
