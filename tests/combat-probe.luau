local Players=game.Players
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function waitFor(fn,seconds) local endAt=os.clock()+seconds;repeat if fn() then return true end;task.wait(.05) until os.clock()>endAt;return fn() end
local function check(ok,label) assert(ok,label);print('COMBAT_PASS',label) end
local function call(p,k,d) return drive:InvokeClient(p,k,d or {}) end
local function park(p,at,look)
 local root=p.Character.HumanoidRootPart;root.Anchored=true
 p.Character:PivotTo(CFrame.lookAt(at,at+look)*root.CFrame:ToObjectSpace(p.Character:GetPivot()))
 root.AssemblyLinearVelocity=Vector3.zero
 call(p,'CombatCamera',{From=at-look*7+Vector3.yAxis*2,To=at+look*20})
end
local ok,err=pcall(function()
 check(waitFor(function() if #Players:GetPlayers()~=2 then return false end;for _,p in Players:GetPlayers() do if not p:GetAttribute('ProbeSpawnFinished') then return false end end;return true end,65),'Two residents loaded')
 local a,b=table.unpack(Players:GetPlayers())
 local floor=Instance.new('Part');floor.Name='Combat test floor';floor.Size=Vector3.new(100,1,100);floor.Position=Vector3.new(1900,40,1900);floor.Anchored=true;floor.Parent=workspace
 for _,p in {a,b} do
  p:RequestStreamAroundAsync(floor.Position,5);local ff=p.Character:FindFirstChildOfClass('ForceField');if ff then ff:Destroy() end
  local regen=p.Character:FindFirstChild('Health');if regen and regen:IsA('Script') then regen.Enabled=false end
 end
 local at=Vector3.new(1900,44,1900);park(a,at,Vector3.zAxis);park(b,at+Vector3.zAxis*4,-Vector3.zAxis)
 call(a,'Equip',{Name='Fists'});call(b,'Equip',{Name='Fists'})
 local h=b.Character.Humanoid;h.MaxHealth=500;h.Health=500
 local before=h.Health
 local punchVisible,punchDetail
 task.spawn(function() punchVisible,punchDetail=call(b,'ObservePunch',{Model=a.Character}) end)
 call(a,'CombatBurst')
 check(waitFor(function() return h.Health<before end,3) and h.Health==before-9,'Remote spam lands one bounded first punch')
 check(waitFor(function() return punchVisible==true end,2),'Other client sees the attacking arm move: '..tostring(punchDetail))
 task.wait(1.2)
 before=h.Health;call(b,'Guard',{Enabled=true})
 local guardState=b.Character:GetAttribute('CombatState');local facing=b.Character.HumanoidRootPart.CFrame.LookVector
 call(a,'Punch')
 check(h.Health<before and h.Health>before-3,string.format('Frontal guard reduces a real player hit (before=%s after=%s state=%s facing=%s combo=%s attack=%s)',before,h.Health,tostring(guardState),tostring(facing),tostring(a.Character:GetAttribute('CombatCombo')),tostring(a.Character:GetAttribute('CombatState'))))
 call(b,'Guard',{Enabled=false});task.wait(1.2)
 park(b,at+Vector3.zAxis*4,Vector3.zAxis);call(b,'Guard',{Enabled=true});before=h.Health;call(a,'Punch')
 check(h.Health==before-9,'Rear attack bypasses directional blocking')
 call(b,'Guard',{Enabled=false});task.wait(1.2)
 local wall=Instance.new('Part');wall.Size=Vector3.new(8,8,.5);wall.Position=at+Vector3.zAxis*2;wall.Anchored=true;wall.Parent=workspace
 before=h.Health;call(a,'Punch');check(h.Health==before,'Wall blocks melee damage');wall:Destroy();task.wait(1.2)
 park(b,at+Vector3.zAxis*15,-Vector3.zAxis);before=h.Health;call(a,'Punch');check(h.Health==before,'Out-of-range swing misses');task.wait(1.2)
 park(b,at+Vector3.zAxis*4,-Vector3.zAxis)
 local ff=Instance.new('ForceField');ff.Visible=false;ff.Parent=b.Character;before=h.Health;call(a,'Punch');check(h.Health==before,'Spawn protection rejects melee damage');ff:Destroy();task.wait(1.2)
 before=h.Health
 call(a,'Punch');task.wait(.23);call(a,'Punch');task.wait(.23);call(a,'Punch')
 check(waitFor(function() return b.Character:GetAttribute('Ragdolled') end,2),'Third clean punch causes a physical knockdown')
 check(h.Health==before-37,'Three-hit chain has the intended damage total')
 check(call(a,'ObserveKnockdown',{Model=b.Character}),'Other client sees sockets and disabled motors')
 check(waitFor(function() return not b.Character:GetAttribute('Ragdolled') end,5),'Knockdown recovers')
 check(not h.PlatformStand and h.Health>0,'Recovery restores humanoid control without killing the player')
 check(waitFor(function() return b.Character.HumanoidRootPart.CFrame.UpVector.Y>.8 end,3),'Recovered character stands upright')
 park(a,at,Vector3.zAxis);park(b,at+Vector3.zAxis*4,-Vector3.zAxis);task.wait(1.2)
 call(a,'Surrender');before=h.Health;call(a,'Punch');check(h.Health==before,'Surrender prevents attacks');call(a,'Surrender')
 check((a:GetAttribute('Heat') or 0)>0,'Player assaults enter the wanted system')
end)
game:GetService('StudioTestService'):EndTest({ok=ok,error=tostring(err)})
