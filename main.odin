package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc(){
    bytes_keywords, _ := os.read_entire_file_from_filename("keywords.txt")
    bytes, _ := os.read_entire_file_from_filename("input.txt")
    keywords := string(bytes_keywords)
    input := string(bytes)
    for line in strings.split_lines(keywords){
        b := strings.builder_make()
        for _ in 0..<len(line) - 1{
            strings.write_string(&b, "_ ")
        }
        strings.write_string(&b, "_")
        input, _ = strings.replace_all(input, line, strings.to_string(b))
    }
    os.write_entire_file("output.txt", transmute([]u8)input)
}