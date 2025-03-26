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

field_t :: [W][H]bool

row_t :: distinct u64


/*
A 1-D u32 array representation of the cell grids. The length of the array is
equivalent to (W / 16) * H, where W and H are compile time known constants
equivalent to the width and height divided by a compile time known tile size
*/
bp_field_t :: [W*H / 32]row_t
// bp_field_t :: [(W / 16) * H]row_t
// bx32_field_t :: [W*H / 32]simd.boolx32


// @(require_results)cet_neighbors_bx32 :: proc(field: ^bx32_field_t, i: int) -> 1
// @(require_results)
// count_neighbors_u32 :: proc(pre, row, post, pos: u32) -> u32 {
// 	count: u32
// 	count += ((pre >> (pos - 1)) & 0b1) + ((pre >> (pos)) & 0b1) + ((pre >> (pos + 1)) & 0b1)
// 	count += ((row >> (pos - 1)) & 0b1) + ((row >> (pos + 1)) & 0b1)
// 	count += ((post >> (pos - 1)) & 0b1) + ((post >> (pos)) & 0b1) + ((post >> (pos + 1)) & 0b1)
// 	return count
// }

/*
A little hack since every half-byte is a cell and 4 bits can represent up to
8 neighbors. Directly sums all neighbors and then returns a 16 u8 array of the
count
*/
count_neighbors_u64 :: #force_inline proc(neighbors: [8]row_t) -> u64 #no_bounds_check {
	count: row_t
	for neighbor in neighbors do count += neighbor
	return cast(u64) count
}

/*
Interpret the u64 count from `count_neighbors_u64` and returns a 16 u8 array
of counts
*/
extract_count_u64 :: proc(count: u64) -> [16]u8 #no_bounds_check {
	counts: [16]u8
	for i := u64(0); i < 16; i += 1 {
		counts[i] = cast(u8)(count >> (4*i)) & 0xF
	}
	return counts
}

// count_neighbors_u64 :: proc(neighbors: [8]row_t) -> (res: [16]u8) {
// 	count: u64
// 	for neighbor in neighbors do count += u64(neighbor)

// 	for  i : u64 = 1; i <= 16; i +=1  {
// 		res[i] = cast(u8)(count >> 4*i) & 0xF
// 	}

// 	return
// }

@(require_results)
get_neighbors_u64 :: proc(field: ^bp_field_t, i: int) -> [8]row_t {
	ROW :: WIDTH / 32
	res : [8]row_t

	res[0] = (field[i - ROW] >> 4) | (field[i - ROW - 1] << 60) // top left
	res[1] = field[i - ROW] // top
	res[2] = (field[i - ROW] << 4) | (field[i - ROW + 1] >> 60) // top right

	res[3] = (field[i] >> 4) | (field[i-1] << 60) // left
	res[4] = (field[i] << 4) | (field[i+1] >> 60) // right

	res[5] = (field[i + ROW] >> 4) | (field[i + ROW - 1] << 60) // bottom left
	res[6] = field[i + ROW] // bottom
	res[7] = (field[i + ROW] << 4) | (field[i + ROW + 1] >> 60) // bottom right

	return res
}
/* @(require_results)
get_neighbors_u64 :: proc(field: ^bp_field_t, i: u64) -> [8]row_t {
	ROW :: W / 32
	res : [8]row_t

	res[0] = (field[i - ROW] >> 4) | (field[i - ROW - 1] << 60) // top left
	res[1] = field[i - ROW] // top
	res[2] = (field[i - ROW] << 4) | (field[i - ROW + 1] >> 60) // top right

	res[3] = (field[i] >> 4) | (field[i-1] << 60) // left
	res[4] = (field[i] >> 4) | (field[i+1] >> 60) // right

	res[5] = (field[i + ROW] >> 4) | (field[i + ROW - 1] << 60) // bottom left
	res[6] = field[i + ROW] // top
	res[7] = (field[i + ROW] << 4) | (field[i + ROW + 1] >> 60) // bottom right

	return res
} */

/* @(require_results)
get_neighbors_u32 :: proc(field: ^bp_field_t, i: u32) -> [8]row_t {
	ROW :: W / 32
	res : [8]row_t
	res[0] = (field[i - ROW] >> 4) | (field[i - ROW - 1] << 28) // top left
	res[1] = field[i - ROW] // top
	res[2] = (field[i - ROW] << 4) | (field[i - ROW + 1] >> 28) // top right

	res[3] = (field[i] >> 4) | (field[i-1] << 28) // left
	res[4] = (field[i] >> 4) | (field[i-1] >> 28) // left

	res[5] = (field[i + ROW] >> 4) | (field[i + ROW - 1] << 28) // bottom left
	res[6] = field[i + ROW] // top
	res[7] = (field[i + ROW] << 4) | (field[i + ROW + 1] >> 28) // bottom right
	return res
} */


// life_cell_bit_packed_u32 :: proc(pre, row, post: u32) -> u32 {

// 	next_row: u32
// 	num_cols :: W / 32

// 	for pos in 1 ..= 30 {
// 		count := count_neighbors_u32(pre, row, post)
// 		alive: bool = ((row >> cast(u32)pos) & 0b1) == 1
// 		if alive {
// 			if count == 2 || count == 3 {
// 				next_row |= 1 << cast(u32)pos
// 			} else {
// 				next_row |= 0 << cast(u32)pos
// 			}
// 		} else {
// 			if count == 3 {
// 				next_row |= 1 << cast(u32)pos
// 			} else {
// 				next_row |= 0 << cast(u32)pos
// 			}
// 		}
// 	}
// 	return next_row
// }

// life_cell_bit_packed_rowt :: proc(pre, row, post: row_t) -> row_t {
// 	return cast(row_t)life_cell_bit_packed_u32(u32(pre), u32(row), u32(post))
// }

// life_cell_bp :: proc {
// 	life_cell_bit_packed_u32,
// 	life_cell_bit_packed_rowt,
// }

// life_cell :: proc {
// 	life_cell_bit_packed_u32,
// 	life_cell_bit_packed_rowt,
// 	life_cell_array,
// }

life_cell_array :: proc(field, new_field: ^field_t, x: int, y: int) {
	count := 0
	for i := x - 1; i < x + 2; i += 1 {
		for j := y - 1; j < y + 2; j += 1 {
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
			life_cell_array(field, new_field, x, y)
		}
	}
}

/*life_grid_bit_packed :: proc(current, next: ^bp_field_t) {
	assert(len(current) == len(next), "length of current and next not equivalent")
	num_cols :: W / 32
	for i in 0 ..< len(current) {
		// disregard vertical edges
		if i < num_cols || i >= H - num_cols {
			continue
		}

		row := current[i]
		pre := current[i - num_cols]
		post := current[i + num_cols]

		switch (i % 16) {
		case 0:
			// disregard left edge
			next[i] = life_cell_bp(pre, row, post, true, false)
		case 15:
			// disregard right edge
			next[i] = life_cell_bp(pre, row, post, false, false)
		case:
			next[i] = life_cell_bp(pre, row, post, false, false)
		}
	}
}*/

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
