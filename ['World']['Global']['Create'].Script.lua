local Grid = require(world.Global.Grid)
grid = Grid:new(1,world.PosTable,world.LinkTable)
grid:TestRender()

--该函数用于场景中获取鼠标点击位置处的cube引用
function GetMouseHitCube()
	local mousehit = world.CurrentCamera:ScreenToViewportPoint(Vector3(Input.GetMouseScreenPos().x, Input.GetMouseScreenPos().y, 0))

	local Ray = world.CurrentCamera:ViewportPointToRay(mousehit)
	--括号内为射线检测的距离
    local HitPosition = Ray:GetPoint(30)
	
	local a=Physics:RaycastAll(world.CurrentCamera.Position,HitPosition,false)
	local long = 0
	local hitposinx = 0
	for k,y in pairs(a.HitObjectAll) do
		long = long + 1
		if y.Name == "TileCube" then
			hitposinx = long
			break
		end
	end
	if hitposinx>0 then
		return a.HitObjectAll[hitposinx]
	else
		return nil
	end
end

--测试用
Input.OnKeyDown:Connect(function()
	if Input.GetPressKeyData(Enum.KeyCode.Mouse0) == Enum.KeyState.KeyStatePress then
		if area ~= nil then
			for k,v in pairs(area) do
				v.c_display.HintCube.Color = Color(128,255,0,100)
				v:SetHintActive(false)
			end
		end
		area = {}
		if GetMouseHitCube() ~= nil then
			area = grid:FindMovableArea(grid.t_cube[GetMouseHitCube()].data_x,
			grid.t_cube[GetMouseHitCube()].data_y, 4)
			for k,v in pairs(area) do
				v:SetHintActive(true)
			end
		end
	end
	if Input.GetPressKeyData(Enum.KeyCode.Mouse1) == Enum.KeyState.KeyStatePress then
		if area ~= nil then
			for k,v in pairs(area) do
				v.c_display.HintCube.Color = Color(128,255,0,100)
				v:SetHintActive(false)
			end
		end
	end
end)

Input.OnKeyUp:Connect(function()
	if Input.GetPressKeyData(Enum.KeyCode.Mouse0) == Enum.KeyState.KeyStateRelease then
		if GetMouseHitCube() ~= nil then
			local way = grid:GetPathTo(grid.t_cube[GetMouseHitCube()].data_x,
			grid.t_cube[GetMouseHitCube()].data_y, area)
			for k,v in pairs(way) do
				v.c_display.HintCube.Color = Color(255,128,0,100)
			end
		end
	end
end)