local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local candidate = rb.deserializePlace(fs.readFile("Northside Baltimore - Heritage Harbor.rbxl"))
local module = candidate:GetService("ReplicatedStorage"):FindFirstChild("JobBearing")
assert(module, "Published client needs a camera-relative job arrow")
local bearing = require("@lune/luau").load(module.Source)()
local v = rb.Vector3
for _, case in {
    {v.new(0,0,-1), v.new(0,0,-30), 0},
    {v.new(0,0,-1), v.new(30,0,0), 90},
    {v.new(0,0,-1), v.new(-30,0,0), -90},
    {v.new(0,0,-1), v.new(0,0,30), 180},
    {v.new(1,-2,0), v.new(30,14,0), 0},
} do
    local rotation, distance = bearing(case[1], case[2])
    assert(math.abs((rotation - case[3] + 180) % 360 - 180) < 0.001)
    assert(distance == 30)
end
local angle, distance = bearing(v.new(0,-1,0), v.new(0,20,0))
assert(angle == 0 and distance == 0)
local city = candidate:GetService("Workspace").Baltimore
assert(city:GetAttribute("CourierDesk") == city:FindFirstChild("Courier desk", true).CFrame.Position)
print("JOB_NAVIGATION_PASS", "cardinal directions, pitched camera, arrival and baked pickup")
local storage = candidate:GetService("ReplicatedStorage")
assert(storage:FindFirstChild("StreetTrail"), "Missing street-level route renderer")
assert(storage:FindFirstChild("WalkingRoute"), "No streaming-independent walking route service")
local clerkDesk = city:FindFirstChild("Eastern Outfitters", true)["Sales counter"]
assert(city:GetAttribute("OutfittersDesk") == clerkDesk.CFrame.Position)
