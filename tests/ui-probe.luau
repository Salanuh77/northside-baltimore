-- Studio RunScript entry point. Run against a disposable copy of the candidate.
local studioTest = game:GetService("StudioTestService")
local device = game:GetService("StudioDeviceSimulatorService")
local json = game:GetService("HttpService")
local report = Instance.new("RemoteEvent")
report.Name = "UiProbeResult"
report.Parent = game.ReplicatedStorage

local server = Instance.new("Script")
server.Source = [==[
local test = game:GetService("StudioTestService")
local done = false
local earlySpawns = {}
local function watch(player)
 local function spawned()
  if not player:GetAttribute("ResidentSlot") then earlySpawns[player] = (earlySpawns[player] or 0) + 1 end
 end
 player.CharacterAdded:Connect(spawned)
 if player.Character then spawned() end
end
game.Players.PlayerAdded:Connect(watch)
for _, player in game.Players:GetPlayers() do watch(player) end
game.ReplicatedStorage.UiProbeResult.OnServerEvent:Connect(function(player, result)
 if done then return end
 done = true
 local count = earlySpawns[player] or 0
 table.insert(result.checks, {name="no server spawn before selecting a file", ok=count==0, actual=tostring(count)})
 if count>0 then result.ok=false; result.error=result.error.." character spawned before file selection" end
 test:EndTest(result)
end)
task.delay(60, function()
 if not done then test:EndTest({ok=false, error="UI client deadline"}) end
end)
]==]
server.Parent = game.ServerScriptService
local client = Instance.new("LocalScript")
client.Source = [==[
local player = game.Players.LocalPlayer
local guiService = game:GetService("GuiService")
local input = game:GetService("UserInputService")
local report = game.ReplicatedStorage:WaitForChild("UiProbeResult")
local checks, failures = {}, {}
local function check(name, valid, actual)
 table.insert(checks, {name=name, ok=valid, actual=tostring(actual)})
 if not valid then table.insert(failures, name) end
end
local function waitUntil(predicate, description)
 local deadline = os.clock() + 8
 repeat
  local value = predicate()
  if value then return value end
  task.wait(0.05)
 until os.clock() > deadline
 error(description)
end
local ok, message = pcall(function()
 local controls = assert(input:CreateVirtualInput(), "Studio VirtualInput unavailable")
 local playerGui = player:WaitForChild("PlayerGui")
 local function visible(item)
  local parent = item
  while parent and parent ~= playerGui do
   if parent:IsA("GuiObject") and not parent.Visible then return false end
   if parent:IsA("ScreenGui") and not parent.Enabled then return false end
   parent = parent.Parent
  end
  return parent == playerGui
 end
 local function findButton(parent, name)
  return waitUntil(function()
   for _, item in parent:GetDescendants() do
    if item:IsA("GuiButton") and visible(item) and (item.Name == name or item:IsA("TextButton") and item.Text == name) then return item end
   end
  end, "missing visible button "..name)
 end
 local function click(button)
  local scroll=button:FindFirstAncestorOfClass('ScrollingFrame')
  if scroll then
   local delta=button.AbsolutePosition.Y-scroll.AbsolutePosition.Y
   if delta<0 or delta+button.AbsoluteSize.Y>scroll.AbsoluteWindowSize.Y then
    scroll.CanvasPosition=Vector2.new(0,math.max(0,scroll.CanvasPosition.Y+delta-scroll.AbsoluteWindowSize.Y/2))
    task.wait(.12)
   end
  end
  local point = button.AbsolutePosition + button.AbsoluteSize/2 + guiService:GetGuiInset()
  controls:SendMousePosition(point)
  controls:SendMouseButton(point, Enum.UserInputType.MouseButton1, true, 0)
  task.wait(0.08)
  controls:SendMouseButton(point, Enum.UserInputType.MouseButton1, false, 0)
  task.wait(0.15)
 end
 if not game:IsLoaded() then game.Loaded:Wait() end
 waitUntil(function() return guiService:GetGuiInset().Y > 0 end, "GUI insets not ready")
 if script:GetAttribute("ExpectedDevice")=="iphone_7" then
  waitUntil(function() return input.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 700 end, "phone emulation not ready")
 end
 task.wait(1)
 local studio = waitUntil(function()
  local screen = playerGui:FindFirstChild("ResidentStudio")
  return screen and screen:IsA("ScreenGui") and screen.Enabled and screen
 end, "full-screen resident file picker did not open")
 local slot = findButton(studio, "New resident")
 check("no playable avatar before file selection", player.Character==nil, player.Character)
 local full = false
 for _, object in studio:GetDescendants() do
  if object:IsA("GuiObject") and visible(object) and object.AbsoluteSize.X >= studio.AbsoluteSize.X-1 and object.AbsoluteSize.Y >= studio.AbsoluteSize.Y-1 then full = true end
 end
 check("file picker covers the usable screen", full, studio.AbsoluteSize)
 click(findButton(studio,"City servers"))
 local browser=waitUntil(function() return playerGui:FindFirstChild("CityServerBrowser") end,"Server list did not open")
 waitUntil(function()
  for _,node in browser:GetDescendants() do
   if node:IsA("TextLabel") and node.Text:match("^Studio session") then return true end
  end
 end,"Server list did not show the actual local instance")
 check("server browser works before file selection",player.Character==nil,player.Character)
 click(findButton(browser,"Close"))
 click(slot)
 click(findButton(studio,"Andre"));click(findButton(studio,"Brooks"))
 local function labelPresent(value)
  for _,obj in studio:GetDescendants() do if obj:IsA("TextLabel") and visible(obj) and obj.Text==value then return true end end
 end
 check("first and last names update the identity",labelPresent("Andre Brooks"))
 click(findButton(studio,"Continue"))
 check("appearance controls show both directions", findButton(studio,"Hair previous").Text=="‹" and findButton(studio,"Hair next").Text=="›")
 local function rig()
  for _, obj in studio:GetDescendants() do
   if obj:IsA("WorldModel") and visible(obj) then
    local model = obj:FindFirstChild("ResidentRig")
    if model and model:IsA("Model") and model:GetAttribute("GameOwnedRig")==true then return model end
   end
  end
 end
 local model = waitUntil(rig, "missing game-owned preview rig")
 check("preview uses game-owned resident rig", model:FindFirstChildOfClass("Humanoid")~=nil, model.Name)
 for index,key in {'canvas-trousers-black','washed-denim-black','street-denim'} do
  click(findButton(studio,'Preset '..(4-index)))
  waitUntil(function()
   local r=rig();local pants=r and r:FindFirstChildOfClass('Pants')
   return pants and pants.PantsTemplate:find(game.ReplicatedStorage.StreetStyle:GetAttribute(key),1,true)
  end,'Starter outfit did not apply '..key)
  check('Trouser joint covered '..key,rig().LeftUpperLeg.Color~=rig().Head.Color)
 end
 model=rig()
 local baseHeight = model:GetExtentsSize().Y
 click(findButton(studio, "Height next"))
 waitUntil(function() local r=rig(); return r and r:GetExtentsSize().Y>baseHeight+0.01 end, "Tall did not change rendered preview height")
 local torso = function(r) return r and (r:FindFirstChild("Torso") or r:FindFirstChild("UpperTorso")) end
 local baseWidth = assert(torso(rig()), "preview torso missing").Size.X
 click(findButton(studio, "Build next"))
 waitUntil(function() local t=torso(rig()); return t and t.Size.X>baseWidth+0.01 end, "Broad did not change rendered preview width")
 check("build edits change preview proportions", true, tostring(rig():GetExtentsSize()))
 local baseDepth=torso(rig()).Size.Z
 click(findButton(studio,"Depth next"))
 check("torso depth changes independently",torso(rig()).Size.Z>baseDepth)
 click(findButton(studio,"Pants next"));click(findButton(studio,"Shoes next"))
 local pants=rig():FindFirstChildOfClass("Pants")
 check("washed denim and black shoes combine",pants.PantsTemplate:find(game.ReplicatedStorage.StreetStyle:GetAttribute("washed-denim-black"),1,true)~=nil)

 local baseColor = rig().Head.Color
 click(findButton(studio, "Tone previous"))
 local function previewColor() local r=rig(); return r and r.Head.Color end
 waitUntil(function() return previewColor() and previewColor()~=baseColor end, "tone swatch did not change preview skin")
 check("skin swatch changes preview", true, previewColor())
 local function haircutId()
  local r=rig();local mesh=r and r.Head:FindFirstChild('Hair mesh',true)
  return mesh and mesh:GetAttribute('CatalogId')
 end
 local initialHair=haircutId()
 click(findButton(studio,'Hair next'))
 waitUntil(function() return haircutId()==7193452166 and haircutId()~=initialHair end,'Curls mesh did not render')
 check('style tab changes rendered hair',true,haircutId())
 local head=rig().Head;local cap=head:FindFirstChild('Hair mesh',true)
 local center=head.CFrame:PointToObjectSpace(cap.Position)
 check('hair covers crown above forehead',cap.Size.X>head.Size.X and center.Y>0 and center.Y<head.Size.Y*.7,center)
 local function viewPose()
  local r = rig()
  local viewport = r and r:FindFirstAncestorOfClass("ViewportFrame")
  if viewport and viewport.CurrentCamera then return viewport.CurrentCamera.CFrame:ToObjectSpace(r:GetPivot()) end
 end
 local angle = assert(viewPose(), "preview camera missing")
 click(findButton(studio, "Turn right"))
 waitUntil(function() local pose=viewPose(); return pose and angle.LookVector:Dot(pose.LookVector)<0.999 end, "Turn right did not rotate preview")
 check("turn control changes preview angle", true, viewPose().LookVector)
 click(findButton(studio,"Face view"))
 click(findButton(studio,"Expression next"));click(findButton(studio,"Eye next"))
 local baseEyes=rig().Head["Resident face"].Texture
 click(findButton(studio,"Mouth next"))
 check("eye and mouth selectors render separately",rig().Head["Resident face"].Texture==baseEyes and rig().Head["Resident mouth"].Texture:find(game.ReplicatedStorage.StreetStyle:GetAttribute("mouth-smile"),1,true)~=nil)
 click(findButton(studio, "Enter city"))
 local character = waitUntil(function()
  local c = player.Character
  return c and c:FindFirstChild("HumanoidRootPart") and c
 end, "enter city did not spawn resident")
 waitUntil(function() return not studio.Parent or not studio.Enabled end, "resident studio remained open after entry")
 check("selected fictional name applies to the live resident", character.Humanoid.DisplayName=="Andre Brooks",character.Humanoid.DisplayName)
 check("enter city spawns game-owned resident", character:GetAttribute("GameOwnedRig")==true, character.Name)
 local gui = playerGui:WaitForChild("NorthsideHUD", 12)
 local content = waitUntil(function() return gui:FindFirstChildWhichIsA("ScrollingFrame", true) end, "missing scrolling frame")
 local modal = content.Parent
 local title = modal:FindFirstChildOfClass("TextLabel")
 local function opened(name)
  waitUntil(function() return modal.Visible and title.Text == name end, "did not open "..name)
 end
 local function close()
  click(modal:FindFirstChildOfClass("TextButton"))
  waitUntil(function() return not modal.Visible end, "close did not dismiss modal")
 end
 local directions=waitUntil(function()
  local card=gui:FindFirstChild("JobDirections")
  return card and card.Visible and card
 end,"first job direction missing after creation")
 local payoutShown=false
 for _,label in directions:GetChildren() do
  if label:IsA("TextLabel") and label.Text:find("$90",1,true) then payoutShown=true end
 end
 check("first job card advertises real delivery payout",payoutShown,directions.Visible)
 click(findButton(gui, "GUIDE"))
 click(findButton(gui,"Hide courier directions"))
 check("resident can dismiss first job directions",not directions.Visible,directions.Visible)
 click(findButton(gui, "GUIDE"))
 click(findButton(gui,"Find the $90 courier desk"))
 waitUntil(function() return directions.Visible end,"directions did not reopen")
 click(findButton(gui, "GUIDE"))
 opened("WELCOME TO NORTHSIDE")
 local clipped = {}
 local guide = {}
 for _, paragraph in content:GetChildren() do
  if paragraph:IsA("TextLabel") then
   table.insert(guide, paragraph.Text)
   if not paragraph.TextFits then table.insert(clipped, paragraph.Text:sub(1,32)) end
  end
 end
 check("guide paragraphs fit", #clipped==0, table.concat(clipped," | "))
 local guideText = table.concat(guide, " ")
 for _, stop in {"Seven Foot Knoll Lighthouse", "USS Constellation", "Pier 8 Maritime Gallery"} do
  check("guide lists "..stop, string.find(guideText, stop, 1, true) ~= nil, stop)
 end
 local center = content.AbsolutePosition + content.AbsoluteSize/2 + guiService:GetGuiInset()
 controls:SendPointerAction(center, {Wheel=-14})
 waitUntil(function() return content.CanvasPosition.Y > 1 end, "guide did not scroll")
 close()
 click(findButton(gui, "PHONE"))
 opened("CITY PHONE")
 check("new page starts at top", content.CanvasPosition.Y < 1, content.CanvasPosition.Y)
 local view = workspace.CurrentCamera.ViewportSize
 local lo, hi = modal.AbsolutePosition, modal.AbsolutePosition + modal.AbsoluteSize
 check("phone fits usable viewport", lo.X>=0 and lo.Y>=0 and hi.X<=gui.AbsoluteSize.X+1 and hi.Y<=gui.AbsoluteSize.Y+1,
  string.format("viewport %s, usable %s, modal %s..%s", tostring(view), tostring(gui.AbsoluteSize), tostring(lo), tostring(hi)))
 close()
 click(findButton(gui,'PHONE'));opened('CITY PHONE')
 click(findButton(content,'Work'));opened('WORK')
 click(findButton(modal,'Home'));opened('CITY PHONE')
 click(findButton(content,'My bag'))
 check('Bag opens from phone grid',title.Text~='CITY PHONE' and modal.Visible,title.Text)
 click(findButton(modal,'Home'));opened('CITY PHONE');close()
 local root = player.Character:WaitForChild("HumanoidRootPart")
 local start = root.Position
 controls:SendKey(true, Enum.KeyCode.W, false)
 task.wait(0.75)
 controls:SendKey(false, Enum.KeyCode.W, false)
 local distance = (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(start.X,0,start.Z)).Magnitude
 check("movement available after close", distance>1, distance)
end)
report:FireServer({ok=ok and #failures==0, error=ok and table.concat(failures,", ") or tostring(message), checks=checks,
 viewport=tostring(workspace.CurrentCamera.ViewportSize), touch=input.TouchEnabled})
]==]
client.Parent = game.StarterPlayer.StarterPlayerScripts
task.wait(4)
local results = {}
for _, profile in {"default", "iphone_7"} do
 if profile == "default" then device:StopSimulationAsync() else device:SetDeviceAsync(profile) end
 client:SetAttribute("ExpectedDevice", profile)
 local result = studioTest:ExecutePlayModeAsync({name="Northside UI "..profile})
 assert(type(result)=="table" and type(result.ok)=="boolean", "Missing UI result for "..profile)
 if profile=="iphone_7" and (not result.touch or not result.viewport or not result.viewport:match("^66[67], 37[45]$")) then
  result.ok = false
  result.error = "iPhone 7 emulation did not reach expected landscape viewport: "..tostring(result.viewport)
 end
 results[profile] = result
 print("NORTHSIDE_UI_PROFILE", profile, json:JSONEncode(result))
end
device:StopSimulationAsync()
print("SQUISHY_TEST_RESULT", json:JSONEncode({ok=results.default.ok and results.iphone_7.ok, profiles=results}))
