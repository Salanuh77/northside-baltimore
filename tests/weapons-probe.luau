local Players=game.Players
local drive=game.ReplicatedStorage:WaitForChild('TestDrive')
local function waitFor(fn,seconds) local due=os.clock()+seconds;repeat if fn() then return true end;task.wait(.1) until os.clock()>due;return fn() end
local function check(ok,label) assert(ok,label);print('WEAPON_PASS',label) end
local function call(p,k,d) return drive:InvokeClient(p,k,d or {}) end
local function park(p,at) p.Character:PivotTo(CFrame.new(at));p.Character.HumanoidRootPart.Anchored=true;p:RequestStreamAroundAsync(at,4) end
local ok,err=pcall(function()
 check(waitFor(function() if #Players:GetPlayers()~=2 then return false end;for _,p in Players:GetPlayers() do if not p:GetAttribute('ProbeSpawnFinished') then return false end end;return true end,70),'Two ready residents')
 local a,b=table.unpack(Players:GetPlayers());local profile=game.ServerStorage.TestProfile
 local loaded,detail=call(a,'WeaponArt');check(loaded,'All six imported weapon assets and materials load: '..tostring(detail))
 local counter;for _,v in workspace.Baltimore:GetDescendants() do if v:GetAttribute('Action')=='GunStore' then counter=v;break end end
 park(a,counter.Position+counter.CFrame.LookVector*5+Vector3.yAxis*2)
 call(a,'Prompt',counter)
 check(call(a,'ItemCard',{Key='Pistol',Weapon='Compact',Price='$250',Buy=true}),'Cash weapon picture card is clickable')
 local d=profile:Invoke(a);check(d.Cash==250 and d.Guns.Compact==1 and d.Magazine==12,'Starter cash buys loaded compact')
 call(a,'WeaponAttachment',{Item='Suppressor'});d=profile:Invoke(a)
 check(d.Cash==30 and d.Attachments.Suppressor and d.AttachmentEnabled.Suppressor,'Cash suppressor delivered')
 check(a.Backpack.Pistol:FindFirstChild('sidearm exterior') and a.Backpack.Pistol:FindFirstChild('suppressor exterior'),'Imported attachments mounted to the real tool')
 call(a,'WeaponAttachment',{Item='Scope'});check(profile:Invoke(a).Cash==30,'Incompatible scope rejects without charging')
 profile:Invoke(a,2200)
 call(a,'BuyWeapon',{Item='SMG'});call(a,'WeaponAttachment',{Item='Scope'})
 d=profile:Invoke(a);check(d.Guns.SMG==1 and d.Magazine==24 and d.Cash==1270,'Automatic cash gun and scope equipped')
 call(a,'BuyWeapon',{Item='Shotgun'});check(profile:Invoke(a).Magazine==6,'Shotgun has its own magazine')
 call(a,'BuyWeapon',{Item='SMG'});check(profile:Invoke(a).Magazine==24,'Weapon switching preserves rounds')
 call(a,'BuyAmmo');check(profile:Invoke(a).Reserve>=12,'Ammo purchase supplies reload reserve')
 park(a,Vector3.new(2100,44,2100));park(b,Vector3.new(2160,44,2100))
 for _,p in {a,b} do local ff=p.Character:FindFirstChildOfClass('ForceField');if ff then ff:Destroy() end end
 call(a,'Equip',{Name='Pistol'});local tool=a.Character.Pistol
 check(tool:GetAttribute('Automatic') and tool:GetAttribute('Scope'),'Automatic and optic states replicate')
 call(a,'FireBurst',{Position=Vector3.new(2100,100,2000)})
 check(tool:GetAttribute('Ammo')==23,'Burst spam consumes only one server-approved shot')
 call(a,'HoldFire');check(tool:GetAttribute('Ammo')<22 and tool:GetAttribute('Ammo')>=16,'Holding fire produces a bounded automatic burst')
 call(a,'Reload');check(waitFor(function() return tool:GetAttribute('Ammo')==24 end,4),'SMG reload fills its catalog capacity')
 park(a,counter.Position+counter.CFrame.LookVector*5+Vector3.yAxis*2)
 call(a,'BuyWeapon',{Item='Compact'});park(a,Vector3.new(2100,44,2100));call(a,'Equip',{Name='Pistol'})
 call(b,'Shots');call(a,'Shoot',{Position=Vector3.new(2100,100,2000),Aiming=true});task.wait(.4)
 check(#call(b,'Shots')==0,'Distant player receives no suppressed muzzle coordinates or tracer')
 park(a,counter.Position+counter.CFrame.LookVector*5+Vector3.yAxis*2);call(a,'WeaponAttachment',{Item='Suppressor'})
 park(a,Vector3.new(2100,44,2100));call(a,'Equip',{Name='Pistol'});call(b,'Shots')
 call(a,'Shoot',{Position=Vector3.new(2100,100,2000),Aiming=true});task.wait(.4)
 local heard=call(b,'Shots');check(#heard==1 and not heard[1].Suppressed,'Normal shots remain audible and visible to nearby players')
 local cash=profile:Invoke(a).Cash;call(a,'BuyWeapon',{Item='Compact'});check(profile:Invoke(a).Cash==cash,'Off-site shop remote cannot charge or change inventory')
 call(a,'EquipWeapon',{Item='SMG'});check(profile:Invoke(a).Weapon=='SMG','Owned loadout switches away from shops')
 call(a,'EquipWeapon',{Item='Carbine'});check(profile:Invoke(a).Weapon=='SMG','Loadout remote cannot mint an unowned premium gun')
end)
game:GetService('StudioTestService'):EndTest({ok=ok,error=tostring(err)})
