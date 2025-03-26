package life

import "core:c"
import "core:fmt"
import "core:simd"
import "core:math/rand"
import rl "vendor:raylib"

WIDTH :: 512
HEIGHT :: 512
TILE :: 2
W :: WIDTH / TILE
H :: HEIGHT / TILE

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

main :: proc() {
	next_field: field_t
	current_field: field_t

	for j: c.int = 0; j < H; j += 1 {
		for i: c.int = 0; i < W; i += 1 {
			// current_field[i][j] = rand.int31() % 2 == 0 // random
			// current_field[i][j] = (i % 9) == 0 // straight lines
			current_field[i][j] = ((2 * i + j) % 4) == 0 // horizontal  lines
			// current_field[i][j] = ((i * j) % 22) == 0 // some grid thingy
			// current_field[i][j] = ((i + j) % 2 == 0) // checkerboard
		}
	}

	rl.InitWindow(WIDTH, HEIGHT, "Conway's Game of Life")
	defer rl.CloseWindow()
	// rl.SetTargetFPS(300)
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		life_grid(&current_field, &next_field)
		display(current_field, TILE, rl.WHITE)
		current_field = next_field
		rl.DrawFPS(0, 0)

		rl.EndDrawing()
	}

}
