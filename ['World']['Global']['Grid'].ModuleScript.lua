Grid = class("Grid")
local Tile = require(world.Global.Tile)

local t_tiles_data = {}
local n_tile_size

--用于表示tile高度的变量，被移至Tile类中了
--local n_tile_height

local v3_grid_offset

local _private = setmetatable({}, {__mode = "k"})	

function Grid:initialize(n_tile_size, o_property_csv, o_weight_csv, o_height_csv)
--用于存储TestRender中显示用的cube，key为cube引用，value为该cube对应的tile在grid中的二维数组维度值
	self.t_cube = {}

	_private[self] = {	
		n_tile_size = n_tile_size
	}
	local tab = o_property_csv
	local wei = o_weight_csv
	local x,y,z
	for k,v in pairs(tab:GetRows()) do
		for l,b in pairs(v) do
			if l == "坐标x" then
				x = b
			elseif l == "坐标y" then
				y = b
			elseif l == "坐标z" then
				z = b
			end
		end
		tile = Tile:new(wei:GetCell("权重y+1",k),wei:GetCell("权重x-1",k),wei:GetCell("权重y-1",k),wei:GetCell("权重x+1",k))		
		tile.n_grid_x = x
		tile.n_grid_y = z
		
		tile.n_height = y
		
		--下面建立tile的链接
		if t_tiles_data[x] == nil then
			t_tiles_data[x] = {}
		end
		t_tiles_data[x][z]=tile
		if t_tiles_data[x]~= nil and t_tiles_data[x][z+1]~=nil then
			t_tiles_data[x][z+1].t_back_tile = tile
			tile.t_forward_tile = t_tiles_data[x][z+1]
		end
		if t_tiles_data[x-1]~= nil and t_tiles_data[x-1][z]~=nil then
			t_tiles_data[x-1][z].t_right_tile = tile
			tile.t_left_tile = t_tiles_data[x-1][z]
		end
		if t_tiles_data[x]~= nil and t_tiles_data[x][z-1]~=nil then
			t_tiles_data[x][z-1].t_forward_tile = tile
			tile.t_back_tile = t_tiles_data[x][z-1]
		end
		if t_tiles_data[x+1]~= nil and t_tiles_data[x+1][z]~=nil then
			t_tiles_data[x+1][z].t_left_tile = tile
			tile.t_right_tile = t_tiles_data[x+1][z]
		end
	end
end

function Grid:FindMovableArea(n_x, n_y, n_max_distance)
	local tile = t_tiles_data[n_x][n_y]
	local rootTile = tile
	rootTile.n_root_weight = n_max_distance
	local queue = {rootTile}
	local has_check = {}
	has_check[rootTile] = 1
	local result = {}
	
	for k,v in ipairs(queue) do
		local tmpDis = v.n_root_weight
		rootTile = v
		if tonumber(rootTile.n_forward_weight) ~= nil then
			if tonumber(rootTile.n_forward_weight) <= tmpDis and rootTile.t_forward_tile ~= rootTile.t_root_tile then
				if rootTile.t_forward_tile.n_root_weight <= tmpDis - tonumber(rootTile.n_forward_weight) then
					if has_check[rootTile.t_forward_tile] == nil then
						has_check[rootTile.t_forward_tile] = 1
					end
					table.insert(queue,rootTile.t_forward_tile)
					rootTile.t_forward_tile.n_root_weight = tmpDis - tonumber(rootTile.n_forward_weight)
					rootTile.t_forward_tile.t_root_tile = rootTile
				end
			end
		end
		if tonumber(rootTile.n_back_weight) ~= nil then
			if tonumber(rootTile.n_back_weight) <= tmpDis and rootTile.t_back_tile ~= rootTile.t_root_tile then
				if rootTile.t_back_tile.n_root_weight <= tmpDis - tonumber(rootTile.n_back_weight) then
					if has_check[rootTile.t_back_tile] == nil then
						has_check[rootTile.t_back_tile] = 1
					end
					table.insert(queue,rootTile.t_back_tile)
					rootTile.t_back_tile.n_root_weight = tmpDis - tonumber(rootTile.n_back_weight)
					rootTile.t_back_tile.t_root_tile = rootTile

				end
			end
		end
		if tonumber(rootTile.n_left_weight) ~= nil then
			if tonumber(rootTile.n_left_weight) <= tmpDis and rootTile.t_left_tile ~= rootTile.t_root_tile then
				if rootTile.t_left_tile.n_root_weight <= tmpDis - tonumber(rootTile.n_left_weight) then
					if has_check[rootTile.t_left_tile] == nil then
						has_check[rootTile.t_left_tile] = 1
					end
					table.insert(queue,rootTile.t_left_tile)
					rootTile.t_left_tile.n_root_weight = tmpDis - tonumber(rootTile.n_left_weight)
					rootTile.t_left_tile.t_root_tile = rootTile
				end
			end
		end
		if tonumber(rootTile.n_right_weight) ~= nil then
			if tonumber(rootTile.n_right_weight) <= tmpDis and rootTile.t_right_tile ~= rootTile.t_root_tile then
				if rootTile.t_right_tile.n_root_weight <= tmpDis - tonumber(rootTile.n_right_weight) then
					if has_check[rootTile.t_right_tile] == nil then
						has_check[rootTile.t_right_tile] = 1
					end
					table.insert(queue,rootTile.t_right_tile)
					rootTile.t_right_tile.n_root_weight = tmpDis - tonumber(rootTile.n_right_weight)
					rootTile.t_right_tile.t_root_tile = rootTile
				end
			end
		end
	end
	for k,v in pairs(has_check) do
		table.insert(result,k)
		k.n_root_weight = 0
	end
	return result
