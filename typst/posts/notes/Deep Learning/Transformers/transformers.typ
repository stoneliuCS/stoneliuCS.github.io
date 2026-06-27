#metadata((
  title: "What are Transformers?",
  description: "Is attention all you really need?",
  date: "2026-06-25",
)) <post-meta>

#import "@preview/cetz:0.5.2"
#import "../../../../lib/web.typ": aside, bookmark, link-post, toc

To quote *3Blue1Brown*, a transformer is a just a very specific type of _neural network (Deep Learning)_. When prompting a _Large Language Model_, it will attempt to find the token that is most likely to occur to finish the sentence. Machine Learning is a very flexible approach to building a function, it doesn't require a specific set of procedures _(snippets of code)_ to produce an output, instead it has a bunch of *tunable parameters*. I interpret these to be the weights and biases for a deep learning model. In the case of #link("/2026/06/22/Spam-or-Ham.html")[supervised learning], we feed the network a bunch of inputs and their corresponding _correct_ outputs and use an algorithm called #link("/2026/06/17/Building-a-Neural-Network-from-scratch-in-Go.html#backpropogation")[backpropogation] to tune the weights and biases in such a way that the deep learning model can gradually minimize the error of its predictions.

== Tokenization and Embeddings
Say we want to process a chunk of text like this
$
  "Today I want to be able to eat _"
$
The first thing we want to do is break up these words, a process known as tokenization and then create #link("https://en.wikipedia.org/wiki/Embedding_(machine_learning)")[vector embeddings] from them. Vector Embeddings are ways to preserve the semantic meanings of each token in a higher dimensional #link("https://en.wikipedia.org/wiki/Vector_space")[vector space]. To get a feel for how vector embeddings work, we can play around with a local embedding model and see what happens when we add or subtract specific words. Adding two vectors and finding the nearest vectors of the resulting sum should combine the semantic meaning of each
```bash
# E("Water") + E("Ship")
$ python3 transformer.py

[('vessel', 0.8715493083000183),
('sea', 0.8330526351928711),
('boat', 0.8327040672302246),
('ocean', 0.8029822111129761),
('ships', 0.8028886914253235),
('vessels', 0.7998801469802856),
('boats', 0.7984598278999329),
('waters', 0.7883374094963074)]
```
We get words that are sort of semanatically similar to them. But how does this even work? The current model that I am using represents each vector embedding in a $50$ dimensional space which is of course impossible to visualize. But we can get a sense _geometrically_ with the #link("https://en.wikipedia.org/wiki/Dot_product")[dot product]. Remember, the dot product of two vectors encodes a sense of _directionality_ between them. If two vectors are facing the same direction then their dot product will be positive, if they are perpendicular then their dot product would be close to or equal to zero.

#figure(grid(
  columns: 3,
  gutter: 1.5cm,
  cetz.canvas({
    import cetz.draw: *

    line((0, 0), (5, 0))
    line((0, 0), (0, 3))

    stroke(1pt)

    line((0, 0), (1, 2), mark: (end: ">"))
    line((0, 0), (2, 0.5), mark: (end: ">"))

    content((3, 1.5), [Positive Dot Product])
  }),

  cetz.canvas({
    import cetz.draw: *

    line((0, 0), (5, 0))
    line((0, 0), (0, 3))

    stroke(1pt)

    line((0, 0), (1.5, 0.4), mark: (end: ">"))
    line((0, 0), (-1.5, 0.25), mark: (end: ">"))

    content((3, 1.5), [Negative Dot Product])
  }),

  cetz.canvas({
    import cetz.draw: *

    line((0, 0), (5, 0))
    line((0, 0), (0, 3))

    stroke(1pt)

    line((0, 0), (2.5, 1), mark: (end: ">"))
    line((0, 0), (-1, 2.5), mark: (end: ">"))

    content((3, 1.5), [Zero Dot Product])
  }),
))


