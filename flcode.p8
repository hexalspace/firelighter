-- levelcode

function _init()
 globalg = {}
 globalg.dt = 1/30
 globalg.pause = false
 globalg.debugstr = ""
end

function _update()
 local g = globalg

 if btnp(2) then
  g.pause = not g.pause
 end

 if not g.pause then
  update()
 end

end

function update()

end

function _draw()
 local g = globalg
 if not g.pause then
  draw()
  dprintflush()
 end
end

function draw()
 cls()
 map(0,0,0,0,16,16)
 --spr(4, 0, 0) 
end

function dprint(o)
 if (type(o) == "string") then
   globalg.debugstr = globalg.debugstr..o.."\n"
 else
  globalg.debugstr = globalg.debugstr..dtostring(o).."\n"
 end
end

function dprintflush()
 print(globalg.debugstr, 0,0,7)
 globalg.debugstr = ""
end

function dtostring(t)
 dtostringhelper(t,"")
end
 
function dtostringhelper(t, indent)
 if t == nil then 
  return indent.."nil"
 end
 local tstring = ""
 local firstit = true
 for k,v in pairs(t) do
  local val = v
  if val == nil then
   val = "nil"
  elseif val == true then
   val = "true"
  elseif val == false then
   val = "false"
  elseif (type(val) == "table") then
   -- indent two spaces each time
   val = "subtable\n"..dtostringhelper(val, indent.."  ")
  end
  if firstit then
   tstring = tstring..indent..k.." = "..val
   firstit = false
  else
   tstring = tstring.."\n"..indent..k.." = "..val
  end
 end
 return tstring
end