-- levelcode

function _init()
 globalg = {}
 globalg.dt = 1/30
 globalg.framestepcount=0
 globalg.framesperstep=10
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
    grid.items[x][y] = createborder()
   else
    grid.items[x][y] = creategrass()
   end
   
  end
 end

 globalg.grid = grid

end

-- accurate to .xxxx
function rndper(p)
 local d = flr(p*10000)
 return rnd(10000) < d
end

function createitem()
 return {type=nil,burned=false}
end

function createborder()
 local i = createitem()
 i.type = "border"
 return i
end

function creategrass()
 local i = createitem()
 i.type = "grass"
 return i
end

function createdirt()
 local i = createitem()
 i.type = "dirt"
 return i
end

function createfire()
 local i = createitem()
 i.type = "fire"
 i.dwindlechance = .90
 i.spreadchance = .90
 i.burnheight = 10
 i.burnheightmax = 10
 return i
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
  grid.items[5][5].burned = true
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
    local burnmod = obj.burnheight/obj.burnheightmax
    if rndper(obj.spreadchance*burnmod) then
     grid.items[x+1][y].burned = true
    end
    if rndper(obj.spreadchance*burnmod) then
     grid.items[x-1][y].burned = true
    end
    if rndper(obj.spreadchance*burnmod) then
     grid.items[x][y+1].burned = true
    end
    if rndper(obj.spreadchance*burnmod) then
     grid.items[x][y-1].burned = true
    end

    if rndper(obj.dwindlechance) then
     obj.burnheight -= 1
    end

   end
  end
 end

 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]

   if (obj.type == "border") then
    -- do nothing
   elseif (obj.type == "fire") then
    if obj.burnheight <= 0 then
     grid.items[x][y] = createdirt()
    end
   elseif (obj.type == "grass") then
    if obj.burned then
     grid.items[x][y] = createfire()
    end
   elseif (obj.type == "dirt") then
    -- do nothing
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

function pointdistance(x1,y1,x2,y2)
 local xsqu = (x2-x1)*(x2-x1)
 local ysqu = (y2-y1)*(y2-y1)
 return sqrt(xsqu + ysqu)
end

function drawfire(ix,iy,width,height,burnheight,burnheightmax)
 --using sprite sheet spot 32 as tempspace and avoiding pset
 local sx = 0
 local sy = 16 

  -- fire hottest point
 local fhp = {x=sx+(width/2), y=sy+height}
 -- max distance fire can be drawn from hp
 local maxdisthp = (9*(height/10))*(burnheight/burnheightmax)

 for x=sx,sx+width-1 do
  for y=sy,sy+height-1 do
   local dist = pointdistance(x,y, fhp.x, fhp.y)
   local distmod = 1-(min(1,(dist/maxdisthp)))
   -- white
   if rndper(distmod*.2) then
    sset(x,y,7)
   -- orange
   elseif rndper(distmod*.6) then
    sset(x,y,9)
   -- red
   elseif rndper(distmod*.3) then
    sset(x,y,8)
   -- black
   else
    sset(x,y,0)
   end
  end
 end
 -- background for fire
 spr(6,ix,iy)
 sspr(sx,sy,width,height,ix,iy)
end


function draw(grid)
 cls()
 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]
   if (obj.type == "grass") then
    spr(5,x*8,y*8)
   elseif (obj.type == "fire") then
    drawfire(x*8,y*8,8,8,obj.burnheight,obj.burnheightmax)
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