package main

import "core:fmt"
import "core:os"
import "core:strings"

keywords: [dynamic]string 
//BUG: it accepts if the first part of the word is in listed words so sadness would be ...ness

letter_contained_in_listed_words_first_letter :: proc(letter: u8) -> (bool, string){
    for word in keywords{
        if word[0] == letter{
            return true, word
        }
    }
    return false, "no"
}

ActiveWord :: struct{
    word_to_match: string,
    cur_word_progress: int,
    indicies: []int
}

alphabreic ::proc(b: u8) -> bool{
    return b > 64 && b < 91 || b > 96 && b < 123
}

main :: proc(){
    //getting keywords
    {
        bytes, ok := os.read_entire_file_from_filename("keywords.txt")
        if !ok{
            fmt.println("cannot open the file keywords.txt")
            return
        }
        buffer: [32]u8
        i := 0
        for b, idx in bytes{
            if b != 10 && b != 13{
                buffer[i] = b
                if idx == len(bytes) -1{
                    str: string = string(buffer[0:i+1])
                    append(&keywords, str)
                }
                i += 1
            }
            else if b == '\n'{
                str: string = string(buffer[0:i])
                new_str := strings.clone(str)
                append(&keywords, new_str)
                delete(new_str)
                i = 0
            }
        }
    }
    active_words: [dynamic]ActiveWord
    bytes, ok := os.read_entire_file_from_filename("input.txt")
    if !ok{
        fmt.println("error reading the file")
        return
    }
    //parsing
    found_indicies: [dynamic]int
    for letter, idx in bytes{
        //fmt.println(letter)
        if len(active_words) == 0{
            ok, word := letter_contained_in_listed_words_first_letter(letter)
            if ok{
                active_word := ActiveWord{
                    word_to_match = word,
                    cur_word_progress = 0,
                    indicies = make([]int, len(word)),
                }
                active_word.indicies[active_word.cur_word_progress] = idx
                active_word.cur_word_progress += 1
                append(&active_words, active_word)
            }
        }
        else{
            for i in 0..<len(active_words){
                if active_words[i].word_to_match[active_words[i].cur_word_progress] == letter{
                    active_words[i].indicies[active_words[i].cur_word_progress] = idx
                    active_words[i].cur_word_progress += 1
                    if active_words[i].cur_word_progress == len(active_words[i].word_to_match){
                        if !alphabreic(bytes[idx+1]){
                            for ii in active_words[i].indicies{
                                append(&found_indicies, ii)
                            }
                        }
                        ordered_remove(&active_words, i)         
                    }
                }
                else{
                    ordered_remove(&active_words, i)         
                }
            }
        }
    }
    delete(active_words)

    new_bytes: [dynamic]u8
    bytes_index := 0 
    i := 0
    added_dot := false
    for{
        for index in found_indicies{
            if index == i{
                append(&new_bytes, "_")
                append(&new_bytes, " ")
                added_dot = true
            }
        }
        if !added_dot{
            append(&new_bytes, bytes[bytes_index])
        }

        added_dot = false 
        bytes_index += 1
        i += 1

        if bytes_index >= len(bytes){
            break
        }
    }
    for index in found_indicies{
        bytes[index] = '.'
    }
    os.write_entire_file("output.txt", new_bytes[:])
    delete(found_indicies)
    delete(new_bytes)
}
