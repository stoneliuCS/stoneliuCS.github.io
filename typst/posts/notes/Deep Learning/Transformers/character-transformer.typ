#metadata((
  title: "Bigrams for Natural Language Processing",
  description: "Exploring N-gram Language Models",
  date: "2026-06-27",
  slug: "n-gram-language-model",
)) <post-meta>
#import "../../../../lib/web.typ": aside
#aside[
  Following Ch 2 and 3 of #link("https://web.stanford.edu/~jurafsky/slp3/")[Speech and Language Processing]!
]

== What is a word?
Really and seriously, what is a word? Is a word simple a collection of characters spaced out by spaces? But what about other languages that have really short words like _Chinese_ or words in _Turkish_ that are really long. What about things that we don't really consider words like punctuation, commas, and exclaimations? When we speak we usually put some sort of filler word like _ums_ or _uhs_. When training a language model, we typically don't include these #link("https://en.wikipedia.org/wiki/Filler_(linguistics)")[Fillers]. If we consider the number of words in a language to be $V$ and the number of word instances to be $N$ then their relationship can be found to be
$
  |V| = k N^beta "where" \
  k, beta > 0 "and" 0 < beta < 1
$
The issue here is that some types of words, especially those that are not #link("https://en.wikipedia.org/wiki/Function_word")[_Function Words_] such as nouns tend to grow indefinitely. We can not expect a language model to ever hold the entire vocabulary corpus of a language like this! That is, our model is bound to see words it has never ever seen before, which is an issue when we think of simplistic tokenization algorithms that simply split characters by some sort of delimiter.

=== Morphemes
_Words_ are often composed of morphemes, the smallest possible unit that bears any meaning in a particular language. We typically can distinguish these morphemes into two categories, the *root* and the *affixes*. The _root_ is what gives the primary meaning to the word while the _affixes_ give additional meaning.

=== Unicode
#aside[
  Remember, a _bit_ is just $0$ or $1$. A _byte_ is a collection of $8$ bits. In total that means we have $2^8 = 256$ possible representations in ASCII.
]
We can also tokenize words based on their #link("https://en.wikipedia.org/wiki/Unicode")[_Unicode_] encoding. For english, we represent the latin characters of our language based off of #link("https://en.wikipedia.org/wiki/ASCII")[*ASCII*]. For each character in our alphabet it is given a single byte as its unique representation. This is not going to be sufficient when representing characters in other languages, which is where unicode encodings come into play. We represent the unicode encoding of a character by a hexidecimal number ranging from $0$ to $0 times 1 0 F F F F$.

== Byte Pair Encoding
The _Byte Pair Encoding_ algorithm is as follows:
1. Obtain the set of all unique characters in the training corpus.
2. Check every single _"pair"_ of adjacent characters/words, and finds the pair that occurs the most frequently in the text.
3. Replace all occurrences of most frequent pairs with the new merged token found above.
The algorithm is really quite simple, if we consider the following walkthrough
```
A B C B C A // Start out with the following characters
A BC BC A // Observe that the pair (B,C) are the most frequent so we merge them
... tie breaking and continue merging for some arbitrary constant k.
```

== N-Grams
Simply put, an _n-gram_ is a sequence of $n$ words. What we want to do is to be able to produce a probability distribution of the most likely words to occur proceeding a history of text. That is to predict the $n$th word of a text given that we have observed the $n - 1$  preceeding words. Say for example we wanted to predict the following

$
  "Roses are Red, Violets are _"
$
If we want to be able to know what is the probability of the word _"blue"_ given this history of text, we can formalize it to be
$
  Pr("blue" | "Roses are Red, Violets are")
$
A really simple way to predict this probability _(given a large enough training corpus)_ is to literally count the occurences of this sentence and check also the occurrences of the sentence _"Roses are Red, Violets are Blue"_. This is obviously not feasible with arbitrary sentences, words are _emergent_ and we can easily produce new sentences that likely have never been said in the history of humanity.
