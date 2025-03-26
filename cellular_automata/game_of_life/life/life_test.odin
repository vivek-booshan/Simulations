package life

import "core:log"
import "core:testing"

// @(test)
// bitpacked_sum :: proc(t: ^testing.T) {
// 	bp_field: bp_field_t
// 	bp_field[0] = 0b00100101
// 	bp_field[1] = 0b01100101
// 	bp_field[2] = 0b00110101

// 	pre_row := cast(u32)bp_field[0]
// 	row := cast(u32)bp_field[1]
// 	post_row := cast(u32)bp_field[2]

// 	pos: u32 = 7
// 	count := neighbors(pre_row, row, post_row, pos)
// 	testing.expect_value(t, count, 1)

// 	pos = 6
// 	count = neighbors(pre_row, row, post_row, pos)
// 	testing.expect_value(t, count, 3)

// 	pos = 5
// 	count = neighbors(pre_row, row, post_row, pos)
// 	testing.expect_value(t, count, 4)

// }

/*
checks a single step for the bit packed grid but does not handle the left and right most u32 bit cases
```odin
package main

import "core:fmt"

main :: proc() {
	fmt.println("Hellope!")
}
```
*/

// @(test)
/*
bitpacked_life_single_step :: proc(t: ^testing.T) {
	field: bp_field_t
	field[1]  = 0b00100101
	field[17] = 0b01100101
	field[33] = 0b00110101

	next_field: bp_field_t
	next_field[17] = life_cell_bit_packed_rowt(field[1], field[17], field[33])

	testing.expectf(
		t,
		next_field[17] == 0b01000100,
		"expected %b got %b",
		0b01000100,
		next_field[17],
	)
}
*/

// @(test)
/* bitpacked_life_single_step_full :: proc(t: ^testing.T) {
	field: bp_field_t
	CENTER      :: 17
	TOPLEFT     :: CENTER - 16 - 1
	TOP         :: CENTER - 16
	TOPRIGHT    :: CENTER - 16 + 1

	LEFT        :: CENTER - 1
	RIGHT       :: CENTER + 1

	BOTTOMLEFT  :: CENTER + 16 - 1
	BOTTOM      :: CENTER + 16
	BOTTOMRIGHT :: CENTER + 16 + 1

	field[CENTER]      = 0b01100101

	field[TOPLEFT]     = 0b10011010
	field[TOP]         = 0b00100101
	field[TOPRIGHT]

	field[LEFT]        = 0b0000001
	field[RIGHT]       = 0b01011111

	field[BOTTOMLEFT]
	field[BOTTOM]      = 0b00110101
	field[BOTTOMRIGHT] = 0b01101101

	next_field: bp_field_t
	// next_field[center] = life_cell_bit_packed_rowt(field[1], field[17], field[33])

	// testing.expectf(
	// 	t,
	// 	next_field[17] == 0b01000100,
	// 	"expected %b got %b",
	// 	0b01000100,
	// 	next_field[17],
	// )
} */

@(test)
count_neighbors_u64_test :: proc(t: ^testing.T) {

	topleft     : row_t : 0b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001
	top         : row_t : 0b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000
	topright    : row_t : 0b0000_0000_0001_0000_0001_0001_0001_0000_0001_0000_0001_0001_0000

	left        : row_t : 0b0001_0001_0001_0001_0001_0001_0000_0000_0000_0001_0000_0000_0001
	// center      : row_t : 0b0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001
	right       : row_t : 0b0001_0001_0000_0000_0001_0000_0001_0001_0001_0001_0001_0000_0001

	bottomleft  : row_t : 0b0000_0001_0001_0001_0000_0001_0000_0000_0000_0000_0000_0001_0000
	bottom      : row_t : 0b0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000
	bottomright : row_t : 0b0001_0000_0001_0001_0001_0001_0000_0000_0001_0001_0001_0001_0000

	neighbors :: [8]row_t{ topleft, top, topright, left, right, bottomleft, bottom, bottomright }

	count := count_neighbors_u64(neighbors)
	expected_count : u64 : 0b0101_0110_0110_0110_0110_0111_0101_0011_0110_0101_0101_0101_0011
	testing.expectf(
		t,
		count == expected_count,
		"\nexp %b\ngot %b",
		expected_count,
		count
	)
	
}

@(test)
extract_count_u64_test :: proc(t: ^testing.T) {
	topleft     : row_t : 0b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001
	top         : row_t : 0b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000
	topright    : row_t : 0b0000_0000_0001_0000_0001_0001_0001_0000_0001_0000_0001_0001_0000

	left        : row_t : 0b0001_0001_0001_0001_0001_0001_0000_0000_0000_0001_0000_0000_0001
	// center      : row_t : 0b0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001
	right       : row_t : 0b0001_0001_0000_0000_0001_0000_0001_0001_0001_0001_0001_0000_0001

	bottomleft  : row_t : 0b0000_0001_0001_0001_0000_0001_0000_0000_0000_0000_0000_0001_0000
	bottom      : row_t : 0b0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000
	bottomright : row_t : 0b0001_0000_0001_0001_0001_0001_0000_0000_0001_0001_0001_0001_0000

	neighbors :: [8]row_t{ topleft, top, topright, left, right, bottomleft, bottom, bottomright }

	count := count_neighbors_u64(neighbors)
	expected_counts :: [16]u8{3, 5, 5, 5, 6, 3, 5, 7, 6, 6, 6, 6, 5, 0, 0, 0}
 	counts := extract_count_u64(count)
	testing.expectf(
		t,
		counts == expected_counts,
		"\nexp %d\ngot %d",
		expected_counts,
		counts
	)
}

