local json = require("json")
local sqlite3 = require("sqlite3")

-- 使用内存数据库，你可以换成持久性数据库
DB = DB or sqlite3.open_memory()

-- 创建用户表，包含 balance 字段
DB:exec [[
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    password TEXT,
    createdAt INT,
    updatedAt INT,
    address TEXT UNIQUE,
    score INT DEFAULT 0,
    balance INTEGER DEFAULT 0
  );
]]

-- 执行 SQL 查询并返回结果
local function query(stmt)
  local rows = {}
  for row in stmt:nrows() do
    table.insert(rows, row)
  end
  stmt:reset()
  return rows
end

-- 获取用户的得分
local function getscore(n)
  local stmt = DB:prepare [[
    SELECT * FROM users ORDER BY score DESC LIMIT :limit;
  ]]

  if not stmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  stmt:bind_names({ limit = n })

  local rows = query(stmt)
  return rows
end

-- 检查用户名是否唯一
local function checkUsernameUnique(msg)
  local dataJson = json.decode(msg.Data)
  local username = dataJson.username

  -- 检查用户名是否已存在
  local stmt = DB:prepare [[
    SELECT * FROM users WHERE username = :username;
  ]]

  if not stmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  stmt:bind_names({ username = username })

  local existingUser = query(stmt)[1]

  local result
  if existingUser then
    result = json.encode({ unique = false })
  else
    result = json.encode({ unique = true })
  end

  Handlers.utils.reply(result)(msg)

  stmt:reset()
  stmt:finalize()
end

-- 初始化用户
local function initUser(data, timestamp)
  -- 解码 JSON 数据
  local dataJson = json.decode(data)
  local username = dataJson.username
  local email = dataJson.email
  local password = dataJson.password
  local address = dataJson.address
  local balance = dataJson.balance or 0 -- 默认值为0

  -- 检查用户名是否已存在
  local checkUsernameStmt = DB:prepare [[
    SELECT * FROM users WHERE username = :username;
  ]]

  if not checkUsernameStmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  checkUsernameStmt:bind_names({ username = username })

  local existingUser = query(checkUsernameStmt)[1]

  if existingUser then
    print("错误: 用户名已存在")
    Handlers.utils.reply("错误: 用户名已存在")
    return
  end

  -- 准备 SQL 语句
  local stmt = DB:prepare [[
    INSERT INTO users (username, email, password, createdAt, updatedAt, address, score, balance)
    VALUES (:username, :email, :password, :createdAt, :updatedAt, :address, :score, :balance);
  ]]

  if not stmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  -- 绑定值到语句中
  stmt:bind_names({
    username = username,
    email = email,
    password = password,
    createdAt = timestamp,
    updatedAt = timestamp,
    address = address,
    score = 0,
    balance = balance
  })

  -- 执行语句
  local result = stmt:step()
  if result ~= sqlite3.DONE then
    print("错误: 无法添加用户")
    Handlers.utils.reply("错误: 无法添加用户")
  else
    print('用户已添加!')
    Handlers.utils.reply("用户已添加!")
  end

  -- 重置并终结语句
  checkUsernameStmt:reset()
  checkUsernameStmt:finalize()
  stmt:reset()
  stmt:finalize()
end

-- 获取用户信息
local function getUser(data)
  local dataJson = json.decode(data)
  local username = dataJson.username
  local stmt = DB:prepare [[
    SELECT * FROM users WHERE username = :username;
  ]]

  if not stmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  stmt:bind_names({ username = username })

  local rows = query(stmt)
  return rows
end

-- 获取所有用户信息
local function getAllUsers()
  local stmt = DB:prepare [[
    SELECT * FROM users;
  ]]

  if not stmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  local rows = query(stmt)
  
  return rows
end

-- 更新用户数据
local function updateUserData(user, data)
  local currentUserStmt = DB:prepare [[
    SELECT * FROM users WHERE username = :username;
  ]]

  if not currentUserStmt then
    error("准备 SQL 语句失败: " .. DB:errmsg())
  end

  currentUserStmt:bind_names({ username = user.username })

  local currentUser = query(currentUserStmt)[1]

  if currentUser then
    local dataJson = json.decode(data)
    local newEmail = dataJson.email
    local newPassword = dataJson.password
    local newBalance = dataJson.balance -- 新增字段

    local stmt = DB:prepare [[
      UPDATE users SET email = :email, password = :password, balance = :balance, updatedAt = :updatedAt WHERE username = :username;
    ]]

    if not stmt then
      error("准备 SQL 语句失败: " .. DB:errmsg())
    end

    stmt:bind_names({
      username = user.username,
      email = newEmail,
      password = newPassword,
      balance = newBalance, -- 新增字段
      updatedAt = os.time()
    })

    stmt:step()
    stmt:reset()
    print('用户数据已更新!')
    Handlers.utils.reply("用户数据已更新!")(user)
  else
    print('用户未找到.')
    Handlers.utils.reply("用户未找到.")(user)
  end
