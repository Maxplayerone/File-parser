package main

import "core:fmt"
import "core:os"
import "core:strings"

//changes the letter from uppercase to lower_case
to_lower :: proc(letter: u8) -> u8{
    //if the letter is already uppercase
    if letter > 96 && letter < 123{
        return letter
    }
    //the letter is uppercase
    if letter > 64 && letter < 91{
        return letter + 32
    }
    //it's not even a letter
    return letter
}

//BUG: it accepts if the first part of the word is in listed words so sadness would be ...ness
letter_contained_in_listed_words_first_letter :: proc(letter: u8, keywords: string) -> (bool, string){
    for line in strings.split_lines(keywords){
        if line[0] == letter || line[0] == to_lower(letter){
            return true, line 
        }
    }
    return false, "no"
}

keyword_to_underscores :: proc(str: string) -> string{
    b := strings.builder_make()
    for i in 0..<len(str) - 1{
        if str[i] == ' '{
            strings.write_string(&b, " ")
        }
        else{
            strings.write_string(&b, "_ ")
        }
    }
    strings.write_string(&b, "_")
    return strings.to_string(b)
}

ActiveWord :: struct{
    word_to_match: string,
    cur_word_progress: int,
    starting_index: int,
    wrong: bool,
    debug_size: int,
}

FinishedWord :: struct{
    starting_index: int,
    length: int,
    underscore_thingy: string,
    debug: string,
}

alphabreic ::proc(b: u8) -> bool{
    return b > 64 && b < 91 || b > 96 && b < 123
}

main :: proc(){
    //getting keywords
    bytes_keywords, _ := os.read_entire_file_from_filename("keywords.txt")
    keywords := string(bytes_keywords)
    fmt.println(keywords)

    active_words: [dynamic]ActiveWord
    finished_words: [dynamic]FinishedWord
    bytes, ok := os.read_entire_file_from_filename("input.txt")
    if !ok{
        fmt.println("error reading the file")
        return
    }
    //-------------PARSING----------
    for c, idx in bytes{
        //checking the keywords
        for i in 0..<len(active_words){
            if active_words[i].wrong{
                //fmt.println("removing ", active_words[i])
                //ordered_remove(&active_words, i)
            }
        }
        for i in 0..<len(active_words){
            //fmt.println(active_words[i])

            if active_words[i].word_to_match[active_words[i].cur_word_progress] == c{
                active_words[i].cur_word_progress += 1
                if active_words[i].cur_word_progress == len(active_words[i].word_to_match){
                    fmt.println(active_words[i].word_to_match, " at index ", idx, " is correct")
                    //fmt.println("letter ", bytes[idx])
                    if !alphabreic(bytes[idx + 1]){
                        finished_word := FinishedWord{
                            starting_index = active_words[i].starting_index,
                            length = len(active_words[i].word_to_match),
                            underscore_thingy = keyword_to_underscores(active_words[i].word_to_match),
                            debug = active_words[i].word_to_match,
                        }

                    append(&finished_words, finished_word)
                    }
                    active_words[i].wrong = true
                }
            }
            else{
                fmt.println(active_words[i].word_to_match, " at index ", idx, " is deleted")
                active_words[i].wrong = true
            }


        } 

        //if the letter c matches the first letter of any keyword
        //fmt.println("letter ", rune(c))
        for word in strings.split_lines(keywords){
            if len(word) == 0{
                continue
            }
            word := strings.trim_right(word, "\n")
            if c == word[0] || to_lower(c) == word[0] || c == to_lower(word[0]){
                active_word := ActiveWord{
                    word_to_match = word,
                    cur_word_progress = 1,
                    starting_index = idx, 
                    debug_size = len(word)
                }
                //fmt.println("adding ", active_word)
                append(&active_words, active_word)
            }
        }
    }
    delete(active_words)

    fmt.println("\n")
    //every single keyword we found in the input text
    for word in finished_words{
        fmt.println(word)
    }


    //-----------CHANGING THE KEYWORDS INTO UNDERSCORES----------------------
    output: [dynamic]u8
    bytes_index := 0
    i := 0
    bump_finished_words := false
    bump_value := 0

    for{
        for word in finished_words{
            if i == word.starting_index{

                append(&output, word.underscore_thingy)
                bytes_index += word.length

                bump_finished_words = true
                bump_value = word.length
            }
        }
        if bump_finished_words{
            ordered_remove(&finished_words, 0)
            for i in 0..<len(finished_words){
                finished_words[i].starting_index -= bump_value
            }
            bump_finished_words = false
        }

        append(&output, bytes[bytes_index])
        bytes_index += 1

        i += 1
        if bytes_index >= len(bytes){
            break
        }

    }
    os.write_entire_file("output.txt", output[:])
}