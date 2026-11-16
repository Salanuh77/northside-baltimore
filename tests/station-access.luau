local rb = require('@lune/roblox')
local fs = require('@lune/fs')
local city = rb.deserializePlace(fs.readFile('Northside Baltimore - Heritage Harbor.rbxl')):GetService('Workspace').Baltimore
local v = rb.Vector3
local solids = {}
for _,part in city:GetDescendants() do
    if part:IsA('BasePart') and part.CanCollide and part.CFrame.Y - part.Size.Y/2 < 9 then
        table.insert(solids, part)
    end
end
local function corridor(site, frame, first, last)
    local nearby = {}
    local midpoint = frame:PointToWorldSpace(v.new(0,4,(first+last)/2))
    for _,part in solids do
        if (part.CFrame.Position-midpoint).Magnitude < part.Size.Magnitude/2 + (last-first)/2 + 12 then
            table.insert(nearby, part)
        end
    end
    for z=first,last,1 do
        for _,x in {-3,0,3} do
            for _,y in {2.8,5,7.3} do
                local at=frame:PointToWorldSpace(v.new(x,y,z))
                for _,part in nearby do
                    local q=part.CFrame:PointToObjectSpace(at)
                    local h=part.Size/2
                    assert(math.abs(q.X)>h.X or math.abs(q.Y)>h.Y or math.abs(q.Z)>h.Z,
                        site..' approach blocked by '..part:GetFullName()..' at '..tostring(at))
                end
            end
        end
    end
end
for _,name in {'District police desk','Medic dispatch','North Avenue Fuel','Franklin Fuel','Eastside Fuel'} do
    local site=city:FindFirstChild(name,true)
    local floor=site:FindFirstChild('Station house floor') or site['Shop floor']
    local frame=floor.CFrame.Rotation + v.new(floor.CFrame.X,0,floor.CFrame.Z)
    local street=site:GetAttribute('SidewalkOffset')
    assert(street and street < -18,name..' needs a measured street entrance')
    corridor(name,frame,street,site:FindFirstChild('Duty desk') and 3 or 4)
    print('ENTRANCE_PASS',name)
end
