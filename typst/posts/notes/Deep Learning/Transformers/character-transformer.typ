#metadata((
  title: "Bigrams for Natural Language Processing",
  description: "Exploring N-gram Language Models",
  date: "2026-06-27",
  slug: "n-gram-language-model",
)) <post-meta>
#import "../../../../lib/web.typ": aside, update
#aside[
  Following Ch 2 and 3 of #link("https://web.stanford.edu/~jurafsky/slp3/")[Speech and Language Processing]!
]

== What is a word?
Really and seriously, what is a word? Are words simply a collection of characters spaced out by spaces/seperators? But what about other languages that have really short words like _Chinese_ or words in _Turkish_ that are really long. What about things that we don't really consider are words like punctuation, commas, and exclaimations? When we speak we usually put some sort of filler word like _ums_ or _uhs_. When training a language model, we typically don't include these #link("https://en.wikipedia.org/wiki/Filler_(linguistics)")[Fillers]. If we consider the number of words in a language $V$ and the number of word instances to be $N$ then their relationship can be found to be
#aside[
  Word instances are the _unique_ words found in a corpus.
]
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
A really simple way to predict this probability _(given a large enough training corpus)_ is to literally count the occurences of this sentence and check also the occurrences of the sentence _"Roses are Red, Violets are Blue"_. This is obviously not feasible with arbitrary sentences, words are _emergent_ and we can easily produce new sentences that likely have never been said in the history of humanity if we so choose to.
#update(date: "June 30th, 2026")[
  I have finished a small tangent exploring a problem _aggressive cows_... I am back!
]
Picking back up where we left off, we can represent a sequence of $n$ words as just $w_1 dots w_n$. We can represent the probability of a particular word _(in this case "the")_ in a sequence of words occurring to be $Pr(X_i = "the")$. Naturally it follows that the joint probability of a sequence of words is to be represented as such...
$
  Pr(X_1 = w_1, X_2 = w_2, dots, X_n = w_n)
$
There are a few ways to compute this probability, but neither are really appealing. The chain rule of probability involves computing a bunch of conditional probabilities together which isn't very practical. We can however make an assumption to give an approximate probability. That is we can assume the _markov assumption_. That is, instead of computing this monstrosity:
$
  Pr(X_n | X_(1 : n - 1)) = Pr("blue" | "Roses are Red, Violets are")
$
We can approximate it by assuming that each word in the sequence only depends only the previous word.
$
  Pr(X_n | X_(1 : n - 1)) approx Pr(X_n | X_(n - 1)) = Pr("blue" | "are")
$
== Maximum Likelihood Estimation
An intuitive way to compute the probabilities of words from a _n-gram_ language model is to use #link("https://en.wikipedia.org/wiki/Maximum_likelihood_estimation")[maximum likelihood estimation]. To compute the probability of a particular word given a word before it $Pr(w_n | w_(n-1))$ we simply take that sequence $w_(n-1) w_n$ and then ask what are the counts in our corpus that match this word sequence exactly $w_(n-1) w_n$ vs what is the count of our words that match $w_(n-1) w$ for any word $w$ proceeding $w_(n-1)$. That is to say
$
  Pr(w_n | w_(n - 1)) = frac(C(w_(n-1) w_n), sum_w C(w_(n - 1) w))
$
The book postulates that
$
  sum_w C(w_(n - 1) w) = C(w_(n-1))
$
In other words, if we sum all the bigrams that start with the word $w_(n-1)$ in a corpus, it must be equal to the occurrences of $w_(n-1)$ in our corpus.

For this particular implementation of the bigram, I will be training a _bigram_ language model on my website corpus. As I am currently writing the top $10$ words and their occurrences are as follows...

#figure(
  table(
    columns: 11,
    align: (
      left,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
    ),
    stroke: none,
    [],
    [*the*],
    [*of*],
    [*a*],
    [*to*],
    [*is*],
    [*we*],
    [*that*],
    [*and*],
    [*x*],
    [*in*],

    [*the*], [1], [2], [0], [0], [0], [0], [0], [0], [1], [1],
    [*of*], [86], [0], [22], [0], [0], [0], [1], [1], [2], [0],
    [*a*], [0], [0], [1], [2], [0], [0], [0], [0], [2], [0],
    [*to*], [31], [0], [11], [1], [2], [1], [1], [0], [0], [0],
    [*is*], [23], [2], [16], [18], [0], [4], [10], [0], [1], [2],
    [*we*], [0], [0], [0], [0], [0], [0], [3], [0], [0], [0],
    [*that*], [15], [2], [0], [1], [10], [17], [0], [0], [0], [2],
    [*and*], [8], [1], [3], [0], [0], [2], [2], [0], [2], [0],
    [*x*], [1], [0], [2], [0], [2], [2], [0], [3], [6], [3],
    [*in*], [41], [0], [11], [0], [0], [0], [0], [1], [0], [0],
  ),
)

Using this table, we can easily compute the conditional probabilities for any sequence $w_(n-1) w_n$ found in our training sequence. For example:
$
  Pr("that we") = frac(C("that we"), C("that")) approx 0.11
$

#figure(
  table(
    columns: 11,
    align: (
      left,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
      right,
    ),
    stroke: none,
    [],
    [*the*],
    [*of*],
    [*a*],
    [*to*],
    [*is*],
    [*we*],
    [*that*],
    [*and*],
    [*x*],
    [*in*],

    [*the*],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],

    [*of*],
    [0.29],
    [0.00],
    [0.07],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.01],
    [0.00],

    [*a*],
    [0.00],
    [0.00],
    [0.00],
    [0.01],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.01],
    [0.00],

    [*to*],
    [0.12],
    [0.00],
    [0.04],
    [0.00],
    [0.01],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],

    [*is*],
    [0.11],
    [0.01],
    [0.08],
    [0.09],
    [0.00],
    [0.02],
    [0.05],
    [0.00],
    [0.00],
    [0.01],

    [*we*],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.02],
    [0.00],
    [0.00],
    [0.00],

    [*that*],
    [0.08],
    [0.01],
    [0.00],
    [0.01],
    [0.06],
    [0.11],
    [0.00],
    [0.01],
    [0.00],
    [0.01],

    [*and*],
    [0.05],
    [0.01],
    [0.02],
    [0.00],
    [0.00],
    [0.01],
    [0.01],
    [0.00],
    [0.03],
    [0.00],

    [*x*],
    [0.01],
    [0.00],
    [0.01],
    [0.00],
    [0.01],
    [0.01],
    [0.00],
    [0.02],
    [0.04],
    [0.03],

    [*in*],
    [0.29],
    [0.00],
    [0.08],
    [0.00],
    [0.00],
    [0.00],
    [0.00],
    [0.01],
    [0.00],
    [0.00],
  ),
)
