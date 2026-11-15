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
game.ReplicatedStorage.UiProbeResult.OnServerEvent:Connect(function(_, result)
 if done then return end
 done = true
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
 local gui = player:WaitForChild("PlayerGui"):WaitForChild("NorthsideHUD", 12)
 local content = waitUntil(function() return gui:FindFirstChildWhichIsA("ScrollingFrame", true) end, "missing scrolling frame")
 local modal = content.Parent
 local title = modal:FindFirstChildOfClass("TextLabel")
 local function findButton(parent, name)
  for _, item in parent:GetChildren() do
   if item:IsA("TextButton") and item.Text == name then return item end
  end
  error("missing button "..name)
 end
 local function click(button)
  local point = button.AbsolutePosition + button.AbsoluteSize/2 + guiService:GetGuiInset()
  controls:SendMousePosition(point)
  controls:SendMouseButton(point, Enum.UserInputType.MouseButton1, true, 0)
  task.wait(0.08)
  controls:SendMouseButton(point, Enum.UserInputType.MouseButton1, false, 0)
  task.wait(0.15)
 end
 local function opened(name)
  waitUntil(function() return modal.Visible and title.Text == name end, "did not open "..name)
 end
 local function close()
  click(modal:FindFirstChildOfClass("TextButton"))
  waitUntil(function() return not modal.Visible end, "close did not dismiss modal")
 end
 opened("YOUR NORTHSIDE CHARACTER")
 if not game:IsLoaded() then game.Loaded:Wait() end
 waitUntil(function() return guiService:GetGuiInset().Y > 0 end, "GUI insets not ready")
 if script:GetAttribute("ExpectedDevice")=="iphone_7" then
  waitUntil(function() return input.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 700 end, "phone emulation not ready")
 end
 task.wait(1)
 local nameBox = assert(content:FindFirstChildOfClass("TextBox"))
 -- Move the field above the bottom hotbar when the creator's preview fills a short viewport.
 local center = content.AbsolutePosition + content.AbsoluteSize/2 + guiService:GetGuiInset()
 if nameBox.AbsolutePosition.Y + nameBox.AbsoluteSize.Y/2 > content.AbsolutePosition.Y + content.AbsoluteSize.Y*0.68 then
  controls:SendPointerAction(center, {Wheel=-1})
  waitUntil(function() return content.CanvasPosition.Y > 1 end, "creator did not scroll")
  waitUntil(function()
   local fieldY = nameBox.AbsolutePosition.Y + nameBox.AbsoluteSize.Y/2
   return fieldY >= content.AbsolutePosition.Y and fieldY <= content.AbsolutePosition.Y + content.AbsoluteSize.Y*0.68
  end, "creator name did not scroll into view")
 end
 click(nameBox)
 waitUntil(function() return input:GetFocusedTextBox()==nameBox end, "creator name did not focus")
 check("creator focuses name", input:GetFocusedTextBox()==nameBox, input:GetFocusedTextBox())
 controls:SendTextInput("River")
 waitUntil(function() return nameBox.Text=="River" end, "name input did not receive typing")
 check("name input receives typing", nameBox.Text=="River", nameBox.Text)
 close()
 check("closing releases name focus", input:GetFocusedTextBox()==nil, input:GetFocusedTextBox())
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
 center = content.AbsolutePosition + content.AbsoluteSize/2 + guiService:GetGuiInset()
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
