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
local listing=serde.decode('json',fs.readFile('release-metadata.json'))
local target=131234846449292
local cfg=request('GET','https://develop.roblox.com/v2/places/'..target)
assert(cfg.statusCode==200,'Cannot verify target')
local config=serde.decode('json',cfg.body)
assert(config.universeId==10755218391 and config.isRootPlace,'Wrong destination')
assert(config.name=='Squishy factory' or (config.name=='Northside Baltimore' or config.name==listing.name),'Unexpected target name')
local args=require('@lune/process').args
local expected=assert(tonumber(args[1]),'Expected live revision required')
assert(config.currentSavedVersion==expected,'Live place revision changed since review')
local bytes=fs.readFile(assert(args[2],'Tested artifact path required'))
assert(serde.hash('sha256',bytes)==string.lower(assert(args[3],'Tested SHA256 required')),'Candidate hash changed')
local model=rb.deserializePlace(bytes)
assert(model:GetService('Workspace'):FindFirstChild('Baltimore'))
assert(not model:GetService('ReplicatedStorage'):FindFirstChild('TestDrive'))
local boundary='NorthsidePublishBoundary20261115'
local body='--'..boundary..'\r\nContent-Disposition: form-data; name="request"\r\nContent-Type: application/json\r\n\r\n'..serde.encode('json',{assetId=target,assetType='Place',published=true})..'\r\n--'..boundary..'\r\nContent-Disposition: form-data; name="fileContent"; filename="Northside Baltimore.rbxl"\r\nContent-Type: application/octet-stream\r\n\r\n'..bytes..'\r\n--'..boundary..'--\r\n'
local result=request('PATCH','https://apis.roblox.com/assets/user-auth/v1/assets/'..target,body,'multipart/form-data; boundary='..boundary)
print('PUBLISH_UPLOAD',result.statusCode,result.body)
assert(result.statusCode>=200 and result.statusCode<300,'Upload rejected')
local operation=serde.decode('json',result.body)
fs.writeFile('publish-operation.json',serde.encode('json',operation,true))
local done
for i=1,25 do
 local response=request('GET','https://apis.roblox.com/assets/user-auth/v1/'..operation.path)
 assert(response.statusCode==200,'Cannot verify publish operation')
 local status=serde.decode('json',response.body)
 if status.done then done=status; break end
 task.wait(2)
end
assert(done,'Publish still processing; check saved operation')
fs.writeFile('publish-receipt.json',serde.encode('json',done,true))
print('PUBLISH_RECEIPT',serde.encode('json',done))
assert(not done.error and done.response and done.response.isPublished==true,'Published state unconfirmed')

-- Optional promotional text has its own Roblox review and must not be bundled
-- into the required name/description update after a successful place upload.
local listingUpdate={name=listing.name,description=listing.description}
for _,url in {'https://develop.roblox.com/v2/universes/10755218391/configuration','https://develop.roblox.com/v2/places/'..target} do
 local renamed=request('PATCH',url,serde.encode('json',listingUpdate),'application/json')
 print('RENAME_RESULT',renamed.statusCode,renamed.body)
 assert(renamed.statusCode==200,'Name update rejected')
end
local verify=request('GET','https://develop.roblox.com/v2/places/'..target)
assert(verify.statusCode==200,'Could not verify final place')
local final=serde.decode('json',verify.body)
assert(final.name==listing.name and final.id==target and final.currentSavedVersion==tonumber(done.response.revisionId),'Final place version mismatch')
fs.writeFile('published-place.json',verify.body)
print('FINAL_PLACE',final.name,final.currentSavedVersion)
local delivery=request('GET','https://assetdelivery.roblox.com/v2/asset/?id='..target..'&version='..final.currentSavedVersion)
assert(delivery.statusCode==200,'Could not inspect published revision')
local location=assert(serde.decode('json',delivery.body).locations[1].location)
local shipped=net.request({url=location})
assert(shipped.statusCode==200 and shipped.body==bytes,'Published artifact differs from tested candidate')
print('VERIFIED_PUBLISHED_SHA256',args[3])
