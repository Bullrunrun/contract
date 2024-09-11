-- 初始化 json 库
local json = require('json')

-- 初始化 bint 库（确保它已被正确加载）
local bint = require('.bint')(256)

-- 初始化代币配置
local function initializeToken(name, ticker, denomination, logo, initialBalance)
    if not name then name = 'My Coin' end
    if not ticker then ticker = 'COIN' end
    if not denomination then denomination = 10 end
    if not logo then logo = 'optional arweave TXID of logo image' end
    
    local token = {
        Name = name,
        Ticker = ticker,
        Denomination = denomination,
        Logo = logo,
        Balances = { [ao.id] = initialBalance }
    }
    
    return token
end

-- 创建 Bull Coin 和 Dai 代币
local bullCoin = initializeToken('Bull', 'BULL', 1, 'optional arweave TXID of BullCoin logo', bint(1000000))
local dai = initializeToken('Dai', 'DAI', 1, 'optional arweave TXID of Dai logo', bint(1000000))

-- 流动性池
local liquidityPool = {
    lastUpdateTime = os.time(),
    lastPrice = bint(1),  -- 示例初始价格：1 DAI = 1 BULL
    daiBalance = dai.Balances[ao.id],
    bullCoinBalance = bullCoin.Balances[ao.id],
    priceHistory = {}
}

-- 计算时间加权平均价格（TWAP）
local function updatePrice()
    local currentTime = os.time()
    local timeElapsed = currentTime - liquidityPool.lastUpdateTime
    
    if timeElapsed > 0 then
        -- 将之前的价格记录添加到历史记录中
        table.insert(liquidityPool.priceHistory, {time = liquidityPool.lastUpdateTime, price = liquidityPool.lastPrice})
        
        -- 更新最后价格和时间
        liquidityPool.lastPrice = liquidityPool.daiBalance / liquidityPool.bullCoinBalance
        liquidityPool.lastUpdateTime = currentTime
    end
end

local function calculateTWAP(startTime, endTime)
    local sumPrice = bint(0)
    local totalTime = 0
    
    for _, record in ipairs(liquidityPool.priceHistory) do
        if record.time >= startTime and record.time <= endTime then
            local duration = endTime - record.time
            sumPrice = sumPrice + (record.price * duration)
            totalTime = totalTime + duration
        end
    end
    
    if totalTime == 0 then
        return liquidityPool.lastPrice
    else
        return sumPrice / totalTime
    end
end

-- 交换函数：将 Dai 兑换为 Bull Coin
 function SwapDaiForBullCoin(user, daiAmount)
    updatePrice()  -- 在交换之前更新价格
    
    local currentTime = os.time()
    local twapPrice = calculateTWAP(currentTime - 3600, currentTime)  -- 示例：1小时 TWAP
    
    local bullCoinAmount = daiAmount / twapPrice

    if dai.Balances[user] < daiAmount then
        return false, "DAI 余额不足"
    end

    if bullCoin.Balances[ao.id] < bullCoinAmount then
        return false, "合约中 BullCoin 余额不足"
    end

    dai.Balances[user] = dai.Balances[user] - daiAmount
    dai.Balances[ao.id] = dai.Balances[ao.id] + daiAmount
    bullCoin.Balances[user] = (bullCoin.Balances[user] or bint(0)) + bullCoinAmount
    bullCoin.Balances[ao.id] = bullCoin.Balances[ao.id] - bullCoinAmount

    return true, "交换成功"
end

-- 转账函数：将 Bull Coin 转账到用户地址
 function TransferBullCoin(sender, recipient, amount)
    if bullCoin.Balances[sender] < amount then
        return false, "BullCoin 余额不足"
    end

    bullCoin.Balances[sender] = bullCoin.Balances[sender] - amount
    bullCoin.Balances[recipient] = (bullCoin.Balances[recipient] or bint(0)) + amount

    return true, "转账成功"
end

-- 提现函数：将用户的 Bull Coin 转换为 Dai
 function WithdrawBullCoin(user)
    local bullCoinBalance = bullCoin.Balances[user] or bint(0)
    if bullCoinBalance == bint(0) then
        return false, "没有 BullCoin 可以提现"
    end

    local daiAmount = bullCoinBalance
    if dai.Balances[ao.id] < daiAmount then
        return false, "合约中 DAI 余额不足"
    end

    bullCoin.Balances[user] = bint(0)
    dai.Balances[user] = (dai.Balances[user] or bint(0)) + daiAmount
    dai.Balances[ao.id] = dai.Balances[ao.id] - daiAmount

    return true, "提现成功"
end

-- 示例用户和操作
local user = 'user1'
dai.Balances[user] = bint(1000)  -- 用户初始 DAI 余额
local success, message = swapDaiForBullCoin(user, bint(500))
print(message)

success, message = transferBullCoin(user, 'user2', bint(100))
print(message)

success, message = withdrawBullCoin(user)
print(message)
