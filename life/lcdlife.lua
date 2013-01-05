-- life.lua
-- eLua version by Bogdan Marinescu, www.eluaproject.net
-- original by Dave Bollinger <DBollinger@compuserve.com> posted to lua-l
-- modified to use ANSI terminal escape sequences
-- modified to use for instead of while

function ARRAY2D(w,h)
  local t = {w=w,h=h}
  for y=1,h do
    t[y] = {}
    for x=1,w do
      t[y][x]=0
    end
  end
  return t
end

_CELLS = {}

-- give birth to a "shape" within the cell array
function _CELLS:spawn(shape,left,top)
  for y=0,shape.h-1 do
    for x=0,shape.w-1 do
      self[top+y][left+x] = shape[y*shape.w+x+1]
    end
  end
end

-- run the CA and produce the next generation
function _CELLS:evolve(next)
  local ym1,y,yp1,yi=self.h-1,self.h,1,self.h
  while yi > 0 do
    local xm1,x,xp1,xi=self.w-1,self.w,1,self.w
    while xi > 0 do
      local sum = self[ym1][xm1] + self[ym1][x] + self[ym1][xp1] +
                  self[y][xm1] + self[y][xp1] +
                  self[yp1][xm1] + self[yp1][x] + self[yp1][xp1]
      next[y][x] = ((sum==2) and self[y][x]) or ((sum==3) and 1) or 0
      xm1,x,xp1,xi = x,xp1,xp1+1,xi-1
    end
    ym1,y,yp1,yi = y,yp1,yp1+1,yi-1
  end
end

-- output the array to screen
function _CELLS:draw()
  local pixval = { 16, 8, 4, 2, 1 }
  -- reprogram each user-defined character doing each column from left to right
  for charcol = 0, 3 do
    for charrow = 0, 1 do
      local charval = { 0, 0, 0, 0, 0, 0, 0, 0 }
      for pixrow = 1, 8 do
        local rowval = 0  -- value to program into this pixel row of the char
	local y = pixrow + charrow * 8
        for pixcol = 1, 5 do
          local x = pixcol + charcol * 5
          if self[y][x] > 0 then
            rowval = rowval + pixval[pixcol]
          end
        end
        charval[pixrow] = rowval
      end
      mizar32.lcd.definechar(charcol + charrow*4, charval)
    end
  end
end

-- constructor
function CELLS(w,h)
  local c = ARRAY2D(w,h)
  c.spawn = _CELLS.spawn
  c.evolve = _CELLS.evolve
  c.draw = _CELLS.draw
  return c
end

--
-- shapes suitable for use with spawn() above
--
HEART = { 1,0,1,1,0,1,1,1,1; w=3,h=3 }
GLIDER = { 0,0,1,1,0,1,0,1,1; w=3,h=3 }
EXPLODE = { 0,1,0,1,1,1,1,0,1,0,1,0; w=3,h=4 }
FISH = { 0,1,1,1,1,1,0,0,0,1,0,0,0,0,1,1,0,0,1,0; w=5,h=4 }
BUTTERFLY = { 1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,1,0,1,0,1,1,0,0,0,1; w=5,h=5 }

-- the main routine
function LIFE(w,h)
  -- create two arrays
  local thisgen = CELLS(w,h)
  local nextgen = CELLS(w,h)

  -- create some life
  -- about 1000 generations of fun, then a glider steady-state
  thisgen:spawn(GLIDER,5,4)
  thisgen:spawn(EXPLODE,25,10)
  thisgen:spawn(FISH,4,12)

  -- run until break
  local gen=1
  while true do
    thisgen:evolve(nextgen)
    thisgen,nextgen = nextgen,thisgen
    thisgen:draw()
    gen=gen+1
    if gen>2000 then break end
  end
end

-- We do pixel graphics by printing the 8 user-definable characters as two
-- rows fo four characters, then redefining their bitmap on the fly.
-- 0 1 2 3
-- 4 5 6 7
-- and each character is 5 pixels wide by 8 pixels high.

-- First, clear all the user-defined characters
mizar32.lcd.reset()
for c = 0,7 do mizar32.lcd.definechar( c, {} ) end
mizar32.lcd.print(0, 1, 2, 3, " LCD")
mizar32.lcd.goto(2,1)
mizar32.lcd.print(4, 5, 6, 7, " Life")

LIFE(4*5, 2*8)
