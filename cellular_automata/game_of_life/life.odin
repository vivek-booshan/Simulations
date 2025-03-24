package life

import "core:c"
import "core:fmt"
import "core:testing"
// import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

WIDTH :: 1200
HEIGHT :: 800
TILE :: 5

W :: WIDTH / TILE
H :: HEIGHT / TILE

// TILE :: 5
// S :: 3
// W :: S
// H :: S
// WIDTH :: TILE * S
// HEIGHT :: TILE * S


field_t :: [W][H]bool

life_cell :: proc(field, new_field: ^field_t, x: int, y: int) {
	count := 0
	for j := y - 1; j < y + 2; j += 1 {
		for i := x - 1; i < x + 2; i += 1 {
			if field[i][j] {
				count += 1
			}

		}
	}
	if field[x][y] {
		count -= 1
		if count == 2 || count == 3 {
			new_field[x][y] = true
		} else {
			new_field[x][y] = false
		}
	} else {
		if count == 3 {
			new_field[x][y] = true
		} else {
			new_field[x][y] = false
		}
	}
}

life_grid :: proc(field, new_field: ^field_t) {
	for x := 1; x < W - 1; x += 1 {
		for y := 1; y < H - 1; y += 1 {
			life_cell(field, new_field, x, y)
		}
	}
}

life_grid2 :: proc(field: ^field_t) -> field_t {
	next_field: field_t = {}
	for x := 1; x < W - 1; x += 1 {
		for y := 1; y < H - 1; y += 1 {
			life_cell(field, &next_field, x, y)
		}
	}

	return next_field
}


life :: proc {
	life_cell,
	life_grid,
}

isequal :: proc(a, b: field_t) -> bool {
	for i := 0; i < W; i += 1 {
		for j := 0; j < H; j += 1 {
			if a[i][j] != b[i][j] {
				return false
			}
		}
	}
	return true
}

deepcopy :: proc(a: field_t) -> field_t {
	b: field_t
	for i := 0; i < W; i += 1 {
		for j := 0; j < H; j += 1 {
			b[i][j] = a[i][j]
		}
	}
	return b
}

display :: proc(field: field_t, TILE: $int, color: rl.Color) {
	for i := 0; i < W; i += 1 {
		for j := 0; j < H; j += 1 {
			if field[i][j] {
				rl.DrawRectangle(c.int(i * TILE), c.int(j * TILE), c.int(TILE), c.int(TILE), color)
			}
		}
	}
}

main :: proc() {
	next_field: field_t
	current_field: field_t

	for j: c.int = 0; j < H; j += 1 {
		for i: c.int = 0; i < W; i += 1 {
			// current_field[i][j] = rand.int31() % 2 == 0 // random
			// current_field[i][j] = (i % 9) == 0 // straight lines
			// current_field[i][j] = ((2 * i + j) % 4) == 0 // horizontal  lines
			// current_field[i][j] = ((i * j) % 22) == 0 // some grid thingy
			// current_field[i][j] = ((i + j) % 2 == 0) // checkerboard
		}
	}
	init_field := current_field
	// next_field = life_grid2(&current_field)
	rl.InitWindow(WIDTH, HEIGHT, "Conway's Game of Life")
	defer rl.CloseWindow()
	// rl.SetTargetFPS(15)
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		next_field = life_grid2(&current_field)
		display(current_field, TILE, rl.WHITE)
		current_field = deepcopy(next_field)
		rl.DrawFPS(900, 0)
		rl.EndDrawing()
	}

}
