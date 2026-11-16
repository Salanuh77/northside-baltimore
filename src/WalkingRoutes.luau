local Pathfinding = game:GetService('PathfindingService')
local Storage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Tags = game:GetService('CollectionService')

return function(city, markers, jobs)
    local desks = {markers.Job[1], markers.GunStore[1]}
    local style = require(Storage.StreetStyle)
    for i,desk in desks do
        local clerk = Storage.ResidentRig:Clone()
        clerk.Name = i == 1 and 'Parcel dispatcher' or 'Outfitters clerk'
        clerk.HumanoidRootPart.Anchored = true
        clerk.Parent = desk.Parent
        style.apply(clerk, {Name=clerk.Name, Height='Medium', Build='Average', Hair=i==1 and 'Curls' or 'Close crop', Tone='Umber', Starter=i==1 and 'Clay' or 'Overshirt'})
        -- Stand behind the counter, facing the public aisle.
        clerk:PivotTo(desk.CFrame * CFrame.new(0,1.1,desk.Size.Z/2+1.6))
        for _,piece in clerk:GetDescendants() do
            if piece:IsA('BasePart') then piece.CanCollide=false; piece.CanTouch=false; piece.CanQuery=false end
        end
        clerk:SetAttribute('RouteDesk',desk.Position)
        Tags:AddTag(clerk,'RouteClerk')
    end

    local nextRequest, computing = {}, {}
    Players.PlayerRemoving:Connect(function(p) nextRequest[p]=nil; computing[p]=nil end)
    Storage.WalkingRoute.OnServerInvoke = function(p, position)
        local root = p.Character and p.Character:FindFirstChild('HumanoidRootPart')
        if not root or typeof(position)~='Vector3' or computing[p] or os.clock()<(nextRequest[p] or 0) then return end
        local marker = jobs[p] and jobs[p].dest
        if not marker or marker.Position~=position then
            marker=nil
            for _,desk in desks do if desk.Position==position then marker=desk; break end end
        end
        if not marker or (p:GetAttribute('CustodyUntil') or 0)>0 then return end
        nextRequest[p]=os.clock()+2
        computing[p]=true
        local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=8,Costs={Asphalt=.8}})
        local goal=marker.CFrame:PointToWorldSpace(Vector3.new(0,0,-marker.Size.Z/2-3))
        local ok=pcall(function() path:ComputeAsync(root.Position,goal) end)
        computing[p]=nil
        local points={}
        if ok and path.Status==Enum.PathStatus.Success then
            for _,wp in path:GetWaypoints() do table.insert(points,wp.Position) end
        end
        path:Destroy()
        return points
    end
end
