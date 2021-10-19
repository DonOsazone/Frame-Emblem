--- ModuleScript  Skill
--- Created by Gyss
--- Latest Editted by Gyss
Skill = class("Skill")

local _private = setmetatable({}, {__mode = "k"})

--- @function initialize 构造函数
function Skill:initialize()

    --- 技能的伤害事件，用于计算技能的伤害效果与数值
    --- @param p_from PawnInstance 技能施法者
    --- @param p_to PawnInstance 技能施放目标
    self.E_Damage = Event()

    --- 技能的治愈事件，用于计算技能对目标单位的治愈效果
    --- @param p_from PawnInstance 技能施法者
    --- @param p_to PawnInstance 技能施放目标
    self.E_Heal = Event()

    --- 技能的Buff更改事件，当技能会对目标的Buff产生变化时，使用该事件处理
    --- @param p_from PawnInstance 技能施法者
    --- @param p_to PawnInstance 技能施放目标
    self.E_ChangeBuff = Event()

    --- 技能的其他效果事件，当技能对地图产生其他副效果或进行其他处理时，使用该事件处理
    --- @param p_from PawnInstance 技能施法者
    --- @param p_to PawnInstance 技能施放目标
    --- @param v2_target_position Vector2 技能施放的目标位置
    self.E_OtherEffect = Event()

    --- 技能施法消耗，施放技能需要消耗的MP值
    self.n_cost = 0

    --- 子技能队列
    _private[self].t_sub_skills = {}
end

--[[
    对子技能的解释：
    一个技能在释放后，如果还需要对技能进行进一步的扩展操作，此时可使用子技能
    子技能的本质也是Skill，但子技能内部可以进一步嵌套其他子技能
    若不使用子技能，原生的Skill最大捕获为一人，这在制作范围攻击或群体效果时会非常棘手
    借助子技能，开发者可以将一个群攻技能进行包装，计算所有的合法单位，并依次对其施放子技能
    如果仍然难以理解，可参考下方的示例——
    【流星火雨：在场地内召唤3~5枚陨石，陨石随机落在场地内，对以落点为中心3*3范围内的所有敌方单位造成伤害】
    使用子技能后，其嵌套如下——
    施放【流星火雨】技能 -> 随机选择3~5个场景内落点，每个落点触发一次子技能【陨石】 -> 子技能【陨石】施放 -> 技能施放点3*3范围内的所有单位触发一次子技能【流星火雨伤害】 -> 子技能【流星火雨伤害】施放 -> 目标单位的生命值减少 -> 技能施放结束
]]

function Skill:Release(p_from,p_to,v2_target_position)
    if self.n_cost > p_from:Get("n_magic") then
        return
    else
        -- 计算并实施技能消耗【因Buff尚未实装，此处为暂代方案】
        p_from:Increase("n_magic",-1*self.n_cost)

        -- 事件触发顺序如下：
        -- E_Damage -> E_Heal -> E_ChangeBuff -> E_OtherEffect
        EventManager:AddEvent(self.E_Damage, {p_from,p_to})
        EventManager:AddEvent(self.E_Heal, {p_from,p_to})
        EventManager:AddEvent(self.E_ChangeBuff, {p_from,p_to})
        EventManager:AddEvent(self.E_OtherEffect, {p_from,p_to,v2_target_position})
        for _, SubSkill in ipairs(_private[self].t_sub_skills) do
            _SubRelease(SubSkill,p_from,p_to,v2_target_position)
        end
        -- 沟通GM，技能施放结束，由GM判断下一步动作
        -- 留待GM制作完成后决定
    end
end

local function _SubRelease(self,p_from,p_to,v2_target_position)
    -- 子技能通常不会有额外消耗
    -- 计算并实施技能消耗【因Buff尚未实装，此处为暂代方案】
    p_from:Increase("n_magic",-1*self.n_cost)

    -- 事件触发顺序如下：
    -- E_Damage -> E_Heal -> E_ChangeBuff -> E_OtherEffect
    EventManager:AddEvent(self.E_Damage, {p_from,p_to})
    EventManager:AddEvent(self.E_Heal, {p_from,p_to})
    EventManager:AddEvent(self.E_ChangeBuff, {p_from,p_to})
    EventManager:AddEvent(self.E_OtherEffect, {p_from,p_to,v2_target_position})
    for _, SubSkill in ipairs(_private[self].t_sub_skills) do
        _SubRelease(SubSkill,p_from,p_to,v2_target_position)
    end
end


return Skill