-- Server-started Animator tracks replicate to every viewer. Visuals never award hits.
local Tags=game:GetService('CollectionService')
local Storage=game:GetService('ReplicatedStorage')
local Motion={}
function Motion.start()
 local watched={}
 local function watch(model)
  if watched[model] then return end
  local human=model:FindFirstChildOfClass('Humanoid');if not human then return end
  local animator=human:FindFirstChildOfClass('Animator') or Instance.new('Animator',human)
  local state={tracks={},connections={},key=nil};watched[model]=state
  for _,clip in Storage.CombatAnimations:GetChildren() do
   local ok,track=pcall(animator.LoadAnimation,animator,clip)
   if ok then
    state.tracks[clip.Name]=track;track.Priority=Enum.AnimationPriority[clip:GetAttribute('Priority')]
    track.Looped=clip:GetAttribute('Loop')==true
   else warn('Combat clip could not load: '..clip.Name) end
  end
  local function update()
   if not model.Parent then return end
   local mode=model:GetAttribute('CombatState') or 'Idle'
   local hit=model:GetAttribute('CombatHitAt') or -100
   local now=workspace:GetServerTimeNow();local name,key,started
   if human.Health>0 and not human.SeatPart and not model:GetAttribute('Resting') and not model:GetAttribute('Ragdolled') then
    if now-hit<.22 and model:GetAttribute('CombatHitBlocked') then name='GuardHit';key=name..hit;started=hit
    elseif mode=='Attacking' then
     name=({'Jab','Cross','Hook'})[model:GetAttribute('CombatCombo') or 1]
     started=model:GetAttribute('CombatStarted') or now;key=name..started
    elseif mode=='Stunned' then name='Flinch';key=name..hit;started=hit
    elseif mode=='Blocking' then name='Guard';key=name
    elseif model:GetAttribute('Surrendered') then name='Surrender';key=name
    elseif model:FindFirstChild('Fists') then name='Ready';key=name end
   end
   if key==state.key then return end
   state.key=key
   for _,track in state.tracks do if track.IsPlaying then track:Stop(.08) end end
   local track=name and state.tracks[name]
   if track then
    track:Play(name=='Ready' and .16 or .045,1,1)
    if started and track.Length>0 then track.TimePosition=math.clamp(now-started,0,math.max(0,track.Length-.01)) end
   end
   model:SetAttribute('CombatAnimation',name)
  end
  local queued=false
  local function queue()
   if queued then return end;queued=true
   task.defer(function() queued=false;update() end)
  end
  for _,attribute in {'CombatState','CombatStarted','CombatCombo','CombatHitAt','CombatHitBlocked','Ragdolled','Resting','Surrendered'} do
   table.insert(state.connections,model:GetAttributeChangedSignal(attribute):Connect(queue))
  end
  table.insert(state.connections,model.ChildAdded:Connect(queue));table.insert(state.connections,model.ChildRemoved:Connect(queue))
  table.insert(state.connections,human.Died:Connect(queue));table.insert(state.connections,human.Seated:Connect(queue))
  if state.tracks.GuardHit then table.insert(state.connections,state.tracks.GuardHit.Ended:Connect(queue)) end
  update()
 end
 local function forget(model)
  local state=watched[model];if not state then return end;watched[model]=nil
  for _,connection in state.connections do connection:Disconnect() end
  for _,track in state.tracks do track:Stop(0);track:Destroy() end
 end
 Tags:GetInstanceAddedSignal('CombatActor'):Connect(watch)
 Tags:GetInstanceRemovedSignal('CombatActor'):Connect(forget)
 for _,model in Tags:GetTagged('CombatActor') do watch(model) end
 return {watch=watch,forget=forget}
end
return Motion