@(test)
get_neighbors_u64_test :: proc(t: ^testing.T) {
	field: bp_field_t		
	topleft     : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001
	top         : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000
	topright    : row_t : 0b0000_0000_0000_0000_0000_0001_0000_0001_0001_0001_0000_0001_0000_0001_0001_0000

	left        : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0000_0000_0000_0001_0000_0000_0001
	center      : row_t : 0b0000_0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001
	right       : row_t : 0b0000_0000_0000_0001_0001_0000_0000_0001_0000_0001_0001_0001_0001_0001_0000_0001

	bottomleft  : row_t : 0b0000_0000_0000_0000_0001_0001_0001_0000_0001_0000_0000_0000_0000_0000_0001_0000
	bottom      : row_t : 0b0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000
	bottomright : row_t : 0b0000_0000_0000_0001_0000_0001_0001_0001_0001_0000_0000_0001_0001_0001_0001_0000

	field[17] = center

	field[16] = left
	field[18] = right

	field[0]  = topleft
	field[1]  = top
	field[2]  = topright

	field[32] = bottomleft
	field[33] = bottom
	field[34] = bottomright

	neighbors := get_neighbors_u64(&field, 17)

	testing.expect_value(t, (field[1] >> 4)  | (field[0] << 60),  0b0001_0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001)
	testing.expect_value(t, (field[1]),                           0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000)
	testing.expect_value(t, (field[1] << 4)  | (field[2] >> 60),  0b0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000_0000)

	testing.expect_value(t, (field[17] >> 4) | (field[16] << 60), 0b0001_0000_0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000)
	testing.expect_value(t, (field[17] << 4) | (field[18] >> 60), 0b0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001_0000)

	testing.expect_value(t, (field[33] >> 4) | (field[34] << 60), 0b0000_0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000)
	testing.expect_value(t, (field[33]),                          0b0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000)
	testing.expect_value(t, (field[33] << 4) | (field[34] >> 60), 0b0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000_0000)

	testing.expect_value(t, neighbors[0], 0b0001_0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001)
	testing.expect_value(t, neighbors[1], 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000)
	testing.expect_value(t, neighbors[2], 0b0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000_0000)

	testing.expect_value(t, neighbors[3], 0b0001_0000_0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000)
	testing.expect_value(t, neighbors[4], 0b0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001_0000)

	testing.expect_value(t, neighbors[5], 0b0000_0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000)
	testing.expect_value(t, neighbors[6], 0b0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000)
	testing.expect_value(t, neighbors[7], 0b0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000_0000)
}

@(test)
update_cell_u64_test :: proc(t: ^testing.T) {
	current: bp_field_t		
	next: bp_field_t
	topleft     : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001
	top         : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000
	topright    : row_t : 0b0000_0000_0000_0000_0000_0001_0000_0001_0001_0001_0000_0001_0000_0001_0001_0000

	left        : row_t : 0b0000_0000_0000_0001_0001_0001_0001_0001_0001_0000_0000_0000_0001_0000_0000_0001
	center      : row_t : 0b0000_0000_0000_0001_0001_0001_0000_0000_0000_0000_0001_0000_0001_0000_0000_0001
	right       : row_t : 0b0000_0000_0000_0001_0001_0000_0000_0001_0000_0001_0001_0001_0001_0001_0000_0001

	bottomleft  : row_t : 0b0000_0000_0000_0000_0001_0001_0001_0000_0001_0000_0000_0000_0000_0000_0001_0000
	bottom      : row_t : 0b0000_0000_0000_0000_0001_0000_0001_0000_0001_0001_0000_0001_0000_0000_0000_0000
	bottomright : row_t : 0b0000_0000_0000_0001_0000_0001_0001_0001_0001_0000_0000_0001_0001_0001_0001_0000

	current[17] = center

	current[16] = left
	current[18] = right

	current[0]  = topleft
	current[1]  = top
	current[2]  = topright

	current[32] = bottomleft
	current[33] = bottom
	current[34] = bottomright

	neighbors := get_neighbors_u64(&current, 17)
	count := cast(row_t)count_neighbors_u64(neighbors)
	log.infof("count:            %b", count)
	counts := extract_count_u64(cast(u64)count)
	log.infof("current:          %b", center)
	log.info(counts)
	corcount := (current[17] | count)
	update := corcount ~ 0x3333_3333_3333_3333
	log.infof("current | count = %b", corcount)
	log.infof("update =          %b", update)
	next[17] = ~update
	// update_cells_u64(&current, &next, 17)
	testing.expect_value(t, next[17], 0x1000_0000_0000_0000)
}
