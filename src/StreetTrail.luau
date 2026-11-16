local Storage=game:GetService('ReplicatedStorage')
local Tags=game:GetService('CollectionService')

return function()
    local folder=Instance.new('Folder')
    folder.Name='Local street directions'
    folder.Parent=workspace
    local outline=Instance.new('Highlight')
    outline.Name='Nearby contact'
    outline.Enabled=false
    outline.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    outline.OutlineColor=Color3.new(1,1,1)
    outline.OutlineTransparency=0
    outline.FillTransparency=.88
    outline.FillColor=Color3.new(1,1,1)
    outline.Parent=folder
    local arrows={}
    local function newArrow()
        local model=Instance.new('Model')
        model.Name='Street arrow'
        local function stroke(cf,size)
            local part=Instance.new('Part')
            part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
            part.CastShadow=false; part.Material=Enum.Material.Neon; part.Color=Color3.new(1,1,1)
            part.Size=size; part.CFrame=cf; part.Parent=model
            return part
        end
        model.PrimaryPart=stroke(CFrame.identity,Vector3.new(.68,.10,3.4))
        for _,side in {-1,1} do
            stroke(CFrame.new(side*.71,0,-.85)*CFrame.Angles(0,side*math.rad(43),0),Vector3.new(.65,.10,2.2))
        end
        return model
    end
    local function hideAfter(n)
        for i=n+1,#arrows do arrows[i].Parent=nil end
    end
    local destination,points,nextTry,generation=nil,{},0,0
    local pending=false
    local function update(root,target,showContacts)
        if target~=destination then
            destination=target; points={}; nextTry=0; generation+=1; pending=false; hideAfter(0)
        end
        local contact,best=nil,23
        if root and showContacts then
            for _,npc in Tags:GetTagged('RouteClerk') do
                local pos=npc:GetAttribute('RouteDesk')
                if pos and (not target or target==pos) then
                    local d=(root.Position-pos).Magnitude
                    if d<best then best=d;contact=npc end
                end
            end
        end
        outline.Adornee=contact
        outline.Enabled=contact~=nil
        if not root or not target or (root.Position-target).Magnitude<9 then hideAfter(0); return end
        -- Snap to the nearest segment so the trail advances or reverses with the player.
        local nearest,beginIndex,beginPos=math.huge,nil,nil
        for i=1,#points-1 do
            local a,b=points[i],points[i+1]
            local delta=b-a
            if delta.Magnitude>.01 then
                local at=a+delta*math.clamp((root.Position-a):Dot(delta)/delta:Dot(delta),0,1)
                local distance=(root.Position-at).Magnitude
                if distance<nearest then nearest=distance;beginIndex=i;beginPos=at end
            end
        end
        if nearest>14 and not pending and os.clock()>=nextTry then
            local ticket=generation
            pending=true;nextTry=os.clock()+3
            task.spawn(function()
                local ok,result=pcall(function() return Storage.WalkingRoute:InvokeServer(target) end)
                if ticket~=generation then return end
                pending=false
                if ok and type(result)=='table' then points=result end
            end)
        end
        if not beginIndex or nearest>18 then hideAfter(0); return end
        local count,spacing=0,4
        local ray=RaycastParams.new()
        ray.FilterType=Enum.RaycastFilterType.Exclude
        ray.FilterDescendantsInstances={root.Parent,folder}
        ray.RespectCanCollide=true
        for i=beginIndex,#points-1 do
            local a=i==beginIndex and beginPos or points[i]
            local delta=points[i+1]-a
            local heading=Vector3.new(delta.X,0,delta.Z)
            if heading.Magnitude<.05 then continue end
            while spacing<=delta.Magnitude and count<14 do
                local at=a+delta.Unit*spacing
                local ground=workspace:Raycast(at+Vector3.yAxis*2,-Vector3.yAxis*6,ray)
                if ground and ground.Normal.Y>.65 then
                    count+=1
                    local arrow=arrows[count] or newArrow()
                    arrows[count]=arrow
                    local pos=ground.Position+Vector3.yAxis*.13
                    arrow:PivotTo(CFrame.lookAt(pos,pos+heading))
                    arrow.Parent=folder
                end
                spacing+=8
            end
            if count==14 then break end
            spacing-=delta.Magnitude
        end
        hideAfter(count)
    end
    return update
end
