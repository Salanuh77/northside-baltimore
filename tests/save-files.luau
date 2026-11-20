local fs=require('@lune/fs')
assert(fs.isFile('src/ResidentFiles.luau'),'Missing resident save files')
local files=require('../src/ResidentFiles')
local function sample(name,cash)
 return {Look={Name=name},Cash=cash,Receipts={first=true},Trades={done=true}}
end
local old=sample('River',785)
local account=files.open(old)
assert(account.Files['1'].Look.Name=='River' and account.Files['1'].Cash==785)
assert(account.Receipts.first and files.hasTrade(account,'done'))
assert(#files.list(account)==3 and files.list(account)[1].Name=='River' and not files.list(account)[2].Name)
local summary=files.list(account)[1]
assert(summary.Occupied and summary.Look.Name=='River' and not summary.Receipts and not summary.Trades)
summary.Look.Name='Preview edit';assert(account.Files['1'].Look.Name=='River','Preview aliases the saved appearance')
local updated=files.write(account,2,sample('Quay',24))
assert(updated.Files['1'].Cash==785 and updated.Files['2'].Cash==24 and not account.Files['2'])
assert(files.open(updated).Files['2'].Look.Name=='Quay')
assert(not files.hasTrade(updated,'absent'))
local empty=files.open(nil);assert(next(empty.Files)==nil)
local legacy=files.open({Cash=960,Bank=88});assert(legacy.Files['1'].Cash==960)
for _,bad in {0,4,2.1,'1',0/0} do assert(not files.valid(bad)) end
for i=1,3 do assert(files.valid(i)) end
print('PASS: fresh accounts, migration, three slots, receipts, trades and isolated files')
