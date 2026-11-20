-- Simulated saved DataStore response in an isolated Studio session. Production hydrates it normally.
local cityServer=game.ServerScriptService.CityServer
local old='else account=Files.open%(nil%) end'
local sample=[[
else
 account=Files.open({Look={Name='Old Harbor',Tone='Olive',Hair='Shaved',Build='Average',Height='Medium'},Cash=983,Bank=102})
 account=Files.write(account,2,{Look={Name='River',Tone='Copper',Hair='Barrel twists',Build='Broad',Height='Tall',Starter='Olive',FaceShape='Heart',FaceWidth='Narrow',HairColor='Honey',EyeSpacing='Wide',LipFullness='Full'},Cash=701,Bank=81,Items={Bat=true},Reserve=7,Employment='dock',Wages=86})
end]]
local source,count=cityServer.Source:gsub(old,sample,1)
assert(count==1,'Saved-record fixture no longer matches Studio storage adapter');cityServer.Source=source
local server=Instance.new('Script');server.Source=[=[
local p=game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait()
local function waitFor(fn)
 local deadline=os.clock()+20
 repeat if fn() then return true end;task.wait(.1) until os.clock()>deadline
end
local ok,err=pcall(function()
 assert(waitFor(function() return p:GetAttribute('ResidentFiles') end),'Files unavailable')
 local rows=game.HttpService:JSONDecode(p:GetAttribute('ResidentFiles'))
 assert(rows[1].Name=='Old Harbor' and rows[2].Name=='River' and rows[3].Name==nil,'Wrong file summaries')
 assert(not p.Character and not p:GetAttribute('ResidentSlot'),'Account avatar spawned before choosing a file')
 p:SetAttribute('ProbeChoose',true)
 assert(waitFor(function() return p.Character and p.Character:GetAttribute('GameOwnedRig') and p.Character:FindFirstChild('Head') and p.Character.Head:FindFirstChild('Northside hair') end),'Saved resident did not load')
 assert(p.Character.Humanoid.DisplayName=='River' and p:GetAttribute('ResidentSlot')==2 and p:GetAttribute('NeedsCharacter')==false)
 local head=p.Character.Head
 assert(head:FindFirstChild('Head sculpt',true).MeshId==game.ReplicatedStorage.ResidentProfiles:FindFirstChild('Heart',true).MeshId,'Saved head geometry not restored')
 local hair=head:FindFirstChild('Hair mesh',true)
 assert(hair.MeshId==game.ReplicatedStorage.ResidentGrooms:FindFirstChild('Barrel twists',true).MeshId and hair.Color==require(game.ReplicatedStorage.StreetStyle).Dyes.Honey,'Saved cut or color lost on rejoin')
 assert(p:GetAttribute('Cash')==701 and p:GetAttribute('Bank')==81 and p:GetAttribute('Wages')==86 and p:GetAttribute('Employment')=='dock')
 assert(p.Character:FindFirstChildOfClass('Shirt') and p.Character:FindFirstChildOfClass('Pants'),'Existing resident missing street clothes')
 assert(p.Backpack:FindFirstChild('Bat') and p:GetAttribute('ReserveAmmo')==7,'Inventory not restored')
 game.ReplicatedStorage.CityAction:FireClient(p,'ReturnCheck')
 task.wait(1)
 assert(p:GetAttribute('ResidentSlot')==2,'Active file switched during gameplay')
end)
game:GetService('StudioTestService'):EndTest(game.HttpService:JSONEncode({ok=ok,error=tostring(err)}))
]=];server.Parent=game.ServerScriptService
local client=Instance.new('LocalScript');client.Source=[=[
local p=game.Players.LocalPlayer
local event=game.ReplicatedStorage.CityAction
while not p:GetAttribute('ProbeChoose') do task.wait(.05) end
event.OnClientEvent:Connect(function(kind) if kind=='ReturnCheck' then event:FireServer('SelectFile',{Index=1}) end end)
local input=game:GetService('UserInputService'):CreateVirtualInput()
local gui=p.PlayerGui:WaitForChild('ResidentStudio')
local function click(button)
 local point=button.AbsolutePosition+button.AbsoluteSize/2+game.GuiService:GetGuiInset()
 input:SendMousePosition(point);input:SendMouseButton(point,Enum.UserInputType.MouseButton1,true,0)
 task.wait(.1);input:SendMouseButton(point,Enum.UserInputType.MouseButton1,false,0);task.wait(.3)
end
local deadline=os.clock()+10
repeat task.wait(.1) until gui:FindFirstChild('River',true) or os.clock()>deadline
repeat task.wait(.1) until game.GuiService:GetGuiInset().Y>0 or os.clock()>deadline
task.wait(1)
click(assert(gui:FindFirstChild('River',true),'Saved resident card is missing'))
assert(not p.Character,'Clicking a save must preview it before entering')
local preview
deadline=os.clock()+5
repeat
 preview=gui:FindFirstChild('ResidentRig',true)
 if preview and preview.Humanoid.DisplayName=='River' then break end
 task.wait(.05)
until os.clock()>deadline
assert(preview and preview.Head:FindFirstChild('Head sculpt',true).MeshId==game.ReplicatedStorage.ResidentProfiles:FindFirstChild('Heart',true).MeshId,'Selected save preview is wrong')
local enter
for _,v in gui:GetDescendants() do if v:IsA('TextButton') and v.Text=='Enter city' then enter=v;break end end
click(assert(enter,'Enter city button is missing'))
]=];client.Parent=game.StarterPlayer.StarterPlayerScripts
task.wait(4)
local result=game:GetService('StudioTestService'):ExecutePlayModeAsync({name='Restore an existing resident'})
if type(result)=='string' then result=game.HttpService:JSONDecode(result) end
print('SQUISHY_TEST_RESULT',game.HttpService:JSONEncode(result))
