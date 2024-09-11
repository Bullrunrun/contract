-- 引入 json 和 token 模块
local json = require('json')
local token = require('token')

-- 从 token.lua 获取代币实例
local bullCoin = token.BullCoin
local daiCoin = token.DaiCoin

-- 将用户传入的dai换为游戏币bullCoin
function Swap_dai_To_bullCoin(user,daiAmountin)
    if token.swapDaiForBullCoin(user, daiAmountin) then
        return true
    end
    return false
end


-- 用户提现
function Withdraw(user)
    if token.withdrawBullCoin(user) then
        return true
    end
    return false
end


-- 初始化随机数种子
math.randomseed(os.time())

-- 定义一个函数，生成 1 到 9 的随机整数列表
function Generate_random_numbers()
    local numbers = {}
    for i = 1, 9 do
        numbers[i] = math.random(1, 9)
    end
    return numbers
end

-- 定义转账函数，模拟向调用者转账
function Transfer_funds(recipient, amount)
    -- 使用 token.lua 中的转账函数
    if token.TransferBullCoin(ao.id, recipient, amount) then
        return true
    end
    return false
end

-- 定义成功率函数
function Random_percentage()
    return math.random(100)
end

-- 定义 6 个不同成功率的函数
-- 成功率 50%
function Function1(recipient)
    if Random_percentage() <= 50 then
        Transfer_funds(recipient, 1)
        return true
    end
    return false
end

-- 成功率 25%
function Function2(recipient)
    if Random_percentage() <= 25 then
        Transfer_funds(recipient, 2)
        return true
    end
    return false
end

-- 成功率 14%
function Function3(recipient)
    if Random_percentage() <= 14 then
        Transfer_funds(recipient, 3)
        return true
    end
    return false
end

-- 成功率 11%
function Function4(recipient)
    if Random_percentage() <= 11 then
        Transfer_funds(recipient, 4)
        return true
    end
    return false
end

-- 成功率 8%
function Function5(recipient)
    if Random_percentage() <= 8 then
        Transfer_funds(recipient, 5)
        return true
    end
    return false
end

-- 成功率 1%
function Function6(recipient)
    if Random_percentage() <= 1 then
        Transfer_funds(recipient, 6)
        return true
    end
    return false
end









-- 提供调用接口
function Get_random_numbers()
    return Generate_random_numbers()
end

function Get_bull_1(recipient)
    return Function1(recipient)
end

function Get_bull_2(recipient)
    return Function2(recipient)
end

function Get_bull_3(recipient)
    return Function3(recipient)
end

function Get_bull_4(recipient)
    return Function4(recipient)
end

function Get_bull_5(recipient)
    return Function5(recipient)
end

function Get_bull_6(recipient)
    return Function6(recipient)
end


function Swap(user,daiAmountin)
    return Swap_dai_To_bullCoin(user,daiAmountin)
end

function Withdraw(user)
    return Withdraw(user)
end