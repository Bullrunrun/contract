# contract
bull的合约端

## 1.Token.lua
- Info(): 返回代币参数，如名称、代号、徽标和计量单位
- Balance(Target?: string): 返回目标的代币余额。如果未提供目标，则默认发送者为目标
- Balances(): 返回所有参与者的代币余额
- Transfer(Target: string, Quantity: number): 如果发送者有足够的余额，则将指定数量的代币发送给目标。还会向目标发送信用通知，并向发送者发送借记通知
- Mint(Quantity: number): 如果发送者匹配进程所有者，则铸造所需数量的代币，并将其添加到进程的余额中
- Total-Supply(): 返回代币的总供应量
- Burn(Quantity: number):  销毁指定数量的代币，从地址中扣除

## 2.EazyGame.lua
- get_random_numbers()  获得1-5的随机数字用于生成牛，返回的是长度为5的数组，数组里有五个元素，为避免时间问题
- get_bull_1(recipient) 套中数字为1的牛后，判断是否获得代币，recipient是用户地址
- get_bull_2(recipient)
- .....同上

## 3.HardGame.lua
- get_random_numbers()  获得1-5的随机数字用于生成牛，返回的是长度为10的数组，数组里有10个元素，为避免时间问题
其余同EazyGame.lua