end

-- 添加初始化用户的 Handler
Handlers.add(
  "initUser",
  Handlers.utils.hasMatchingTag("Action", "initUser"),
  function (msg)
    initUser(msg.Data, msg.Timestamp)
  end
)

-- 添加获取用户信息的 Handler
Handlers.add(
  "getUser",
  Handlers.utils.hasMatchingTag("Action", "getUser"),
  function (msg)
    local user = getUser(msg.Data)
    local usersJson = json.encode(user)
    print(user)
    Handlers.utils.reply(usersJson)(msg)
  end
)

-- 添加获取所有用户信息的 Handler
Handlers.add(
  "getAllUsers",
  Handlers.utils.hasMatchingTag("Action", "getAllUsers"),
  function (msg)
    local users = getAllUsers()
    print(users)
    local usersJson = json.encode(users)
    Handlers.utils.reply(usersJson)(msg)
  end
)

-- 添加更新用户数据的 Handler
Handlers.add(
  "updateUserData",
  Handlers.utils.hasMatchingTag("Action", "updateUserData"),
  function (msg)
    local user = getUser(msg.Data)[1]
    if user then
      updateUserData(user, msg.Data)
    else
      Handlers.utils.reply("用户未找到!")(msg)
    end
  end
)

-- 添加获取用户数量的 Handler
Handlers.add(
  "getCount",
  Handlers.utils.hasMatchingTag("Action", "getCount"),
  function (msg)
    local stmt = DB:prepare [[
      SELECT COUNT(*) AS count FROM users;
    ]]
  
    if not stmt then
      error("准备 SQL 语句失败: " .. DB:errmsg())
    end
  
    local rows = query(stmt)
    print(rows[1].count)
    Handlers.utils.reply(tostring(rows[1].count))(msg)
  end
)

-- 添加检查用户名唯一性的 Handler
Handlers.add(
  "checkUsernameUnique",
  Handlers.utils.hasMatchingTag("Action", "checkUsernameUnique"),
  function (msg)
    checkUsernameUnique(msg)
  end
)

-- 添加获取用户得分的 Handler
Handlers.add(
  "getscore",
  Handlers.utils.hasMatchingTag("Action", "getscore"),
  function (msg)
    local n = tonumber(msg.Data) or 10 -- 默认返回前10名用户
    local users = getscore(n)
    local usersJson = json.encode(users)
    Handlers.utils.reply(usersJson)(msg)
  end
)

-- 添加信息介绍的 Handler
Handlers.add(
  "Info",
  Handlers.utils.hasMatchingTag("Action", "Info"),
  function (msg)
    local info = [[
这个模块处理用户管理，包括创建、检索、更新和列出用户。核心功能基于 SQLite 数据库。

1. **数据库设置**
   - 使用 SQLite 数据库，可以是内存数据库或持久性数据库。
   - 创建 `users` 表来存储用户详细信息，并在 `username` 和 `email` 字段上设置唯一约束。

2. **函数**

   - `query(stmt)`: 执行准备好的 SQL 语句并返回结果行。
   - `initUser(user, timestamp)`: 向数据库中添加新用户。字段包括 `username`、`email`、`password`、`createdAt` 和 `updatedAt`。如果用户名已存在，则返回错误消息。
   - `getUser(username)`: 根据提供的用户名检索用户详细信息。
   - `getAllUsers()`: 检索数据库中所有用户的详细信息。
   - `updateUserData(user, data)`: 根据提供的信息更新用户数据。

3. **Handlers**

   - `"initUser"`: 向数据库中添加新用户。
   - `"getUser"`: 根据用户名检索用户的详细信息。
   - `"getAllUsers"`: 检索所有用户的详细信息。
   - `"updateUserData"`: 根据提供的用户名和新数据更新用户数据。

每个处理器与一个动作标签相关联，并使用实用函数回复适当的消息或错误。
      ]]
    Handlers.utils.reply(info)(msg)
  end
)
