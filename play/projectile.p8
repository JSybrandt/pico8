pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

function create_projectile(pos_x, pos_y, vel_x, vel_y, rad, color)
	p = {}
	p.x = pos_x
	p.y = pos_y
	p.vel_x = vel_x
	p.vel_y = vel_y
	p.rad = rad
	p.color = color
	function p:draw()
		circfill(self.x, self.y, self.rad, self.color)
	end
	function p:update()
		self.x += self.vel_x
		self.y += self.vel_y
	end
	function p:is_alive()
		return self.x > 0 and self.x < _width and self.y > 0 and self.y < _height
	end
	return p
end
