-- levelcode

function _init()
 globalg = {}
 globalg.dt = 1/30
 globalg.framestepcount=0
 globalg.framesperstep=100
 globalg.pause = false
 globalg.debugstr = ""

 local grid = {}
 grid.x = 0
 grid.y = 0
 grid.width = 16
 grid.height = 12
 grid.items = {}

 local player = {}
 player.x = 5
 player.y = 5
 player.dir = nil
 player.selabil = 1

 local abil = {}
 add(abil,{name="walk",sprite=2})
 add(abil,{name="dash",sprite=9})
 add(abil,{name="sleep",sprite=10})

 player.abil = abil

 grid.player = player


 for x=0,grid.width do
   grid.items[x] = {}
  for y=0,grid.height do
   if x==0 or y==0 or x==grid.width-1 or y==grid.height-1 then
    grid.items[x][y] = createborder()
   else
    grid.items[x][y] = creategrass()
   end
  end
 end

 globalg.grid = grid

end

-- accurate to .xxxx
-- could prob be written better
function rndper(p)
 local d = flr(p*10000)
 return rnd(10000) < d
end

function createitem()
 return {type=nil,burned=false,walkable=true}
end

function createborder()
 local i = createitem()
 i.type = "border"
 i.walkable = false
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

-- sometimes walkable?
function createfire()
 local i = createitem()
 i.type = "fire"
 i.dwindlechance = .90
 i.spreadchance = .40
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
  update(globalg, globalg.grid, shouldstep)
 end

end