If they are facing opposite directions their dot product would be negative. Take for example the embeddings for the words _"sushi", "japan", "germany"_. What would happen if we were to say take their dot products? Well sushi is from japan and not from germany so I would assume that in this $50$ dimensional space encoding the semantics of each word, the dot product between "sushi" and "japan" would be greater than "germany" and "sushi".
```bash
python3 transformer.py # E(Sushi) * E(Germany)
-0.038159132
python3 transformer.py # E(Sushi) * E(Japan)
6.0519114
```
The same goes with addition and subtraction of these embedding vectors in this higher dimensional vector space. If two vectors are pointing in the same direction, then adding them should produce a vector further along that direction. This is why in the example above we see that adding the words "water" and "ship" produce embeddings very similar to those words contextually.

It's important to note that higher dimensional vector spaces are capable of encoding more and more information than merely the representation of the word in a vacuum. It can encode _context_ surrounding the word, like how we interpret the meanings of specific words in a sentence differently depending on its relation, position, and meaning when reading a book or talking to someone.

=== Input Encodings and Positional Encodings
When we first process the text above, we merely take each of its vector embeddings in isolation from the model's vocabulary. Essentially each of these vectors represent the model's current understanding of the word in isolation. That is, no context surrounding each of the word or anything. When implementing my transformer, I want to seperate it out into _tokenizer_, _embeddings_, and then _positional encoding_.

The formula for positional encoding depends on the position of the token with respect to the sequence and also the even/oddness of the encodings in the vector embeddings.

$
  P_(2i)(p) = sin(frac(p, 10000^(frac(2i, 50))))
$

$
  P_(2i + 1)(p) = cos(frac(p, 10000^(frac(2i, 50))))
$


```python
def tokenize(prompt) -> list[str]:
    words = prompt.split()
    return words

def embed(tokens, embedding_model):
    embeddings = []
    for token in tokens:
        embeddings.append(embedding_model[token])
    return np.array(embeddings)

def positional_encoding(tokens):
    def pe(pos, i):
        exponent = 2 * (i // 2) / EMBEDDING_DIMENSION
        if i % 2 == 0:
            return np.sin(pos / (10000 ** exponent))
        else:
            return np.cos(pos / (10000 ** exponent))

    positional_encodings = []
    for pos in range(len(tokens)):
        position_encoding = []
        for i in range(EMBEDDING_DIMENSION):
            position_encoding.append(pe(pos, i))
        positional_encodings.append(np.array(position_encoding))
    return np.array(positional_encodings)
```
The goal of the entire network is to enable the model to _tweak_ and _tune_ its parameters so that each vector embedding can soak up and internalize the context surrounding each word in addition to its meaning! That is when predicting the next token, it is to be able to assign a probability to each word in the model's vocabulary and then take the highest probability token and append it on to its response. How do we actually get these probabilities? Well we use something called a #link("https://en.wikipedia.org/wiki/Softmax_function")[softmax] to normalize all the output of every single number in the resultant vector to a real number between $0,1$ such that they all add up to $1$. The process is very elegant, consider an arbitrary vector of real numbers

$
  x_i in RR,
  vec(x_1, x_2, x_3, dots.v, x_n) -->^(e^(x_i)) vec(e^(x_1), e^(x_2), e^(x_3), dots.v, e^(x_n)) -->^(frac(e^(x_i), sum_i e^(x_i))) vec(
    frac(e^(x_1), sum_(i) e^(x_i)),
    frac(e^(x_2), sum_(i) e^(x_i)),
    frac(e^(x_3), sum_(i) e^(x_i)),
    dots.v,
    frac(e^(x_n), sum_(i) e^(x_i)),
  )
$

== Attention
#aside[
  For simplicity, I am going to use a very simple tokenization algorithm that just splits the sentence by spaces.
]
When we first prompt a message, each word/token of the prompt merely encodes the surface level definition of the models vocabulary. Take for example the context of _"buck"_.

- It will cost you a _"buck"_!
- I saw a really beautiful _"buck"_ on my hike up the mountain yesterday!

