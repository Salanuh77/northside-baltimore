local fs=require('@lune/fs');local luau=require('@lune/luau')
local listener
local game={GetService=function(_,name)
 if name=='ScriptContext' then return {Error={Connect=function(_,fn) listener=fn end}} end
 return name
end}
local watch=luau.load(fs.readFile('tests/runtime-errors.luau'),{environment={game=game},injectGlobals=true})()
local errors=watch()
local function source(service)
 return {IsDescendantOf=function(_,parent) return parent==service end,GetFullName=function() return service..'.Example' end}
end
listener('core failure','',source('CoreGui'));listener('unknown','',nil)
assert(#errors==0,'Roblox CoreGui and unattributed engine messages are not game-owned errors')
for _,service in {'ServerScriptService','ReplicatedStorage','Players','Workspace'} do listener('game failure','',source(service)) end
assert(#errors==4 and errors[3]:find('Players.Example',1,true),'Capture server modules, client modules, player scripts and world scripts')
print('PASS: multiplayer runtime errors are scoped to game-owned scripts on server and clients')
