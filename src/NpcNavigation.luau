local Pathfinding=game:GetService('PathfindingService')
local Navigation={};Navigation.__index=Navigation
function Navigation.new(model)
 return setmetatable({model=model,human=model.Humanoid,root=model.HumanoidRootPart,generation=0,nextPlan=0,index=2},Navigation)
end
function Navigation:clearPath()
 if self.blocked then self.blocked:Disconnect();self.blocked=nil end
 if self.path then self.path:Destroy();self.path=nil end
 self.points=nil
end
function Navigation:stop()
 self.generation+=1;self.goal=nil;self.progressAt=nil;self.progress=nil;self:clearPath()
 if self.model.Parent then self.human:MoveTo(self.root.Position) end
end
function Navigation:step(goal,now,speed)
 if not self.model.Parent then return end
 self.human.WalkSpeed=speed
 if (goal-self.root.Position).Magnitude<2.5 then self:stop();return end
 if not self.goal or (goal-self.goal).Magnitude>5 then
  self.goal=goal;self.generation+=1;self.nextPlan=0;self:clearPath()
 end
 if not self.computing and now>=self.nextPlan then
  local revision=self.generation;local start=self.root.Position
  self.computing=true;self.nextPlan=now+1.25
  task.spawn(function()
   local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=5.5,AgentCanJump=true,WaypointSpacing=4})
   local ok=pcall(function() path:ComputeAsync(start,goal) end)
   self.computing=false
   if not self.model.Parent or revision~=self.generation then path:Destroy();return end
   if not ok or path.Status~=Enum.PathStatus.Success then path:Destroy();self:clearPath();self.human:MoveTo(self.root.Position);return end
   self:clearPath();self.path=path;self.points=path:GetWaypoints();self.index=2
   self.progressAt=self.progressAt or os.clock();self.progress=self.progress or self.root.Position
   self.blocked=path.Blocked:Connect(function(index)
    if self.path==path and index>=self.index then self.nextPlan=0;self:clearPath() end
   end)
  end)
 end
 local point=self.points and self.points[self.index]
 if not point then return end
 local planar=(point.Position-self.root.Position)*Vector3.new(1,0,1)
 if planar.Magnitude<1.8 then
  self.index+=1;self.progressAt=now;self.progress=self.root.Position
  point=self.points[self.index]
 end
 if point then
  if point.Action==Enum.PathWaypointAction.Jump then self.human.Jump=true end
  self.human:MoveTo(point.Position)
 end
 if self.progress and (self.root.Position-self.progress).Magnitude>1.5 then self.progress=self.root.Position;self.progressAt=now end
 if self.progressAt and now-self.progressAt>1.8 then self.nextPlan=0;self:clearPath() end
end
return Navigation
