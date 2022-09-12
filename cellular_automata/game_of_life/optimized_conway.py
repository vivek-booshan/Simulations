import pygame as pg
from random import randint
from copy import deepcopy
import numpy as np
from numba import njit
RES = WIDTH, HEIGHT = 1500, 900
TILE = 5
W, H = WIDTH // TILE, HEIGHT // TILE
FPS = -1

pg.init()
surface = pg.display.set_mode(RES)
clock = pg.time.Clock()



next_field = np.array([[0 for i in range(W)] for j in range(H)])

# current_field = np.array([[0 for i in range(W)] for j in range(H)])
# for i in range(H):
#     current_field[i][i + (W-H)//2] = 1
#     current_field[H-i-1][i + (W-H)//2] = 1
current_field = np.array([[1 if i == W // 2 or j == H // 2 else 0 for i in range(W)] for j in range(H)])
# current_field = np.array([[randint(0, 1) for i in range(W)] for j in range(H)])
# current_field = np.array([[1 if not i % 9 else 0 for i in range(W)] for j in range(H)]) # 2,5,8,9,10,11,13,18,21,22,26,30,33,65
# current_field = np.array([[1 if not (2 * i + j) % 4 else 0 for i in range(W)] for j in range(H)]) # (2,4),(4,4)
# current_field = np.array([[1 if not (i * j) % 22 else 0 for i in range(W)] for j in range(H)]) # 5,6,9,22,33
# current_field = np.array([[1 if not i % 7 else randint(0, 1) for i in range(W)] for j in range(H)])

# def life(current_field, x, y):
    # count = 0
    # for j in range(y - 1, y + 2):
    #     for i in range(x - 1, x + 2):
    #         if current_field[j][i]:
    #             count += 1

    # if current_field[y][x]:
    #     count -= 1
    #     if count == 2 or count == 3:
    #         return 1
    #     return 0
    # else:
    #     if count == 3:
    #         return 1
    #     return 0

@njit(fastmath=True)
def life(current_field, next_field):
    res = []
    for x in range(1, W-1):
        for y in range(1, H-1):
            count = 0
            for j in range(y-1, y+2):
                for i in range(x-1, x+2):
                    if current_field[j][i] == 1:
                        count += 1
            if current_field[y][x] == 1:
                count -= 1
                if count == 2 or count == 3:
                    next_field[y][x] = 1
                    res.append((x, y))
                else:
                    next_field[y][x] = 0
            else:
                if count == 3:
                    next_field[y][x] = 1
                    res.append((x, y))
                else:
                    next_field[y][x] = 0
    return next_field, res

#life with boundary conditions
@njit(fastmath=True)
def pdbd_life(current_field, next_field):
    res = []
    for x in range(W):
        for y in range(H):
            count = 0
            for j in range(y-1, y+2):
                for i in range(x-1, x+2):
                    if current_field[j%H][i%W] == 1:
                        count += 1
            if current_field[y][x] == 1:
                count -= 1
                if count == 2 or count == 3:
                    next_field[y][x] = 1
                    res.append((x, y))
                else:
                    next_field[y][x] = 0
            else:
                if count == 3:
                    next_field[y][x] = 1
                    res.append((x, y))
                else:
                    next_field[y][x] = 0
    return next_field, res

while True:

    surface.fill(pg.Color('black'))
    for event in pg.event.get():
        if event.type == pg.QUIT:
            exit()
    
    next_field, res = pdbd_life(current_field, next_field)
    # next_field, res = life(current_field, next_field)
    tuple(pg.draw.rect(surface, pg.Color('antiquewhite'), 
        (x*TILE + 1, y*TILE + 1, TILE-1, TILE-1)) for x, y in res)
    current_field = deepcopy(next_field)

    print(clock.get_fps())
    pg.display.flip()
    clock.tick(FPS)

