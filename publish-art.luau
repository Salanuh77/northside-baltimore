local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local net=require('@lune/net')
local serde=require('@lune/serde')
local task=require('@lune/task')
local cookie=assert(rb.getAuthCookie(),'Roblox session unavailable')
local token=nil
local function request(method,url,body,contentType)
 local headers={Cookie=cookie}; if token then headers['x-csrf-token']=token end
 if contentType then headers['Content-Type']=contentType end
 local r=net.request({url=url,method=method,headers=headers,body=body})
 if r.statusCode==403 then
  local fresh=r.headers['x-csrf-token'] or r.headers['X-CSRF-TOKEN']
  if fresh then token=fresh; headers['x-csrf-token']=fresh; r=net.request({url=url,method=method,headers=headers,body=body}) end
 end
 return r
end
local assets={}
local catalog={{'Image','alley-paint.png','image/png','Northside alley paint'},{'Audio','meridian-afterhours.wav','audio/wav','Meridian Afterhours'}}
for _,name in {'athlete-paint','block-marks','alley-walls','baltimore-history','fleet-track','pier-varsity','foundry-work','indigo-denim'} do table.insert(catalog,{'Image',name..'.png','image/png',name}) end
for _,spec in catalog do
 local file=spec[2]
 local receipt='art/'..file..'.receipt.json'
 local done=fs.isFile(receipt) and serde.decode('json',fs.readFile(receipt)) or nil
 if not done or not done.response then
  local meta={assetType=spec[1],displayName=spec[4],description='Original artwork for Northside Baltimore.',creationContext={creator={userId='5263645498'}}}
  local boundary='NorthsideCreativeAsset42'
  local body='--'..boundary..'\r\nContent-Disposition: form-data; name="request"\r\nContent-Type: application/json\r\n\r\n'..serde.encode('json',meta)..'\r\n--'..boundary..'\r\nContent-Disposition: form-data; name="fileContent"; filename="'..file..'"\r\nContent-Type: '..spec[3]..'\r\n\r\n'..fs.readFile('art/'..file)..'\r\n--'..boundary..'--\r\n'
  local result=request('POST','https://apis.roblox.com/assets/user-auth/v1/assets',body,'multipart/form-data; boundary='..boundary)
  print(spec[1],result.statusCode)
  assert(result.statusCode==200,result.body)
  local op=serde.decode('json',result.body)
  for _=1,40 do
   local state=request('GET','https://apis.roblox.com/assets/user-auth/v1/'..op.path)
   done=serde.decode('json',state.body)
   if done.done then break end
   task.wait(2)
  end
  print(spec[1],serde.encode('json',done))
  assert(done.response and done.response.assetId)
  fs.writeFile(receipt,serde.encode('json',done,true))
 end
 assets[file=='alley-paint.png' and 'Image' or spec[1]=='Audio' and 'Audio' or file:sub(1,-5)]=done.response.assetId
end
fs.writeFile('art/assets.json',serde.encode('json',assets,true))

local ids={}
for _,id in assets do table.insert(ids,tonumber(id)) end
local permission=request('PATCH','https://apis.roblox.com/asset-permissions-api/v1/assets/permissions',serde.encode('json',{subjectType='Universe',subjectId='10755218391',action='Use',assetIds=ids}),'application/json')
print('EXPERIENCE_ASSET_ACCESS',permission.statusCode,permission.body)
for k,id in assets do
 local status=request('GET','https://apis.roblox.com/assets/user-auth/v1/assets/'..id)
 if status.statusCode==200 then local asset=serde.decode('json',status.body); print(k,asset.moderationResult and asset.moderationResult.moderationState,asset.state) end
end
