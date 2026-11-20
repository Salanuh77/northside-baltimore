-- Update only the experience listing; never upload or publish a place revision.
local rb=require('@lune/roblox')
local fs=require('@lune/fs')
local net=require('@lune/net')
local serde=require('@lune/serde')
local cookie=assert(rb.getAuthCookie(),'Roblox Studio sign-in is required')
local csrf
local function request(method,url,data)
 local headers={Cookie=cookie,['Content-Type']='application/json'}
 if csrf then headers['x-csrf-token']=csrf end
 local options={url=url,method=method,headers=headers}
 if data then options.body=serde.encode('json',data) end
 local result=net.request(options)
 if result.statusCode==403 then
  csrf=result.headers['x-csrf-token'] or result.headers['X-CSRF-TOKEN']
  if csrf then headers['x-csrf-token']=csrf;result=net.request(options) end
 end
 assert(result.statusCode==200,'Listing request failed: HTTP '..result.statusCode)
 return serde.decode('json',result.body)
end
local listing=serde.decode('json',fs.readFile('release-metadata.json'))
assert(type(listing.description)=='string' and #listing.description<1000,'Description exceeds listing budget')
local place='https://develop.roblox.com/v2/places/131234846449292'
local universe='https://develop.roblox.com/v2/universes/10755218391/configuration'
local previous=request('GET',place)
assert(previous.universeId==10755218391 and previous.isRootPlace and previous.name==listing.name,'Unexpected experience')
fs.writeFile('marketing/listing-backup.receipt.json',serde.encode('json',{name=previous.name,description=previous.description,version=previous.currentSavedVersion},true))
for _,url in {universe,place} do request('PATCH',url,{description=listing.description}) end
local verified=request('GET',place)
assert(verified.description==listing.description and verified.currentSavedVersion==previous.currentSavedVersion,'Listing verification failed')
fs.writeFile('marketing/listing-update.receipt.json',serde.encode('json',{name=verified.name,description=verified.description,placeId=verified.id,placeVersion=verified.currentSavedVersion},true))
print('VERIFIED listing updated; place revision unchanged:',verified.currentSavedVersion)
