local Reactions={}
function Reactions.step(state,now,input)
 if input.armed and input.visible then state.waryUntil=now+5 end
 local alarm=(input.alarmUntil or 0)>now
 if alarm then state.waryUntil=math.max(state.waryUntil or 0,input.alarmUntil+3) end
 if alarm then return 'Taking shelter',true end
 if input.armed and input.visible then return 'Alarmed',true end
 if now<(state.waryUntil or 0) then return 'Uneasy',false end
 return input.visible and 'Serving' or 'On duty',false
end
return Reactions
