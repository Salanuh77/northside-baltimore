local props=require('../interior-props')
local fs,serde=require('@lune/fs'),require('@lune/serde')
for _,a in serde.decode('json',fs.readFile('art/interior-meshy-batch.json')).assets do
 if fs.isFile('art/interior-'..a.key..'.rbxm') then print(a.key,props.size(a.key)) end
end
