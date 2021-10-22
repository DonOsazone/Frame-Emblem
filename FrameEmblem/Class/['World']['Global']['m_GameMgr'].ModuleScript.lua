-- @author Qiao-Ziao
-- GameManager类负责管理游戏进程的全部逻辑，例如回合切换、伤害计算等
-- GameManager是正式游戏流程中最先创建的，在GameManager创建之后，首先创建
-- EventManager，随后创建并生成地图，最后创建并注册所有Pawn
-- Pawn类创建后必须注册在GameManager中才能正常控制
-- @module GameManager

local m_GameMgr = class("m_GameMgr")

-- 私有属性表
local _private = setmetatable({}, {__mode = "k"})

--! 构造函数
-- 构造函数会创建一个GameManager实例，该实例用于控制
-- @return void
function m_GameMgr:initialize()
    --! 成员变量
    --! 私有
    _private[self] = {
        -- @param bool 记录目前GM所在的状态，是否已经开始运行
        b_running = "false",
        -- @param number 当前的回合数，从1开始计算
        n_current_round = 0,
        -- @param table 记录所有阵营
        -- 每个阵营都是一个table，且为键弱表，其中记录该阵营所属的单位与阵营名称
        -- 阵营的行动顺序由子表在t_teams中的顺序决定
        t_teams = {},
        -- @param table 记录所有注册的pawn
        -- 该表为一个值弱表
        -- 该表共有两种元素类型：
        -- 1、键和值相同，均为Pawn
        -- 2、键为Pawn的别名，字符串类型，值为Pawn
        t_registered_pawns = setmetatable({}, {__mode = "v"}),
        -- @param table 记录所有的玩家
        -- 该表为一个键弱表
        -- 该表以玩家节点或AI为键，以IO实例为值
        t_io_table = setmetatable({}, {__mode = "k"}),
        -- @param number 指向team表中最后一个有效值的下一位
        -- 用于添加阵营时 给阵营分配位置，分配时将作为返回值
        n_teams_tail = 1,
        -- @param number 当前行动阵营顺序索引
        -- 用于实现“下一个阵营”
        n_current_team_index = 1
    }
end

--! 成员函数
--! 公有
-- 初始化函数 该函数会执行以下操作：
-- 1.激活EM
-- 2.创建Gird地图与所有Tile
-- 3.注册所有的玩家（真人或AI）到t_io_table，并进行反向绑定
-- 4.初始化GM逻辑：检查Grid与Tile生成是否正确、检查注册Pawn和阵营是否正确
-- 5.开始第一回合
-- @return bool
function m_GameMgr:Init()
    _private[self].b_running = "true"
    --! 2.创建Gird地图与所有Tile
    --! 3.注册所有的玩家（真人或AI）到t_io_table，并进行反向绑定
    --! 4.初始化GM逻辑：检查Grid与Tile生成是否正确、检查注册Pawn和阵营是否正确
    _private[self].n_current_round = 1
end

-- 修改属性值
-- 由于暂无公有属性，该函数仅实现了私有属性设置
-- @param s_property_name 属性名
-- @param a_value 属性值
-- @return void
function m_GameMgr:Set(s_property_name, a_value)
    if _private[self][s_property_name] then
        -- 检测类型是否合法，合法后执行赋值
        assert(
            type(_private[self][s_property_name]) == type(a_value),
            "[Error]a_value参数类型(" .. type(a_value) .. ")错误，应为:(" .. type(_private[self][s_property_name]) .. ")"
        )
        _private[self][s_property_name] = a_value
    else
        assert(false, "[Error]未检索到名为'" .. s_property_name .. "'的属性")
    end
end

-- 获取s_property_name对应的值
-- 由于暂无公有属性，该函数仅实现了私有属性读取
-- @param s_property_name 字符串类型的属性名
-- @return auto
function m_GameMgr:Get(s_property_name)
    if _private[self][s_property_name] then
        return _private[self][s_property_name]
    else
        assert(false, "[Error]未检索到名为'" .. s_property_name .. "'的属性")
    end
end

