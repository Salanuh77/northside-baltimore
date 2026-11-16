local Pathfinding = game:GetService('PathfindingService')
local Storage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

return function(city, markers, jobs)
    local desks = {markers.Job[1], markers.GunStore[1]}
    require(script.Parent.ShopStaff)(city)

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
