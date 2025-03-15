local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local guiser = game:GetService("GuiService")
--
local camera = workspace.CurrentCamera
local lastcamcf = camera.CFrame
local camX, camY = 0,0
local velX, velY = 0,0
local destinationX, destinationY = 0,0
local tool = script.Parent
local equiptick = tick()
local animcf = CFrame.new()
local tfind = table.find
local sin = math.sin
local cos = math.cos
--
local remote = tool:WaitForChild("fistremote")
local gui = tool:WaitForChild("fistgui")
local bars = gui:WaitForChild("bars")
local cross = gui:WaitForChild("crosshair")
local crit = cross:WaitForChild("crit")
--
local owner
local character
local charroot
local charhum
local charhead
local chartorso
local rayholder
local animroot
local animrootweld
local lookpart
local wasautorotated
local steppedfunc
--
local currentwelds = {} --dont repeat names
local ignoretable = {}
local currentattachments = {}
local bartable = {}
local moveoncooldown = {}
local myhats = {}
local horriblestates = {Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Flying}
--
local trackmouseY = true
local trackmouselook = true
local holdinglmb = false
--
local transparencylimbs = {
	["Head"] = 1,
	["Torso"] = 1,
	["Left Arm"] = 0.1,
	["Right Arm"] = 0.1,
	["Left Leg"] = 0.3,
	["Right Leg"] = 0.3,
}
--
local maxlookdown = -1.25
local k = 0.15
local friction = 0.35
local hitmarkerSoundID = "rbxassetid://6735107335"
local hitmarkerVolume = 3.5
local hitmarkerPlaybackSpeed = 1
local hitmarkerTimePosition = 0.1

_G.fistvis = false --raycast hitbox visualizer (warning will lag)

--[[local ignoreproxy = setmetatable({}, { --evil proxy metatable that remains unused
	__newindex = function(self, key)
		for i,v in pairs(ignoretable) do
			if not v:IsDescendantOf(game) then
				print(v,"is not ingame")
				table.remove(ignoretable, tfind(ignoretable, v))
			end
		end
		table.insert(ignoretable, key)
	end,
})--]]

local linearlerp = function(a,b,t)
	return a+(b-a)*t
end

local getvel = function(difference, vel, del)
	local offset = (difference*k)
	local vel = (vel * (1 - friction)) + offset
	return vel
end

local tween = function(speed, easingstyle, easingdirection, loopcount, WHAT, goal)
	local info = TweenInfo.new(
		speed,
		easingstyle,
		easingdirection,
		loopcount
	)
	local goals = goal
	local anim = tweenservice:Create(WHAT, info, goals)
	anim:Play()
end

local ws = function()
	return charhum.WalkSpeed/16
end

for i,v in pairs(bars:GetChildren()) do
	bartable[string.gsub(v.Name, "bars", "")] = {
		["shadow"] = v.behindbar,
		["load"] = v.behindbar.loadbar,
		["usetick"] = tick()
	}
	v.behindbar.loadbar.Rotation = 180
	v.behindbar.Visible = false
	v.behindbar.loadbar.Visible = true
end

local parentfindfirstchildofclass = function(cname, search)
	local par = search
	local foundinstance
	while par ~= workspace and not foundinstance do
		foundinstance = par:FindFirstChildOfClass(cname)
		par = par.Parent
	end
	return foundinstance
end

local starthitbox = function(attachmenttable, duration, multihit)
	if rayholder then
		rayholder:Disconnect()
	end
	local savetick = tick()
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Blacklist
	rayparams.FilterDescendantsInstances = ignoretable
	local lastattachpos = {}
	local hitpeople = {}
	for i,v in pairs(attachmenttable) do
		table.insert(lastattachpos, {v, v.WorldPosition})
	end
	rayholder = runservice.RenderStepped:Connect(function()
		--print("scanning "..attachmenttable[1].Parent.Name)
		if tick() >= savetick + duration then
			rayholder:Disconnect()
		end
		for i,v in pairs(lastattachpos) do
			local subt = v[2] - v[1].WorldPosition
			local ray = workspace:Raycast(v[2], -subt.Unit*subt.Magnitude, rayparams)
			if ray then
				local findhum = parentfindfirstchildofclass("Humanoid", ray.Instance) or ray.Instance
				if multihit then
					if not tfind(hitpeople, findhum) then
						table.insert(hitpeople, findhum)
						remote:FireServer("part", ray.Instance, ray.Position, ray.Normal)
						--print("boom:")
					end
				else
					remote:FireServer("part", ray.Instance, ray.Position, ray.Normal)
					rayholder:Disconnect()
				end
			end
			if _G.fistvis then
				local raypos = v[2] + (-subt.Unit*subt.Magnitude)
				local p = Instance.new("Part")
				p.Anchored = true
				p.CanCollide = false
				p.CanTouch = false
				p.CanQuery = false
				p.Transparency = 0.8
				p.BrickColor = BrickColor.new("Lime green")
				p.Material = "SmoothPlastic"
				p.Size = Vector3.new(0.1,0.1,(v[2]-raypos).Magnitude)
				p.CFrame = CFrame.new(v[2] , raypos) * CFrame.new(0,0,-(v[2]-raypos).Magnitude/2)
				p.Parent = workspace
				game.Debris:AddItem(p, duration+0.25)
			end
			lastattachpos[i] = nil
		end
		for i,v in pairs(attachmenttable) do
			table.insert(lastattachpos, {v, v.WorldPosition})
		end
	end)
