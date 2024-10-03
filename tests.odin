package test

import "core:fmt"
import "core:mem"
import "core:slice"
print :: fmt.println
printf :: fmt.printf

DEBUG_MODE :: true

main :: proc() {

	when DEBUG_MODE {
		// tracking allocator
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf(
					"=== %v allocations not freed: context.allocator ===\n",
					len(track.allocation_map),
				)
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf(
					"=== %v incorrect frees: context.allocator ===\n",
					len(track.bad_free_array),
				)
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}

		// tracking temp_allocator
		track_temp: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track_temp, context.temp_allocator)
		context.temp_allocator = mem.tracking_allocator(&track_temp)

		defer {
			if len(track_temp.allocation_map) > 0 {
				fmt.eprintf(
					"=== %v allocations not freed: context.temp_allocator ===\n",
					len(track_temp.allocation_map),
				)
				for _, entry in track_temp.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track_temp.bad_free_array) > 0 {
				fmt.eprintf(
					"=== %v incorrect frees: context.temp_allocator ===\n",
					len(track_temp.bad_free_array),
				)
				for entry in track_temp.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track_temp)
		}
	}

	// main work
	print("Hello from Odin!")
	my_list := [?]int{1, 2, 3, 1, 2, 1, 2, 1, 2}
	print(element_with_least_occurances(my_list[:], context.temp_allocator))

	free_all(context.temp_allocator)

}

element_with_least_occurances :: proc(l: []int, allocator := context.allocator) -> int {
	local_dict := make(map[int]int, allocator = allocator)
	defer delete(local_dict)

	for val in l {
		if val not_in local_dict do local_dict[val] = 1
		else if val in local_dict do local_dict[val] += 1
	}
	key_with_lowest_value := dict_find_lowest_value_and_return_key(local_dict)

	return key_with_lowest_value
}

items :: proc(m: map[$T]T, allocator := context.allocator) -> [dynamic][dynamic]T {
	print("hello there")
	local_array := make([dynamic][dynamic]T, allocator = allocator)
	// don't delete it since you return that local_array

	for key, value in m {
		_items := make([dynamic]T, allocator = allocator)
		append(&_items, key, value)
		append(&local_array, _items)
	}
	return local_array
}

dict_find_lowest_value_and_return_key :: proc(m: map[$T]T) -> int {
	lowest_value: T
	lowest_key: T
	first_pass := true
	for key, value in m {
		if first_pass {
			lowest_key = key
			lowest_value = value
			first_pass = false
		} else {
			if value < lowest_value {
				lowest_key = key
				lowest_value = value
			}
		}
	}
	return lowest_key
}


/*
def element_with_least_occurances(l: list[int]) -> int:
    local_dict = dict()
    for val in l:
        if val not in local_dict:
            local_dict[val] = 1
        elif val in local_dict:
            local_dict[val] += 1

        sorted_list = sorted(local_dict.items(), key=lambda item: item[1])
    return sorted_list[0][0]


def main() -> None:
    print(element_with_least_occurances([1, 2, 3, 1, 2, 1, 2, 1, 2]))


if __name__ == '__main__':
    main()

*/
