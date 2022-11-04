pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

cursor = {}
cursor.x = _width/2
cursor.y = _height/2
cursor._sprite_start = 0
cursor._sprite_end= 8

function cursor:draw()
	i = (t()*5) % (self._sprite_end - self._sprite_start)
	spr(i, self.x, self.y)
end

function cursor:update()
	if(btn(_left)) self.x-=1
	if(btn(_right)) self.x+=1
	if(btn(_up)) self.y-=1
	if(btn(_down)) self.y+=1
end
