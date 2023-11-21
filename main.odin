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
        for i in 0..<len(line) - 1{
            if line[i] == ' '{
                strings.write_string(&b, " ")
            }
            else{
                strings.write_string(&b, "_ ")
            }
        }
        strings.write_string(&b, "_")
        input, _ = strings.replace_all(input, line, strings.to_string(b))
        //pretty naive and slow way of doing this but whatever
        input, _ = strings.replace_all(input, strings.to_upper_camel_case(line), strings.to_string(b))
    }
    os.write_entire_file("output.txt", transmute([]u8)input)
}