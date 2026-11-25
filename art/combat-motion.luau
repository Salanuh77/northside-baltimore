-- Original R15 key poses in degrees. Timings match StreetCombatRules contact windows.
-- Each strike has anticipation, contact, follow-through and a separate recovery.
local ready={Waist={3,-14,-3},Neck={-3,14,3},LeftShoulder={62,-12,-15},LeftElbow={95,0,0},RightShoulder={52,8,14},RightElbow={108,0,0}}
local guard={Waist={10,-8,0},Neck={-8,8,0},LeftShoulder={88,-14,-12},LeftElbow={118,0,0},RightShoulder={84,14,12},RightElbow={118,0,0}}
local function pose(base,overrides)
 local result=table.clone(base);for key,value in overrides do result[key]=value end;return result
end
local hips={Root={0,0,0,0,-.08,0},LeftHip={12,-8,-5},LeftKnee={16,0,0},LeftAnkle={-8,0,0},RightHip={-8,12,5},RightKnee={12,0,0},RightAnkle={-4,0,0}}
local stance=pose(ready,hips)
return {
 Surrender={loop=true,priority='Action2',frames={{0,{Waist={3,0,0},LeftShoulder={152,0,-18},RightShoulder={152,0,18},LeftElbow={28,0,0},RightElbow={28,0,0}}},{1,{Waist={4,0,0},LeftShoulder={150,0,-18},RightShoulder={150,0,18},LeftElbow={30,0,0},RightElbow={30,0,0}}},{2,{Waist={3,0,0},LeftShoulder={152,0,-18},RightShoulder={152,0,18},LeftElbow={28,0,0},RightElbow={28,0,0}}}}},
 Ready={loop=true,priority='Action',frames={{0,ready},{.6,pose(ready,{Waist={4,-16,-2},LeftElbow={92,0,0}})},{1.2,ready}}},
 Guard={loop=true,priority='Action2',frames={{0,guard},{.45,pose(guard,{Waist={12,-8,0}})},{.9,guard}}},
 Jab={contact=.18,priority='Action2',frames={
  {0,stance},{.065,pose(stance,{Waist={3,-23,-3},LeftShoulder={48,-8,-19},LeftElbow={110,0,0}})},
  {.18,pose(stance,{Waist={4,11,-4},Neck={-3,-8,4},LeftShoulder={92,5,-7},LeftElbow={8,0,0},LeftWrist={0,0,-4},RightHip={-4,0,3}})},
  {.24,pose(stance,{Waist={4,8,-3},LeftShoulder={88,3,-8},LeftElbow={22,0,0}})},
  {.36,pose(stance,{Waist={3,-10,-3},LeftShoulder={66,-8,-13},LeftElbow={94,0,0}})},{.55,stance}}},
 Cross={contact=.22,priority='Action2',frames={
  {0,stance},{.085,pose(stance,{Waist={2,12,-4},RightShoulder={35,20,20},RightElbow={118,0,0}})},
  {.22,pose(stance,{Waist={8,-34,2},Neck={-6,28,-2},RightShoulder={94,-8,5},RightElbow={7,0,0},RightHip={4,-24,5},RightAnkle={-10,-14,0},LeftKnee={24,0,0}})},
  {.30,pose(stance,{Waist={8,-27,2},RightShoulder={86,-7,8},RightElbow={30,0,0}})},
  {.44,pose(stance,{Waist={5,-20,0},RightShoulder={60,4,12},RightElbow={90,0,0}})},{.62,stance}}},
 Hook={contact=.3,priority='Action2',frames={
  {0,stance},{.11,pose(stance,{Waist={8,22,-7},RightShoulder={62,30,62},RightElbow={92,0,0},LeftKnee={28,0,0}})},
  {.22,pose(stance,{Waist={9,-2,-2},RightShoulder={87,5,52},RightElbow={90,0,0}})},
  {.30,pose(stance,{Waist={6,-38,5},Neck={-5,25,-4},RightShoulder={95,-48,22},RightElbow={88,0,0},RightHip={12,-25,6},RightAnkle={-14,-18,0}})},
  {.39,pose(stance,{Waist={7,-44,6},RightShoulder={90,-62,8},RightElbow={102,0,0}})},
  {.59,pose(stance,{Waist={5,-26,0},RightShoulder={58,-8,18},RightElbow={108,0,0}})},{.95,stance}}},
 Flinch={priority='Action3',frames={{0,ready},{.075,pose(ready,{Waist={-18,12,-6},Neck={-17,-10,4},LeftShoulder={48,0,-22},RightShoulder={40,0,22}})},{.18,pose(ready,{Waist={-9,7,-3},Neck={-8,-6,3}})},{.32,ready}}},
 GuardHit={priority='Action3',frames={{0,guard},{.06,pose(guard,{Waist={-6,2,2},LeftShoulder={96,-10,-8},RightShoulder={96,10,8}})},{.22,guard}}},
}
