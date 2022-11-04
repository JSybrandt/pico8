pico-8 cartridge // http://www.pico-8.com
version 38
__lua__

_actors = {}

function clear_dead_actors()
	cpy = {}
	for a in all(_actors) do
		if(a:is_alive()) add(cpy, a)
	end
	_actors = cpy
end

function _init()
end

function _update()
	_tick += 1
	cursor:update()

	if(btn(_button_o)) then
		add(_actors, create_projectile(_width/2, _height/2, rnd(10)-5, rnd(10)-5, 3, _red))
	end
	for a in all(_actors) do
		a:update()
	end
	clear_dead_actors()
end

function _draw()
	cls()
	cursor:draw()
	for a in all(_actors) do
		a:draw()
	end
	print(#_actors,0,0,_white)
end