end

local serverresponse = {
	["changestate"] = function(state)
		charhum:ChangeState(state)
	end,
	["showredcross"] = function(speed)
		local ht = Instance.new("Sound", gui)
		ht.SoundId = hitmarkerSoundID
		ht.Volume = hitmarkerVolume
		ht.PlaybackSpeed = hitmarkerPlaybackSpeed
		ht.TimePosition = hitmarkerTimePosition
		ht:Play()
		crit.Visible = true
		crit.ImageTransparency = 0
		tween(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, crit, {ImageTransparency = 1})
		game:GetService("Debris"):AddItem(ht, 6)
	end,
	["startray"] = function(limbname, duration, multihit)
		starthitbox(currentattachments[limbname], duration, multihit)
	end,
	["suddenraystop"] = function()
		if rayholder then
			rayholder:Disconnect()
		end
	end,
	["trackbool"] = function(firstbool, secondbool)
		trackmouseY, trackmouselook = firstbool, secondbool
	end,
	["isholding"] = function()
		if holdinglmb then
			remote:FireServer("lmb")
		end
	end,
	["stopbar"] = function(name)
		if bartable[name] then
			bartable[name].usetick = tick()
			bartable[name].shadow.Visible = false
			if tfind(moveoncooldown, name) then
				table.remove(moveoncooldown, tfind(moveoncooldown, name))
			end
		else
			print(name,"bar was not found")
		end
	end,
	["bar"] = function(name, duration, fill)
		if bartable[name] then
			bartable[name].usetick = tick()
			local backuptick = bartable[name].usetick
			bartable[name].shadow.Visible = true
			local endsiz = UDim2.new(1,0,1,0)
			local startsiz = UDim2.new(1,0,0,0)
			if not fill then
				startsiz = UDim2.new(1,0,1,0)
				endsiz = UDim2.new(1,0,0,0)
			end
			if not tfind(moveoncooldown, name) then
				table.insert(moveoncooldown, name)
			end
			bartable[name].load.Size = startsiz
			bartable[name].load:TweenSize(endsiz, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, duration, true)
			task.spawn(function()
				task.wait(duration)
				if backuptick == bartable[name].usetick then
					bartable[name].shadow.Visible = false
					table.remove(moveoncooldown, tfind(moveoncooldown, name))
				end
			end)
		else
			print(name, "bar not found")
		end
	end,
	["init"] = function(aname)
		local occupied = false
		for i,v in pairs(currentattachments) do occupied = true break end --janky way to detect if a table has stuff inside (#table doesnt work on strings)
		if not occupied then --check if the table is empty at first and then stop adding
			for i,v in pairs(character:GetDescendants()) do
				if v:IsA("Attachment") and v.Name == aname then
					if not currentattachments[v.Parent.Name] then
						currentattachments[v.Parent.Name] = {}
					end
					table.insert(currentattachments[v.Parent.Name], v)
					v.Changed:Connect(function() --some client "security" that if someone edits attachments they get removed and it can be bypassed with getconnections() SO WHATS THE POINT???
						v.Parent = nil
						v:Destroy() --method calls can be also bypassed with __namecall hooking
					end)
				end
			end
		end
	end,
}

local inputpressholder
local inputreleaseholder
local keybehavior = {
	["f"] = function()
		remote:FireServer("keypress", "f")
	end,
	["q"] = function()
		remote:FireServer("keypress", "q")
	end,
	["r"] = function()
		remote:FireServer("keypress", "r")
	end,
	["e"] = function()
		remote:FireServer("keypress", "e")
	end
}

local uispressbehavior = {
	[Enum.UserInputType.Keyboard] = function(input)
		if keybehavior[string.lower(input.KeyCode.Name)] then
			keybehavior[string.lower(input.KeyCode.Name)]()
		end
	end,
	[Enum.UserInputType.MouseButton1] = function()
		holdinglmb = true
		remote:FireServer("lmb")
	end,
}
local uisreleasebehavior = {
	[Enum.UserInputType.MouseButton1] = function()
		holdinglmb = false
	end,
}

local inputpressfunc = function(input, cored)
	if cored then return end
	if uispressbehavior[input.UserInputType] then
		uispressbehavior[input.UserInputType](input)
	end
end
local inputreleasefunc = function(input)
	if uisreleasebehavior[input.UserInputType] then
		uisreleasebehavior[input.UserInputType](input)
	end
end

local mousepos = function(distance, ignore)
	local mpos = uis:GetMouseLocation()
	local scrpoint = camera:ScreenPointToRay(mpos.X, mpos.Y)
	local filter = RaycastParams.new()
	filter.FilterDescendantsInstances = ignore
	filter.FilterType = Enum.RaycastFilterType.Blacklist
	local ray = workspace:Raycast(scrpoint.Origin, scrpoint.Direction*distance, filter)
	local finishpos = scrpoint.Origin + (scrpoint.Direction*distance)
	local rayhit
	if ray then
		finishpos = ray.Position
		rayhit = ray.Instance
	end
	return CFrame.new(finishpos), rayhit
end

remote.OnClientEvent:Connect(function(strin, ...)
	if serverresponse[strin] then
		serverresponse[strin](...)
	end
end)

tool.Equipped:Connect(function()
	equiptick = tick()
	local backuptick = equiptick
	local guirot = 0
	local ogdelta = 0
	owner = players.LocalPlayer
	character = owner.Character
	charroot = character.HumanoidRootPart
	chartorso = character.Torso
	charhead = character.Head
	charhum = character:FindFirstChildOfClass("Humanoid")
	wasautorotated = charhum.AutoRotate
	charhum.AutoRotate = false
	uis.MouseIconEnabled = false
	--
	gui.Parent = owner:FindFirstChildOfClass("PlayerGui")
	table.insert(ignoretable, character)
	inputpressholder = uis.InputBegan:Connect(inputpressfunc)
	inputreleaseholder = uis.InputEnded:Connect(inputreleasefunc)
	runservice:BindToRenderStep("renderfunc", 201, function(delta)
		--crosshair
		local absvel = charroot.CFrame:VectorToObjectSpace(charroot.Velocity)
		local absx,absy,absz = math.clamp(absvel.x,-20,20), math.clamp(absvel.y,-50,50), math.clamp(absvel.z,-20,20)
		local absmag = math.clamp(absvel.Magnitude,0,20)
		local aim,_ = mousepos(500, ignoretable)
		local mpos = uis:GetMouseLocation() - guiser:GetGuiInset()
		cross.Position = UDim2.new(0,mpos.X,0,mpos.Y)
		guirot = linearlerp(guirot, absvel.X/15, delta*2)
		cross.Rotation = cross.Rotation + guirot
		if cross.Rotation > 90 or cross.Rotation < -90 then
			cross.Rotation = 0
		end
		--bars
		for i,v in pairs(bartable) do
			local baroffset = tfind(moveoncooldown, i) or 0
			v.shadow.Position = UDim2.new(-0.014-((baroffset-1)/200),mpos.X,0,mpos.Y) --lua starting tables at first index once again
		end	
		--character lookat
		if lookpart then
			local lookatspeed = 15
			local headpos = charroot.Position + (charroot.CFrame.UpVector*1.5)
			if trackmouselook then
				lookpart.CFrame = CFrame.new(headpos - (headpos - aim.p).Unit)
			else
				lookpart.CFrame = CFrame.new((headpos + charroot.CFrame.LookVector*2), headpos)
			end
			if trackmouseY and not charhum.PlatformStand and not tfind(horriblestates, charhum:GetState()) and not charroot:FindFirstChild("parrid") then --dear god
				charroot.CFrame = charroot.CFrame:lerp(CFrame.new(charroot.Position, Vector3.new(aim.x,charroot.Position.y,aim.z)), (delta*lookatspeed))
			end
		end
		--fps body
		local unvisiblityvalue = 0
		charhum.CameraOffset = Vector3.new()
		if animroot and (camera.CFrame.Position - (charroot.Position + Vector3.new(0,1.5,0))).Magnitude < 1 then
			unvisiblityvalue = 1
			charhum.CameraOffset = Vector3.new(0,0.35,0.3)
			charroot.CFrame = CFrame.new(charroot.Position, Vector3.new(aim.x,charroot.Position.y,aim.z)) --snap instantly instead
			animcf = animcf:Lerp(CFrame.Angles(0.1-(cos(tick())/20),cos(tick()*ws()*8)*(absmag/140),(-cos(tick()*ws()*8)*(absmag/140))) * CFrame.new(0,-0.15+(-(absmag/65)+sin(tick()*ws()*16)*(absmag/160))+sin(tick())/15,0), delta*5)
			--
			local objspace = chartorso.CFrame:ToObjectSpace(camera.CFrame * CFrame.new(0,-0.6,-0.5) * animcf) --the offset
			local objX,objY,_ = objspace:ToOrientation()
			local rcamX,_,_ = camera.CFrame:ToOrientation()
			local _,hrpY,_ = charroot.CFrame:ToObjectSpace(chartorso.CFrame):ToOrientation()
			animrootweld.C0 = objspace * CFrame.Angles(velX*1.8,(velY/1.5)+hrpY,-velY/2) * CFrame.new(0,0,-0.3)
			if rcamX < maxlookdown then
				camera.CFrame = camera.CFrame * CFrame.Angles(maxlookdown+math.abs(rcamX),0,0)
			end
		end
		for i,v in pairs(transparencylimbs) do
			character[i].LocalTransparencyModifier = v*unvisiblityvalue
		end
		for i,v in pairs(myhats) do
			v.LocalTransparencyModifier = unvisiblityvalue
		end
	end)
	steppedfunc = runservice.Stepped:Connect(function(_, delta)
		ogdelta = ogdelta + delta
		if ogdelta < 0.01666 then return end --throttled at roughly 60 fps incase of fps unlocker users
		ogdelta = 0
		local rotX,rotY,_ = camera.CFrame:ToObjectSpace(lastcamcf):ToOrientation()
		--
		camX = (camX + rotX)
		camY = (camY + rotY)
		--
		velX = getvel((camX - destinationX), velX, delta)
		velY = getvel((camY - destinationY), velY, delta)
		--
		destinationX = (destinationX + velX)
		destinationY = (destinationY + velY)
		lastcamcf = camera.CFrame
	end)
	lookpart = character:WaitForChild("aimpartfist")
	animroot = charhead:WaitForChild("lrp")
	animrootweld = chartorso:WaitForChild("lookrootweld")
	local lpvel = Instance.new("BodyVelocity", lookpart)
	lpvel.MaxForce = Vector3.new(1/0,1/0,1/0)
	lpvel.Velocity = Vector3.new()
	for i,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "Handle" then
			table.insert(myhats, v)
		end
	end
	while equiptick == backuptick and tool.Parent == character do
		for i,v in pairs(ignoretable) do
			if not v:IsDescendantOf(game) then
				table.remove(ignoretable, tfind(ignoretable, v))
			end
		end
		task.wait(2)
	end
end)

tool.Unequipped:Connect(function()
	gui.Parent = tool
	uis.MouseIconEnabled = true
	charhum.CameraOffset = Vector3.new()
	inputpressholder:Disconnect()
	inputreleaseholder:Disconnect()
	runservice:UnbindFromRenderStep("renderfunc")
	steppedfunc:Disconnect()
	holdinglmb = false
	if rayholder then
		rayholder:Disconnect()
	end
	table.clear(myhats)
	table.remove(ignoretable, tfind(ignoretable, character))
	charhum.AutoRotate = wasautorotated
	if lookpart then
		lookpart:Destroy()
		lookpart = nil
	end
	animroot = nil
	animrootweld = nil
end)

workspace.DescendantAdded:Connect(function(WHAT)
	if WHAT.Name == "Handle" and WHAT:IsA("BasePart") then
		--print(WHAT.Name)
		table.insert(ignoretable, WHAT)
	end
end)

for i,v in pairs(workspace:GetDescendants()) do
	if v.Name == "Handle" and v:IsA("BasePart") then
		table.insert(ignoretable, v)
	end
end

--[[while wait(2) do
	print("---")
	table.foreach(currentattachments, print)
end--]]