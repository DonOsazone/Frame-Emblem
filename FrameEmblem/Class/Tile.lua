--- ModuleScript  Tile
--- Created by MangXiao

---未写完

Tile =class("Tile")
---local _private=setmetatable({},{__mode = "k"})

--- @function 构造函数
function Tile:initialize(n_forward, n_back, n_left, n_right)
        --- @param n_forward_weight Tile 格子到前向格子的权重
        --- @param n_back_weight Tile 格子到后向格子的权重
        --- @param n_left_weight Tile 格子到左向格子的权重
        --- @param n_right_weight Tile 格子到右向格子的权重
        self.n_forward_weight=n_forward
        self.n_back_weight=n_back
        self.n_left_weight=n_left
        self.n_right_weight=n_right

        --- 邻接Tile默认是nil，nil表示该Tile与周围四个Tile正常连接
        --- @param t_forward_tile Tile 格子的前向格子引用
        --- @param t_back_tile Tile 格子的后向格子引用
        --- @param t_left_tile Tile 格子的左向格子引用
        --- @param t_right_tile Tile 格子的右向格子引用
        self.t_forward_tile=nil
        self.t_back_tile=nil
        self.t_left_tile=nil
        self.t_right_tile=nil

        --- @param t_property Tile 格子的属性列表
        self.t_property={}

        --- @param t_property Tile 仅用于路径遍历时使用
        self.t_root_tile=nil

        --- @param t_height Tile 格子的高度
        self.t_height=1

        --- @param n_grid_x Tile 格子在Grid中的x坐标
        --- @param n_grid_y Tile 格子在Grid中的y坐标
        self.n_grid_x=0
        self.n_grid_y=0
end

--- @function SetHintActive 控制地图高亮块的显隐
---@param b_state boolean 当b_state为true时高亮块显示，为false隐藏
function Tile: SetHintActive(b_state)
    if b_state then
        ---地图高亮块显示
    else
        ---地图高亮快隐藏   
    end
end 

--- @function AddFeature 为格子添加属性
function Tile:AddFeature(feature)
    
end

return Tile