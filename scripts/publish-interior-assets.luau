-- Content-addressed upload ledger: rerunning resumes an operation instead of charging/uploading twice.
local rb,fs,net,serde,task=require('@lune/roblox'),require('@lune/fs'),require('@lune/net'),require('@lune/serde'),require('@lune/task')
local cookie=assert(rb.getAuthCookie(),'Roblox Studio session unavailable')
local token
local function request(method,url,body,contentType)
 local headers={Cookie=cookie};if token then headers['x-csrf-token']=token end
 if contentType then headers['Content-Type']=contentType end
 local r=net.request({url=url,method=method,headers=headers,body=body})
 if r.statusCode==403 then
  token=r.headers['x-csrf-token'] or r.headers['X-CSRF-TOKEN']
  if token then headers['x-csrf-token']=token;r=net.request({url=url,method=method,headers=headers,body=body}) end
 end
 return r
end
local assets=serde.decode('json',fs.readFile('art/assets.json'))
local batch=serde.decode('json',fs.readFile('art/interior-meshy-batch.json'))
local catalog={{key='store-emblems-a',ext='png',kind='Image',mime='image/png'},{key='store-emblems-b',ext='png',kind='Image',mime='image/png'}}
for _,asset in batch.assets do table.insert(catalog,{key='interior-'..asset.key,ext='glb',kind='Model',mime='model/gltf-binary'}) end
local only=require('@lune/process').args[1]
for _,spec in catalog do
 if only and spec.key~=only then continue end
 local file=spec.key..'.'..spec.ext
 if not fs.isFile('art/'..file) then print('NOT_DOWNLOADED',file);continue end
 local bytes=fs.readFile('art/'..file)
 local receipt='art/'..file..'.'..serde.hash('sha256',bytes):sub(1,12)..'.receipt.json'
 local state=fs.isFile(receipt) and serde.decode('json',fs.readFile(receipt)) or nil
 if not state then
  local boundary='BaltimoreInteriorAsset42'
  local meta={assetType=spec.kind,displayName='Baltimore '..spec.key,description='Original game interior art and business identity.',creationContext={creator={userId='5263645498'}}}
  local body='--'..boundary..'\r\nContent-Disposition: form-data; name="request"\r\nContent-Type: application/json\r\n\r\n'..serde.encode('json',meta)..'\r\n--'..boundary..'\r\nContent-Disposition: form-data; name="fileContent"; filename="'..file..'"\r\nContent-Type: '..spec.mime..'\r\n\r\n'..bytes..'\r\n--'..boundary..'--\r\n'
  local r=request('POST','https://apis.roblox.com/assets/user-auth/v1/assets',body,'multipart/form-data; boundary='..boundary)
  assert(r.ok,'Asset upload '..spec.key..' HTTP '..r.statusCode)
  state=serde.decode('json',r.body);fs.writeFile(receipt,serde.encode('json',state,true))
 end
 for _=1,90 do
  if state.done then break end
  assert(state.path,'Missing saved upload operation')
  task.wait(2)
  local r=request('GET','https://apis.roblox.com/assets/user-auth/v1/'..state.path)
  assert(r.ok,'Cannot inspect upload operation: '..r.statusCode)
  state=serde.decode('json',r.body);fs.writeFile(receipt,serde.encode('json',state,true))
 end
 assert(state.response and state.response.assetId,'Upload incomplete; rerun to resume '..spec.key)
 local id=state.response.assetId;assets[spec.key]=id;fs.writeFile('art/assets.json',serde.encode('json',assets,true))
 local permission=request('PATCH','https://apis.roblox.com/asset-permissions-api/v1/assets/permissions',serde.encode('json',{subjectType='Universe',subjectId='10755218391',action='Use',assetIds={tonumber(id)}}),'application/json')
 assert(permission.ok,'Asset permission HTTP '..permission.statusCode)
 if spec.kind=='Model' then
  local r=request('GET','https://assetdelivery.roblox.com/v2/asset/?id='..id);assert(r.ok,'Asset delivery metadata')
  local delivery=serde.decode('json',r.body)
  local download=net.request({url=assert(delivery.locations and delivery.locations[1],'Model not ready').location})
  assert(download.ok,'Model download failed');fs.writeFile('art/'..spec.key..'.rbxm',download.body)
 end
 print('ASSET_READY',spec.key,id)
end
