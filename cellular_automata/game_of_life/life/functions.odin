package life

import "core:c"
import rl "vendor:raylib"

field_t :: [W][H]bool

row_t :: distinct u64

/*
A 1-D u32 array representation of the cell grids. The length of the array is
equivalent to (W / 16) * H, where W and H are compile time known constants
equivalent to the width and height divided by a compile time known tile size
*/
bp_field_t :: [W*H / 32]row_t

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

update_cells_u64 :: proc(current, next: ^bp_field_t, i: int) {
	neighbors := get_neighbors_u64(current, i)	
	count := count_neighbors_u64(neighbors)

	counts := extract_count_u64(count)
	// rule if alive:
	// count == 2 or count == 3 same as
	// (0001 | 0010) or (0001 | 0011) == 3
	// rule if dead:
	// count == 3
	// (0000 | 0011) == 3
	//
	// either way, (cell | count) == 3
	next[i] = (current[i] | cast(row_t)count) & 0x3333_3333_3333_3333
}

life_cell_fieldt :: proc(field, new_field: ^field_t, x: int, y: int) {
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
			life_cell_fieldt(field, new_field, x, y)
		}
	}
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
