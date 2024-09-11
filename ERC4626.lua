-- 定义Vault对象
Vault = {}
Vault.__index = Vault

function Vault:new(assetBalance, totalShares)
    local instance = {
        assetBalance = assetBalance or 0, -- 金库的资产总量
        totalShares = totalShares or 0, -- 金库的总股份
        shares = {} -- 每个用户的股份
    }
    setmetatable(instance, Vault)
    return instance
end

function Vault:deposit(amount, user)
    if amount <= 0 then
        return "Amount must be greater than zero"
    end

    -- 计算股份数量
    local sharesToMint = 0
    if self.totalShares == 0 then
        sharesToMint = amount -- 初始股份等于存入的资产
    else
        sharesToMint = (amount * self.totalShares) / self.assetBalance
    end

    -- 更新金库的资产和股份
    self.assetBalance = self.assetBalance + amount
    self.totalShares = self.totalShares + sharesToMint
    self.shares[user] = (self.shares[user] or 0) + sharesToMint

    return sharesToMint
end

-- 提取资产，返回资产数量
function Vault:withdraw(shares, user)
    local userShares = self.shares[user] or 0
    if shares > userShares then
        return "Insufficient shares"
    end

    -- 计算提取的资产数量
    local assetsToWithdraw = (shares * self.assetBalance) / self.totalShares

    -- 更新金库的资产和股份
    self.assetBalance = self.assetBalance - assetsToWithdraw
    self.totalShares = self.totalShares - shares
    self.shares[user] = userShares - shares

    return assetsToWithdraw
end

-- 查询用户的股份
function Vault:getShares(user)
    return self.shares[user] or 0
end

-- 查询金库的资产总量
function Vault:getAssetBalance()
    return self.assetBalance
end

-- 示例用法
local vault = Vault:new(1000, 100) -- 初始资产为1000，股份为100
print("User1 deposits 500 assets and receives shares:", vault:deposit(500, "User1"))
print("User1 total shares:", vault:getShares("User1"))
print("User1 withdraws 50 shares and receives assets:", vault:withdraw(50, "User1"))
print("Vault's asset balance:", vault:getAssetBalance())
