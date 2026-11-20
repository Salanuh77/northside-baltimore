-- Coordinates are relative to the ScreenGui's CoreUISafeInsets region.
local Layout={}
function Layout.measure(width,height,appearance,identity)
 local w=math.min(1440,width);local h=height
 local margin=w<720 and 12 or 24
 local portrait=w<600 and h>w
 local header=h<430 and 48 or 76
 local footer=h<430 and 54 or 68
 local sidebar=portrait and w-margin*2 or math.clamp(math.floor(w*.30),220,360)
 local tabs=appearance and 44 or 0
 local top=portrait and math.min(math.floor(h*.45),header+320) or header+8
 local preview=portrait and {margin,header,w-margin*2,top-header-8}
  or {margin+sidebar+20,header+8,w-sidebar-margin*2-20,h-header-footer-20}
 local available=math.max(60,h-top-footer-tabs-12)
 local column=identity and (sidebar-12)/2 or sidebar
 return {width=w,height=h,x=(width-w)/2,margin=margin,header=header,footer=footer,
  sidebar=sidebar,top=top,tabs=tabs,available=available,column=column,preview=preview,portrait=portrait}
end
return Layout