end

function Grid:FindVisualArea(n_x, n_y, n_max_distance)
	local tile = t_tiles_data[n_x][n_y]
	local rootTile = tile
	rootTile.n_root_weight = n_max_distance
	local queue = {rootTile}
	has_check = {}
	has_check[rootTile] = 1
	local result = {}
	
	for k,v in ipairs(queue) do
		local tmpDis = v.n_root_weight
		rootTile = v
		if tonumber(rootTile.n_forward_weight) ~= nil then
			if 1 <= tmpDis and rootTile.t_forward_tile ~= rootTile.t_root_tile then
				if rootTile.t_forward_tile.n_root_weight <= tmpDis - 1 then
					if has_check[rootTile.t_forward_tile] == nil then
						has_check[rootTile.t_forward_tile] = 1
					end					
					table.insert(queue,rootTile.t_forward_tile)
					rootTile.t_forward_tile.n_root_weight = tmpDis - 1
					rootTile.t_forward_tile.t_root_tile = rootTile
				end
			end
		end
		if tonumber(rootTile.n_back_weight) ~= nil then
			if 1 <= tmpDis and rootTile.t_back_tile ~= rootTile.t_root_tile then
				if rootTile.t_back_tile.n_root_weight <= tmpDis - 1 then
					if has_check[rootTile.t_back_tile] == nil then
						has_check[rootTile.t_back_tile] = 1
					end
					table.insert(queue,rootTile.t_back_tile)
					rootTile.t_back_tile.n_root_weight = tmpDis - 1
					rootTile.t_back_tile.t_root_tile = rootTile
				end
			end
		end
		if tonumber(rootTile.n_left_weight) ~= nil then
			if 1 <= tmpDis and rootTile.t_left_tile ~= rootTile.t_root_tile then
				if rootTile.t_left_tile.n_root_weight <= tmpDis - 1 then
					if has_check[rootTile.t_left_tile] == nil then
						has_check[rootTile.t_left_tile] = 1
					end
					table.insert(queue,rootTile.t_left_tile)
					rootTile.t_left_tile.n_root_weight = tmpDis - 1
					rootTile.t_left_tile.t_root_tile = rootTile
				end
			end
		end
		if tonumber(rootTile.n_right_weight) ~= nil then
			if 1 <= tmpDis and rootTile.t_right_tile ~= rootTile.t_root_tile then
				if rootTile.t_right_tile.n_root_weight <= 1 then
					if has_check[rootTile.t_right_tile] == nil then
						has_check[rootTile.t_right_tile] = 1
					end
					table.insert(queue,rootTile.t_right_tile)
					rootTile.t_right_tile.n_root_weight = tmpDis - 1
					rootTile.t_right_tile.t_root_tile = rootTile
				end
			end
		end
	end
	for k,v in pairs(has_check) do
		table.insert(result,k)
		k.n_root_weight = 0
	end
	return result
end

function Grid:GetPathTo(n_x, n_y, t_area)
	local aimTile = nil
	local only_check={}
	local result = {}
	local limit = 0
	for k,v in pairs(t_area) do
		limit = limit + 1
		if v.n_grid_x == n_x and v.n_grid_y == n_y then
			aimTile = v
		end
	end
	while (aimTile ~= nil and  limit > 0)
	do
		if only_check[aimTile] == nil then
			only_check[aimTile] = 1
		end
		aimTile = aimTile.t_root_tile
		limit = limit - 1
	end
	for k,v in pairs(only_check) do
		table.insert(result,1,k)
	end
	for k,v in pairs(t_area) do
		v.t_root_tile = nil
	end
	return result
end

function Grid:WorldPositionToGridPosition(v3_world_position)

end

function Grid:GridPositionToWorldPosition(n_grid_x, n_grid_y)

end

