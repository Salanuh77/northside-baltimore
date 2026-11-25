local fs=require('@lune/fs')
local monitor='local runtimeErrors=(function()\n'..fs.readFile('tests/runtime-errors.luau')..'\nend)()()\n'
local client=monitor..fs.readFile('tests/client-probe.luau')
local server=fs.readFile(require('@lune/process').args[1] or 'tests/server-probe.luau')
server=monitor..[==[
local function finishProbe(result)
 if result.ok then
  for _,player in game.Players:GetPlayers() do
   local ok,errors=pcall(function() return game.ReplicatedStorage.TestDrive:InvokeClient(player,'RuntimeErrors',{}) end)
   if not ok or type(errors)~='table' then table.insert(runtimeErrors,'Missing runtime report for '..player.Name)
   else for _,message in errors do table.insert(runtimeErrors,player.Name..' / '..message) end end
  end
  if #runtimeErrors>0 then result.ok=false;result.error=table.concat(runtimeErrors,' | ') end
 end
 return game.HttpService:JSONEncode(result)
end
]==]..server
-- Studio's process boundary reliably carries JSON strings, including failures.
local changed
server,changed=server:gsub('(:EndTest%()(%b{})(%))',function(before,result,after) return before..'finishProbe('..result..')'..after end)
assert(changed==1,'Probe must publish exactly one structured completion result')
local launch=string.format([====[
workspace:SetAttribute('TestMinute',864)
local clock=game.ServerScriptService.CityClock
clock.Source=clock.Source:gsub('local total=math.floor%%(workspace:GetServerTimeNow%%(%%)%%)',"local total=workspace:GetAttribute('TestMinute') or 864")
local cityServer=game.ServerScriptService.CityServer
-- CharacterAdded/root existence precedes completion of LoadCharacterAsync.
-- The isolated encounter must not teleport or strip protection mid-spawn.
local marked
cityServer.Source,marked=cityServer.Source:gsub('d%%.Spawning=false','d.Spawning=false; p:SetAttribute("ProbeSpawnFinished",ok and p.Character~=nil)',1)
assert(marked==1,'Missing initial spawn completion hook')
cityServer.Source..=[==[
local probe=Instance.new('BindableFunction');probe.Name='TestReceipt';probe.Parent=game.ServerStorage
local profileProbe=Instance.new('BindableFunction');profileProbe.Name='TestProfile';profileProbe.Parent=game.ServerStorage
profileProbe.OnInvoke=function(p,cash)
 if cash then profiles[p].Cash=cash;sync(p) end
 return payload(profiles[p])
end
probe.OnInvoke=function(p,info)
 for _,d in profiles do d.PaidTrading=true end
 return retail.receipt(info).Name
end
]==]
local drive=Instance.new('RemoteFunction'); drive.Name='TestDrive'; drive.Parent=game:GetService('ReplicatedStorage')
local client=Instance.new('LocalScript'); client.Name='ClientProbe';client:SetAttribute('CreateFixture',%s); client.Source=%q; client.Parent=game:GetService('StarterPlayer').StarterPlayerScripts
local server=Instance.new('Script'); server.Name='ServerProbe'; server.Source=%q; server.Parent=game:GetService('ServerScriptService')
task.wait(4)
local result=game:GetService('StudioTestService'):ExecuteMultiplayerTestAsync(2,{name='Squishy gameplay validation'})
if type(result)=='string' then result=game.HttpService:JSONDecode(result) end
print('SQUISHY_TEST_RESULT',game:GetService('HttpService'):JSONEncode(result))
]====],tostring(not string.find(require('@lune/process').args[1] or '', 'retail',1,true)),client,server)
fs.writeFile(require('@lune/process').args[2] or 'tests/launch.luau',fs.readFile('studio-smoke.luau')..'\n'..fs.readFile('tests/foundry-joints.luau')..'\n'..fs.readFile('tests/harbor-access.luau')..'\n'..launch)
