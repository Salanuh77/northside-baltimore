local Files={}
function Files.valid(index)
 return type(index)=='number' and index>=1 and index<=3 and index%1==0
end
function Files.open(old)
 if old and old.Files then return old end
 local account={Files={},Receipts={},Schema=2}
 if old and (old.Cash~=nil or old.Look or old.Items) then
  local first=table.clone(old)
  first.Lock=nil;first.Lease=nil;first.Receipts=nil
  account.Files['1']=first
  account.Receipts=table.clone(old.Receipts or {})
 end
 return account
end
function Files.list(account)
 local rows={}
 for index=1,3 do
  local slot=account.Files[tostring(index)]
  rows[index]={Index=index,Name=slot and slot.Look and slot.Look.Name,Cash=slot and slot.Cash,
   Look=slot and slot.Look and table.clone(slot.Look),Outfit=slot and slot.Outfit,
   Occupied=slot~=nil,Employment=slot and slot.Employment}
 end
 return rows
end
function Files.write(account,index,snapshot)
 assert(Files.valid(index))
 local nextAccount=table.clone(account)
 nextAccount.Files=table.clone(account.Files)
 local slot=table.clone(snapshot)
 slot.Lock=nil;slot.Lease=nil;slot.Receipts=nil
 nextAccount.Files[tostring(index)]=slot
 nextAccount.Receipts=table.clone(snapshot.Receipts or account.Receipts)
 return nextAccount
end
function Files.hasTrade(account,id)
 for _,slot in account.Files do
  if slot.Trades and slot.Trades[id] then return true end
 end
 return false
end
return Files