function Grid:TestRender()
	for k,v in pairs(t_tiles_data) do
		for l,b in pairs(v) do
			local x = b.n_grid_x
			local z = b.n_grid_y
			local y = b.n_height
			
			local n_tile_size = _private[self].n_tile_size
			
			cube = world:CreateInstance("GridCube","TileCube",world,Vector3(x*n_tile_size,y*n_tile_size,z*n_tile_size))
			cube.Size = cube.Size*n_tile_size
			b.c_display = cube
			self.t_cube[cube] = {data_x = k,data_y = l}
		end
	end
end

----以下为深度优先遍历，权重低的优先，会有绕路问题，所以改为上面的求最小生成树了。
--[[
function Grid:FindMovableArea(n_x, n_y, n_max_distance)
	local tile = t_tiles_data[n_x][n_y]
	local surplusDis = n_max_distance
	local rootTile = tile
	local stack = {rootTile}
	local result = {}
	
	while stack[1] ~= nil
	do
		local near = nil
		local tmpDis = surplusDis
		for k,v in ipairs(stack) do
			rootTile = v
		end
		if rootTile.n_forward_weight ~= 'nil' then
			if tonumber(rootTile.n_forward_weight) <= tmpDis and rootTile.t_forward_tile.b_has_been_find == false and rootTile.t_forward_tile ~= rootTile.t_root_tile then
				near = rootTile.t_forward_tile
				tmpDis = tonumber(rootTile.n_forward_weight)
			end
		end
		if rootTile.n_back_weight ~= 'nil' then
			if tonumber(rootTile.n_back_weight) <= tmpDis and rootTile.t_back_tile.b_has_been_find == false and rootTile.t_back_tile ~= rootTile.t_root_tile then
				near = rootTile.t_back_tile
				tmpDis = tonumber(rootTile.n_back_weight)
			end
		end
		if rootTile.n_left_weight ~= 'nil' then
			if tonumber(rootTile.n_left_weight) <= tmpDis and rootTile.t_left_tile.b_has_been_find == false and rootTile.t_left_tile ~= rootTile.t_root_tile then
				near = rootTile.t_left_tile
				tmpDis = tonumber(rootTile.n_left_weight)
			end
		end
		if rootTile.n_right_weight ~= 'nil' then
			if tonumber(rootTile.n_right_weight) <= tmpDis and rootTile.t_right_tile.b_has_been_find == false and rootTile.t_right_tile ~= rootTile.t_root_tile then
				near = rootTile.t_right_tile
				tmpDis = tonumber(rootTile.n_right_weight)
			end
		end
		
		if near ~= nil then
			table.insert(stack,near)
			near.t_root_tile = rootTile
			near.n_root_weight = tmpDis
			rootTile = near
			surplusDis = surplusDis - tmpDis
		else
			rootTile.b_has_been_find = true
			table.remove(stack)
			table.insert(result,rootTile)
			if rootTile.t_root_tile ~= nil then
				surplusDis = surplusDis + rootTile.n_root_weight
			end
		end
	end
	for k,v in pairs(result) do
		v.b_has_been_find = false
	end
	return result
end

function Grid:FindVisualArea(n_x, n_y, n_max_distance)
	local tile = t_tiles_data[n_x][n_y]
	local surplusDis = n_max_distance
	local rootTile = tile
	local stack = {rootTile}
	local result = {}
	
	while stack[1] ~= nil
	do
		local near = nil
		local tmpDis = surplusDis
		for k,v in ipairs(stack) do
			rootTile = v
		end
		if rootTile.n_forward_weight ~= 'nil' then
			if tmpDis >= 1 and rootTile.t_forward_tile.b_has_been_find == false then
				near = rootTile.t_forward_tile
			end
		end
		if rootTile.n_back_weight ~= 'nil' then
			if tmpDis >= 1 and rootTile.t_back_tile.b_has_been_find == false then
				near = rootTile.t_back_tile
			end
		end
		if rootTile.n_left_weight ~= 'nil' then
			if tmpDis >= 1 and rootTile.t_left_tile.b_has_been_find == false then
				near = rootTile.t_left_tile
			end
		end
		if rootTile.n_right_weight ~= 'nil' then
			if tmpDis >= 1 and rootTile.t_right_tile.b_has_been_find == false then
				near = rootTile.t_right_tile
			end
		end
		
		if near ~= nil then
			table.insert(stack,near)
			near.t_root_tile = rootTile
			rootTile = near
			surplusDis = surplusDis - 1
		else
			rootTile.b_has_been_find = true
			table.remove(stack)
			table.insert(result,rootTile)
			if rootTile.t_root_tile ~= nil then
				surplusDis = surplusDis + 1
			end
		end
	end
	for k,v in pairs(result) do
		v.b_has_been_find = false
	end
	return result
end
]]--

return Grid