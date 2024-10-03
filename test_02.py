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
