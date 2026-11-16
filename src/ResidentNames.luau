local Names={}

local function clean(value,limit)
 if type(value)~='string' or #value>limit*4 or value:find('%c') then return nil end
 local text=value:match('^%s*(.-)%s*$'):gsub(' +',' ')
 local length=utf8.len(text)
 if not length or length<1 or length>limit then return nil end
 return text
end

function Names.resolve(data,firstNames,lastNames,filter)
 local name
 if data.FirstName~=nil or data.LastName~=nil then
  local first=clean(data.FirstName,20)
  local last=clean(data.LastName,20)
  if not first or not last then return nil,'Enter a first and last name of up to 20 characters each.' end
  name=first..' '..last
  if table.find(firstNames,first) and table.find(lastNames,last) then return name end
 elseif data.Name=='' then
  return firstNames[1]..' '..lastNames[1]
 else
  name=clean(data.Name,41)
 end
 if not name then return nil,'Enter a fictional roleplay name.' end
 local ok,filtered=pcall(filter,name)
 if not ok then return nil,'Roblox could not check that name. Try again.' end
 local safe=clean(filtered,41)
 if not safe or safe:find('#',1,true) then return nil,'Choose another roleplay name.' end
 return safe
end
return Names
