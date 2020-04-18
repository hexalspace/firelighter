-- levelcode

function _init()
 globalg = {}
 globalg.dt = 1/30
 globalg.framestepcount=0
 globalg.framesperstep=60
 globalg.pause = false
 globalg.debugstr = ""

 grid = {}
 grid.width = 16
 grid.height = 16
 grid.items = {}


 for x=-1,grid.width do
   grid.items[x] = {}
  for y=-1,grid.height do
   if x==-1 or y==-1 or x==-1 or y==-1 then
    grid.items[x][y] = {type="border",burned=false}
   else
    grid.items[x][y] = {type="grass",burned=false}
   end
   
  end
 end

 globalg.grid = grid

end

function _update()
 local g = globalg

 --if btnp(2) then
 -- g.pause = not g.pause
 --end

 if not g.pause then
  g.framestepcount+=1
  local shouldstep = false
  if (g.framestepcount >= g.framesperstep) then
   shouldstep = true
   g.framestepcount = 0
  end

  update(globalg.grid, shouldstep)
 end

end

function update(grid, shouldstep)
 if btnp(2) then
  grid.items[0][0].type = "fire"
 end


 if (shouldstep == true) then
  stepgrid(grid)
 end

end

function stepgrid(grid)
 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]
   if (obj.type == "fire") then
    grid.items[x+1][y].burned = true
    grid.items[x-1][y].burned = true
    grid.items[x][y+1].burned = true
    grid.items[x][y-1].burned = true
   end
  end
 end

 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]
   if (obj.burned == true) then
    obj.type = "fire"
    obj.burned = false
   end
  end
 end

end

function _draw()
 local g = globalg
 if not g.pause then
  draw(g.grid)
  dprintflush()
 end
end


function draw(grid)
 cls()
 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]
   if (obj.type == "grass") then
    spr(5,x*8,y*8)
   elseif (obj.type == "fire") then
    spr(1,x*8,y*8)
   elseif (obj.type == "dirt") then
    spr(4,x*8,y*8)
   end
  end
 end
end

function dprint(o)
 globalg.debugstr = globalg.debugstr..dtostring(o).."\n"
end

function dprintflush()
 print(globalg.debugstr,0,0,0)
 globalg.debugstr = ""
end

function dtostring(o)
 if (type(o) == "table") then
  return dtostringtable(o)
 elseif (type(o) == "nil") then
  return "nil"
 elseif (type(o) == "boolean") then
  if (o == true) then
   return "true"
  else
   return "false"
  end
 elseif (type(o) == "number") then
  return tostr(o)
 elseif (type(o) == "string") then
  return o
 else
  return "unknown type"
 end
end

function dtostringtable(t)
 return dtostringhelper(t,"")
end
 
function dtostringhelper(t, indent)
 local tstring = ""
 local firstit = true
 for k,v in pairs(t) do
  local toprint = ""
  if (type(v) == "table") then
   -- indent two spaces each time
   toprint = "subtable\n"..dtostringhelper(v, indent.."  ")
  else
   toprint = dtostring(v)
  end
  if firstit then
   tstring = tstring..indent..k.." = "..toprint
   firstit = false
  else
   tstring = tstring.."\n"..indent..k.." = "..toprint
  end
 end
 return tstring
end