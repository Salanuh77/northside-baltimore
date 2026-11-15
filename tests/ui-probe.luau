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
 click(findButton(studio, "Identity"))
 local nameBox = waitUntil(function()
  local box = studio:FindFirstChild("ResidentName", true)
  return box and box:IsA("TextBox") and visible(box) and box
 end, "identity tab missing resident name")
 click(nameBox)
 waitUntil(function() return input:GetFocusedTextBox()==nameBox end, "resident name did not focus")
 local function selectAll()
  controls:SendKey(true, Enum.KeyCode.LeftControl, false)
  controls:SendKey(true, Enum.KeyCode.A, false)
  controls:SendKey(false, Enum.KeyCode.A, false)
  controls:SendKey(false, Enum.KeyCode.LeftControl, false)
 end
 selectAll()
 controls:SendTextInput("River")
 waitUntil(function() return nameBox.Text=="River" end, "name input did not receive typing")
 check("identity accepts typed name", nameBox.Text=="River", nameBox.Text)
 -- Leave the name blank for the multiplayer-independent Studio fixture.
 selectAll()
 controls:SendKey(true, Enum.KeyCode.Backspace, false)
 controls:SendKey(false, Enum.KeyCode.Backspace, false)
 waitUntil(function() return nameBox.Text=="" end, "resident name did not clear")
 click(findButton(studio, "Build"))
 check("changing tabs releases text focus", input:GetFocusedTextBox()==nil, input:GetFocusedTextBox())
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
 local baseHeight = model:GetExtentsSize().Y
 click(findButton(studio, "Tall"))
 waitUntil(function() local r=rig(); return r and r:GetExtentsSize().Y>baseHeight+0.01 end, "Tall did not change rendered preview height")
 local torso = function(r) return r and (r:FindFirstChild("Torso") or r:FindFirstChild("UpperTorso")) end
 local baseWidth = assert(torso(rig()), "preview torso missing").Size.X
 click(findButton(studio, "Broad"))
 waitUntil(function() local t=torso(rig()); return t and t.Size.X>baseWidth+0.01 end, "Broad did not change rendered preview width")
 check("build edits change preview proportions", true, tostring(rig():GetExtentsSize()))
 click(findButton(studio, "Style"))
 local baseColor = rig().Head.Color
 click(findButton(studio, "Copper"))
 local function previewColor() local r=rig(); return r and r.Head.Color end
 waitUntil(function() return previewColor() and previewColor()~=baseColor end, "tone swatch did not change preview skin")
 check("skin swatch changes preview", true, previewColor())
 local function hairParts()
  local r = rig()
  local hair = r and r.Head:FindFirstChild("Northside hair")
  return hair and #hair:GetChildren() or 0
 end
 local baseHair = hairParts()
 click(findButton(studio, "Curls"))
 waitUntil(function() return hairParts()>baseHair end, "Curls did not change preview hair")
 check("style tab changes rendered hair", true, hairParts())
 local function viewPose()
  local r = rig()
  local viewport = r and r:FindFirstAncestorOfClass("ViewportFrame")
  if viewport and viewport.CurrentCamera then return viewport.CurrentCamera.CFrame:ToObjectSpace(r:GetPivot()) end
 end
 local angle = assert(viewPose(), "preview camera missing")
 click(findButton(studio, "Turn right"))
 waitUntil(function() local pose=viewPose(); return pose and angle.LookVector:Dot(pose.LookVector)<0.999 end, "Turn right did not rotate preview")
 check("turn control changes preview angle", true, viewPose().LookVector)
 click(findButton(studio, "Enter city"))
 local character = waitUntil(function()
  local c = player.Character
  return c and c:FindFirstChild("HumanoidRootPart") and c
 end, "enter city did not spawn resident")
 waitUntil(function() return not studio.Parent or not studio.Enabled end, "resident studio remained open after entry")
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
