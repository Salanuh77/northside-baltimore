-- Clockwise degrees from the camera's horizontal heading, plus ground distance.
return function(forward, offset)
    local distance = math.sqrt(offset.X * offset.X + offset.Z * offset.Z)
    if distance < 0.001 then return 0, 0 end
    local x, z = forward.X, forward.Z
    if x*x + z*z < 0.000001 then x, z = 0, -1 end
    local right = -z * offset.X + x * offset.Z
    local ahead = x * offset.X + z * offset.Z
    return math.deg(math.atan2(right, ahead)), distance
end
