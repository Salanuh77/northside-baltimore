-- Shared by disposable server/client probes; never included in the published place.
return function()
 local errors={}
 game:GetService('ScriptContext').Error:Connect(function(message,stack,source)
  if not source then return end
  local owned=false
  for _,service in {'ServerScriptService','ReplicatedStorage','Players','Workspace'} do
   if source:IsDescendantOf(game:GetService(service)) then owned=true;break end
  end
  if owned then table.insert(errors,source:GetFullName()..': '..tostring(message)) end
 end)
 return errors
end
