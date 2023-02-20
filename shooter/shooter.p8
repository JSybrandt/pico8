pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
#include utils/debug.p8
#include utils/constants.p8
#include utils/v2.p8
#include utils/rnd.p8
#include utils/helpers.p8
#include utils/aabb.p8
#include utils/periodic.p8
#include utils/actor.p8
#include utils/spr_actor.p8
#include utils/collisions.p8

#include tools/step_lists.p8

#include game_constants.p8
#include bullet.p8
#include trajectories.p8
#include enemy.p8
#include waves.p8
#include player.p8
#include main.p8

__gfx__
000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000550000bccccb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000577500bc6666cb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000777700bc6cc6cb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700005777750bc6cc6cb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070005577550bc6666cb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550bccccb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000050050000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
