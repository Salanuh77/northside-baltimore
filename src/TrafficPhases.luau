-- One complete intersection cycle, shared by every approach at the same junction.
local Phases = {}
function Phases.at(seconds, axis, offset)
 local tick = math.floor(seconds + offset - axis * 17) % 34
 if tick < 12 then
  return 'Green', tick < 9 and 'Walk' or (tick % 2 == 0 and 'Clear' or 'Stop')
 elseif tick < 15 then
  return 'Amber', 'Stop'
 end
 return 'Red', 'Stop'
end
return Phases
