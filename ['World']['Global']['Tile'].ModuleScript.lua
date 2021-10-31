Tile = class("Tile")

function Tile:initialize(n_forward, n_left, n_back, n_right)
	self.n_forward_weight = n_forward
	self.t_forward_tile = nil

	self.n_back_weight = n_back
	self.t_back_tile = nil

	self.n_left_weight = n_left
	self.t_left_tile = nil

	self.n_right_weight = n_right
	self.t_left_tile = nil

--格子拥有的属性列表
	self.t_property = {}

--用于路径遍历时使用
	self.t_root_tile = nil
--用于记录从根节点到自己的最大剩余权
	self.n_root_weight = 0
--用于绑定自己与表示自己用的cube
	self.c_display = nil

	self.t_height = 0

	self.n_grid_x = 0
	self.n_grid_y = 0
--深度优先遍历算法用变量，舍弃
	--self.b_has_been_find = false
end

function Tile:SetHintActive(b_state)
	if self.c_display ~= nil then
		self.c_display.HintCube:SetActive(b_state)
	end
end

return Tile