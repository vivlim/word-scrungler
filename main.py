import typer
import editdistance
from english_words import get_english_words_set
from english_dictionary.scripts.read_pickle import get_dict

def find_low_editdistance_words(word: str, allowed_length_delta: int):
    web2lowerset = get_english_words_set(['web2'], lower=True)

    input_word_len = len(word)

    wordlist=list(web2lowerset)

    # filter to words of the appropriate length.
    words_with_length=list(filter(lambda x: input_word_len - allowed_length_delta <= len(x) <= input_word_len + allowed_length_delta, wordlist))
    if allowed_length_delta > 0:
        print(f"Words with length [{input_word_len - allowed_length_delta}, {input_word_len + allowed_length_delta}]: {len(words_with_length)}")
    else:
        print(f"Words with length {input_word_len}: {len(words_with_length)}")

    words_with_editdist=[(x, editdistance.eval(word, x)) for x in words_with_length]

    words_with_editdist.sort(key = lambda x: x[1])
    return words_with_editdist

def main(word: str, max_count: int = 20, max_distance: int = 5, allowed_length_delta: int = 0):
    words = find_low_editdistance_words(word, allowed_length_delta)

    words = list(filter(lambda w: w[1] <= max_distance, words))

    words = words[0:max_count]

    english_dict = get_dict()

    for (word, edit_distance) in words:
        if word in english_dict:
            print(f"'{word}' (distance {edit_distance}){english_dict[word]}")
        else:
            print(f"'{word}' (distance {edit_distance})")


if __name__ == "__main__":
    typer.run(main)