-- 下一回合
-- 更改回合数，并让下一个阵营开始行动
-- @return void
function m_GameMgr:NextRound()
    --! 感觉直接用assert太暴力了，还是软纠错吧
    -- assert(_private[self].b_running == "true", '[Error]禁止在游戏未开始时使用"NextRound"')
    -- assert(#_private[self].t_teams ~= 0, '[Error]禁止在"t_teams"表为空时使用"NextRound"')
    if _private[self].b_running ~= "true" then
        print('[Error]禁止在游戏未开始时使用"NextRound"，已拒绝调用')
        return
    elseif #_private[self].t_teams == 0 then
        print('[Error]禁止在"t_teams"表为空时使用"NextRound"，已拒绝调用')
        return
    end

    -- 便捷设置t_teams中索引为n_cur_index的所有Pawn的可移动性
    -- 同时检测该Pawn是否在t_registered_pawns中
    function SetPawnsActive(b_can_move, n_cur_index)
        function IsPawnBeRegistered(p_pawn)
            for pawn_name, the_pawn in pairs(_private[self].t_registered_pawns) do
                if the_pawn == p_pawn then
                    return true
                end
            end
            print("[Error]检测到一个Pawn不在注册表内")
            return false
        end

        for cur_pawn, pawn_can_move in pairs(_private[self].t_teams[n_cur_index]) do
            -- 这里判断该键值对是否为pawn:boolean的依据是table:string，之后可能会有误判
            if type(cur_pawn) == "table" and type(pawn_can_move) == "string" and IsPawnBeRegistered(cur_pawn) then
                pawn_can_move = b_can_move
            end
        end
    end

    -- 设置回合
    _private[self].n_current_round = _private[self].n_current_round + 1

    -- 设置下一阵营所有Pawn的可移动性
    SetPawnsActive("false", _private[self].n_current_team_index)
    repeat
        -- 该do-while是为了跳过顺序中已经轮空的阵营，同时指向下一阵营
        _private[self].n_current_team_index = _private[self].n_current_team_index + 1
        -- 如果超出了(索引到表尾)
        if _private[self].n_current_team_index >= _private[self].n_teams_tail then
            _private[self].n_current_team_index = 1
        end
    until (_private[self].t_teams[_private[self].n_current_team_index] ~= nil)
    SetPawnsActive("true", _private[self].n_current_team_index)

    -- 打印当前回合
    print("[m_GameMgr]当前回合：", _private[self].n_current_round)
end

-- 创建一个阵营，并根据_private[self].n_teams_tail将其插入t_teams中
-- 每个阵营都是一个table，且为键弱表，该表包括以下元素：
-- "name" : s_teamname 该项用于存储阵营名字
-- "controller" : a_player 该项用于记录该阵营的控制方，默认为World节点Players下第一个玩家
-- p_pawn : a_controller 该项以Pawn为键，其是否能够行动(string类型)作为值；此类元素不止一个
-- @return number 所添加的阵营在t_teams中的索引
function m_GameMgr:CreateTeam(s_team_name, t_pawns)
    assert(type(s_team_name) == "string", "[Error]s_team_name不是string类型")
    assert(type(t_pawns) == "table", "[Error]t_pawns不是table类型")
    local temp_table = setmetatable({}, {__mode = "k"})
    temp_table = {
        ["name"] = s_team_name,
        ["controller"] = world:FindPlayers()[1] or "空玩家"
    }
    for _, v_pawn in pairs(t_pawns) do
        temp_table[v_pawn] = "false"
    end
    local return_num = _private[self].n_teams_tail
    _private[self].t_teams[_private[self].n_teams_tail] = temp_table
    _private[self].n_teams_tail = _private[self].n_teams_tail + 1
    return return_num
end

-- 注册一个Pawn到t_registered_pawns
-- 注册后，该Pawn才会被GM承认，并可以收到开始行动的信号
-- 注册时，可以给该Pawn起一个别名。且之后可通过该别名获取到该Pawn
-- 注册时，触发该Pawn的E_OnCreate事件
-- @return void
function m_GameMgr:RegisterPawn(p_pawn, s_pawn_name)
    if s_pawn_name ~= nil then
        assert(type(s_pawn_name) == "string", "[Error]s_pawn_name不是string类型")
        _private[self].t_registered_pawns[s_pawn_name] = p_pawn
    else
        table.insert(_private[self].t_registered_pawns, p_pawn)
    end
    --! 触发该Pawn的E_OnCreate事件
end

-- 注册一个控制者及其IO表
-- @return void
function m_GameMgr:RegisterIO(a_controller, io_command_table)
    _private[self].t_io_table[a_controller] = io_command_table
end

-- 将p_pawn加入索引为n_team_index的队伍中
-- 此函数不包含“注册”操作，请使用RegisterPawn另行注册Pawn
-- @return void
function m_GameMgr:JoinTeam(p_pawn, n_team_index)
    assert(type(n_team_index) == "number", "[Error]n_team_index不是number类型")
    _private[self].t_teams[n_team_index][p_pawn] = "false"
end

-- 测试函数 打印对象的所有属性
-- @return void
function m_GameMgr:PrintMsg()
    print("————↓↓↓————")
    print("是否正在运行 / b_running : ", self:Get("b_running"))
    print("当前回合 / n_current_round : ", self:Get("n_current_round"))
    print("阵营表 / t_teams : ")
    printTable(self:Get("t_teams"))
    print("所有注册Pawn / t_registered_pawns : ")
    printTable(self:Get("t_registered_pawns"))
    print("所有玩家 / t_io_table : ")
    printTable(self:Get("t_io_table"))
    print("————↑↑↑————")
end

--! 事件/被动触发
-- E_RoundBegin()
-- 新回合开始时触发
-- E_RoundEnd()
-- 回合结束时触发

return m_GameMgr
