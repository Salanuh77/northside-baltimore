local Appearance={}
function Appearance.new()
 return {Height='Medium',Build='Average',Tone='Amber',Hair='Close crop',Name='Avery Bell',FirstName='Avery',LastName='Bell',FaceShape='Oval',FaceWidth='Balanced',EyeSpacing='Balanced',LipFullness='Medium',Depth='Standard',Pants='Dark denim',Shoes='Bone low-tops',Mouth='Level',HairDetail='Natural',Starter='Ash pullover',Detail='Clean',HairColor='Black',Eye='Brown',Expression='Calm'}
end
function Appearance.restore(data,lists)
 local look=Appearance.new()
 if type(data)~='table' then return look end
 for key,options in lists do if table.find(options,data[key]) then look[key]=data[key] end end
 for _,key in {'Name','FirstName','LastName'} do
  local value=data[key]
  if type(value)=='string' and #value>0 and #value<=80 and utf8.len(value) then look[key]=value end
 end
 return look
end
return Appearance
