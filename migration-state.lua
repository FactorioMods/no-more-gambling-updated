-- Native 2.1 ownership migration supplies whole old roots under storage._migrated.
-- Preserve those roots and all object/metatable/cyclic identities; never shallow-copy them.
local migration={}
local origins={"no-more-gambling"}
local map_domains={nmg_transitions=true}
local imported=false
local function is_plain_table(value)
 return type(value)=="table" and not value.object_name
end
local function check_merge(old,new,path,seen)
 if old==new then return end
 seen[old]=seen[old] or {};if seen[old][new] then return end;seen[old][new]=true
 for key,value in pairs(new) do
  if key~="_migrated" then
   local previous=old[key]
   if previous~=nil and previous~=value then
    if is_plain_table(previous) and is_plain_table(value) then
     check_merge(previous,value,path.."."..tostring(key),seen)
    else
     error("no-more-gambling-updated: conflicting existing state at "..path.."."..tostring(key))
    end
   end
  end
 end
end
local function apply_merge(old,new,seen)
 if old==new then return end
 seen[old]=seen[old] or {};if seen[old][new] then return end;seen[old][new]=true
 for key,value in pairs(new) do
  if key~="_migrated" then
   if old[key]==nil then old[key]=value
   elseif old[key]~=value and is_plain_table(old[key]) and is_plain_table(value) then apply_merge(old[key],value,seen) end
  end
 end
end
function migration.adopt()
 local incoming=storage._migrated
 if not incoming then return false end
 local roots={}
 for _,origin in ipairs(origins) do if incoming[origin] then roots[#roots+1]=incoming[origin] end end
 if #roots==0 then return false end
 roots[#roots+1]=storage
 -- Domain policy: retain disjoint player/entity maps and equal values; reject
 -- overlapping live values before mutating any root. Check every pair first.
 for i=1,#roots do
  for j=i+1,#roots do
   for key,value in pairs(roots[j]) do
    local previous=roots[i][key]
    if key~="_migrated" and previous~=nil and previous~=value then
     assert(map_domains[key] and is_plain_table(previous) and is_plain_table(value),"no-more-gambling-updated: conflicting existing root field "..tostring(key))
    end
   end
   check_merge(roots[i],roots[j],"storage",{})
  end
 end
 local payload=roots[1]
 for i=2,#roots do apply_merge(payload,roots[i],{}) end
 for _,origin in ipairs(origins) do incoming[origin]=nil end
 if next(incoming) then payload._migrated=incoming end
 storage=payload
 imported=true
 return true
end
function migration.imported_this_session() return imported end
return migration