The embeddings are the same for the word _"buck"_ in each (For my specific embedding model)
```
[-0.67531    0.10425    0.33199   -0.17162    0.46126    0.13706
 -1.16      -0.0031324 -0.21076   -0.084427  -0.52776    0.90209
 -0.095148   0.028555   0.2243    -0.23107    0.81729    0.049866
 -0.51744   -0.41996   -0.15688   -0.45597    0.25738   -0.24272
  0.43153   -0.78803   -0.26952   -0.11614    0.36117   -0.88136
  1.0305    -0.15528    0.15564    0.16281   -0.066141  -0.054714
 -0.10931   -0.37815    0.63336   -0.24165   -0.44231    0.44146
 -0.9849    -0.061133   0.28721   -0.59582   -0.080311  -0.65274
 -0.25996    1.1327]
```
If we call the first prompt $p_1$, then we have a matrix of size $6 times 50$, where each _row_ corresponds to a word in the original prompt and each entry is the embeddings in the space $RR^50$. After calculating the positional encodings for each token we add those encodings as well onto the matrix.

```python
def predict(prompt: str, embedding_model) -> str:
    tokens = tokenize(prompt)
    embeddings = embed(tokens, embedding_model)
    positional_encodings = positional_encoding(tokens)
    model_input = embeddings + positional_encodings
    ...
```

Now we want to compute a _query_ vector, this vector encodes the context of the words in _front_ of the word. Essentially what we want is to take our embedding matrix $E$ and multiply it through a learned query weight matrix $W_Q$ to produce a query matrix $Q = E W_Q$
$
  underbrace(
    mat(
      delim: "[",
      e_(1,1), e_(1,2), dots.h, e_(1,50);
      e_(2,1), e_(2,2), dots.h, e_(2,50);
      dots.v, dots.v, dots.down, dots.v;
      e_(6,1), e_(6,2), dots.h, e_(6,50);
    ),
    E " " (6 times 50),
  )
  underbrace(
    mat(
      delim: "[",
      w_(1,1), w_(1,2), dots.h, w_(1,128);
      w_(2,1), w_(2,2), dots.h, w_(2,128);
      dots.v, dots.v, dots.down, dots.v;
      w_(50,1), w_(50,2), dots.h, w_(50,128);
    ),
    W_Q " " (50 times 128),
  )
  =
  underbrace(
    mat(
      delim: "[",
      q_(1,1), dots.h, q_(1,128);
      dots.v, dots.down, dots.v;
      q_(6,1), dots.h, q_(6,128);
    ),
    Q " " (6 times 128),
  )
$
The output dimensions of the query are seemingly arbitrary, I have settled on $128$ but you can choose anything that you deem appropriate. Similarily we will want to do the same thing for our key matrix and value matrix. We finally arrive to the famous attention equation

$
  "Attention"(Q,K,V) = "softmax"(frac(K^T Q, sqrt(d_k))) V
$
Notice what exactly is $K^T Q$ doing? Its computing a dot product for every single word in the key matrix and every single word in the value matrix. What does this tell us? Remember, the dot product is a measure of how _similar_ the directions of two vectors are. You can imagine that doing this will result in finding combinations of words that are similar or _related_ to one another. Which means that the queries will be answered by the keys. That is, each word can ask its preceding words how important so to speak it is with the current word.
```python
def attention_block(prompt: str, embedding_model, W_Q, W_K, W_V) -> str:
    tokens = tokenize(prompt)
    embeddings = embed(tokens, embedding_model)
    positional_encodings = positional_encoding(tokens)
    model_input = embeddings + positional_encodings
    Q = model_input @ W_Q
    K = model_input @ W_K
    V = model_input @ W_V
    attention = (
        softmax((Q @ K.T) / np.sqrt(QUERY_DIMENSION)) @ V
    )  # The attention block!
```
#bookmark(date: "June 27 2026")[
  Exploring the world of language models starting #link("/2026/06/27/n-gram-language-model.html")[here!]
]