function update(g, grid, shouldstep)

  -- if commited to turn, allow advancing of time
  local stepmod = 1
  if btn(4) then
   stepmod = 4
  end

  g.framestepcount+= (1*stepmod)
  local shouldstep = false
  if (g.framestepcount >= g.framesperstep) then
   shouldstep = true
   g.framestepcount = 0
  end

 -- placeholder game start
 if btnp(2) then
  grid.items[5][5].burned = true
 end

 local pl = grid.player
 if btnp(0) then
  pl.dir = "left"
 elseif btnp(1) then
  pl.dir = "right"
 elseif btnp(2) then
  pl.dir = "up"
 elseif btnp(3) then
  pl.dir = "down"
 end

 if btnp(5) then
  pl.selabil = pl.selabil + 1
  if (pl.selabil > #pl.abil) then
   pl.selabil = 1
  end
 end

 if (shouldstep == true) then
  stepplayer(grid)
  stepgrid(grid)
 end

end

function stepplayer(grid)
 local pl = grid.player
 local abil = pl.abil[pl.selabil]

 if (abil.name == "walk") then
  stepplayerwalk(grid, pl)
 elseif (abil.name == "dash") then
  stepplayerdash(grid, pl)
 elseif (abil.name == "sleep") then
  -- do nothing
 end
 -- not sure if this is better or worse control wise
 -- to zero out the dir
 pl.dir = nil

end

function stepplayerdash(grid, pl)

 if pl.dir == nil then
  return
 end

 local tx,ty = pl.x,pl.y
 local nx,ny = tx,ty

 repeat
  nx = tx
  ny = ty
  if pl.dir == "left" then
   tx -= 1
  elseif pl.dir == "right" then
   tx += 1
  elseif pl.dir == "up" then
   ty -= 1
  elseif pl.dir == "down" then
   ty += 1
  end
 until (not grid.items[tx][ty].walkable)

 pl.x = nx
 pl.y = ny

end


function stepplayerwalk(grid, pl)
 
 if pl.dir == nil then
  return
 end

 local pl = grid.player
 local nx,ny = pl.x,pl.y

 if pl.dir == "left" then
  nx -= 1
 elseif pl.dir == "right" then
  nx += 1
 elseif pl.dir == "up" then
  ny -= 1
 elseif pl.dir == "down" then
  ny += 1
 end

 if grid.items[nx][ny].walkable then
  pl.x = nx
  pl.y = ny
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
  draw(g)
  dprintflush()
 end
end

function pointdistance(x1,y1,x2,y2)
 local xsqu = (x2-x1)*(x2-x1)
 local ysqu = (y2-y1)*(y2-y1)
 return sqrt(xsqu + ysqu)
end

--fireheight between 0 (nofire) and 1 (fullfire)
function drawfire(ix,iy,fireheight)
 local firesprite = 16 + rnd(16) -- row of 16 possible fire sprites
 local flipx = rndper(.50)


 local pixelfh = flr(8*fireheight)
 local adjpfh = max(pixelfh,2)
 local pushdown = 8 - adjpfh

 -- draw grass background
 spr(5,ix,iy)


 clip(ix,iy,8,8)
 palt(0,true) -- make black transparent

 spr(firesprite,ix,iy+pushdown,1,1)

 palt()
 clip()
end

function drawrectfill(x,y,w,h,col)
 rectfill(x,y,x+w-1,y+h-1,col)
end

function drawrect(x,y,w,h,col)
 rect(x,y,x+w-1,y+h-1,col)
end

function sprcoord(num)
 local row = num \ 16
 local spotinrow = num % 16
 return {x=spotinrow*8,y=row*8}
end

function drawhud(game)
 local g = game
 local pl = g.grid.player

 -- draw turn timer
 local perc = g.framestepcount / g.framesperstep

 local barcol = 7
 if perc > .86 then
  barcol = 8
 elseif perc > .5 then
  barcol = 6
 else
  barcol = 5
 end

 local barheight = 4
 local overlapamt = 4

 local maxwidth = (8*8) + (overlapamt) -- allow a lil overlap
 local barwidth = maxwidth*perc

 -- draw bar from left
 local x1 = 0
 local y = (8*16)-1-barheight
 drawrectfill(x1,y,barwidth,barheight,barcol)

 -- draw bar from right
 local minx2 = 8*8
 local x2 = minx2 + (minx2 - barwidth)
 drawrectfill(x2,y,barwidth,barheight,barcol)


 -- draw abilities
 local xstart = 0
 local xend = (8*16)-1
 local ystart = (8*g.grid.height)+g.grid.y
 local yend = (8*16)-1-barheight
 local abilcount = #pl.abil
 local abilwidth = (xend-xstart)/abilcount
 local abilheight = (yend-ystart)


 for i=1,#pl.abil do
  local abil = pl.abil[i]

  local rectcol = 4

  if (pl.selabil == i) then
   rectcol = 10
  end

  local sc = sprcoord(abil.sprite)
  sspr(sc.x,sc.y,8,8,xstart,ystart,abilwidth,abilheight)
  drawrect(xstart,ystart,abilwidth,abilheight,rectcol)
  xstart += abilwidth
 end


end

function drawplayer(grid)
 -- draw player sprite
 local pl = grid.player

 local px, py = pl.x*8, pl.y*8

 local offset = 3

 palt(0,true)

 spr(1,px,py)

 -- draw direction arrow
 if pl.dir == "left" then
  spr(2,px-offset,py,1,1,true)
 elseif pl.dir == "right" then
  spr(2,px+offset,py)
 elseif pl.dir == "up" then
  spr(3,px,py-offset)
 elseif pl.dir == "down" then
  spr(3,px,py+offset,1,1,false,true)
 end
 palt()
end

function draw(game)

 drawgrid(game.grid)
 drawplayer(game.grid)
 drawhud(game)

 --drawrect(0, 0, 128, 128, 1)
end


function drawgrid(grid)
 cls()
 local pl = grid.player
 for x=0,grid.width-1 do
  for y=0,grid.height-1 do
   obj = grid.items[x][y]
   px = (x*8)+grid.x
   py = (y*8)+grid.y
   if (obj.type == "grass") then
    spr(5,px,py)
   elseif (obj.type == "fire") then
    drawfire(px,py,obj.burnheight/obj.burnheightmax)
   elseif (obj.type == "dirt") then
    spr(4,px,py)
   end
  end
 end
end

function dprint(o)
 globalg.debugstr = globalg.debugstr..dtostring(o).."\n"
end

function dprintflush()
 print(globalg.debugstr,1,1,15)
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