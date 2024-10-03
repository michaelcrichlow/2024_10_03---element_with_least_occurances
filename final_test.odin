package test

import "core:fmt"
print :: fmt.println
printf :: fmt.printf


main :: proc() {

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
