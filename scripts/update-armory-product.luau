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
local url='https://apis.roblox.com/developer-products/v2/universes/10755218391/developer-products/3732000729'
local r=request('GET',url..'/creator');assert(r.ok,'Product details HTTP '..r.statusCode)
local before=serde.decode('json',r.body);print('PRODUCT',before.name,before.priceInformation)
if require('@lune/process').args[1]=='apply' then
 local fields={name='Patapsco Precision Carbine',description='One tradable premium precision carbine for the active resident. Slower semi-auto shots with longer reach; standard guns are available for city cash. Optics and muzzle attachments sold separately for city cash.'}
 local boundary='BaltimoreProductUpdate24';local chunks={}
 for key,value in fields do table.insert(chunks,'--'..boundary..'\r\nContent-Disposition: form-data; name="'..key..'"\r\n\r\n'..value..'\r\n') end
 table.insert(chunks,'--'..boundary..'--\r\n')
 local changed=request('PATCH',url,table.concat(chunks),'multipart/form-data; boundary='..boundary);assert(changed.ok,'Product update HTTP '..changed.statusCode)
 local verify=request('GET',url..'/creator');assert(verify.ok);local after=serde.decode('json',verify.body)
 assert(after.name==fields.name and after.description==fields.description,'Product readback mismatch')
 assert(after.priceInformation.defaultPriceInRobux==before.priceInformation.defaultPriceInRobux,'Unexpected price change')
 print('PRODUCT_UPDATED',after.name,after.priceInformation)
end
