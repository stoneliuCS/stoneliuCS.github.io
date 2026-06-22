#metadata((
  title: "Spam or Ham",
  date: "2026-06-22",
  description: "A naive approach that works surprisingly well!",
)) <post-meta>

#import "../../../lib/web.typ": aside

_Supervised_ means in essence to be watched over, like a parent watching their child play so that they avoid getting hurt. _Supervised Machine Learning_ means training a model on already _labeled_ data points so that the model is able to generalize and extrapolate predictions for new data points.

== Spam vs Ham
Let's start with the classic issue of identifying spam vs not spam emails, a binary classification problem. Lets examine a few techniques on how we can do this effectively.

=== Naive Bayes Classifier
In _Probability Theory_ the probability function denoted as $Pr (Y | X)$ reads what is the probability of a random variable $Y$ given that we have observed $X$. In this case $Y in { 0, 1 }$ where $1$ or $0$ for _Spam_ or _Ham_. Here is the definition of _Bayes Theorem_:
$
  Pr(Y | X) = frac(Pr(X | Y) dot Pr(Y), Pr(X))
$
Notice we have switched the language of the problem now from _what is the probability of the following email is spam given these features_ to _what is the probability that you get these features considering the email is spam?_. That is the power of _Baye's_ theorem.

But why is it called _naive_? Well since it makes our lives easier of course. We represent $X$ as a _vector_ that captures the frequency of each unique word present in the email. When we assume that every single frequency for each unique word is independent _(which is obviously not the case)_ we get that
$
  Pr(X | Y) = Pr(x_1 | Y) dot Pr(x_2 | Y) dots.c Pr(x_n | Y)
$
So we can rewrite our initial equation under this assumption to get
$
  Pr(Y | X) = frac(Pr(x_1 | Y) dot Pr(x_2 | Y) dots.c Pr(x_n | Y) dot Pr(Y), Pr(X))
$
Before we confuse ourselves with all of this mathematical notation, its always good to translate each of these probability calculates into plain english, starting off with
1. $Pr(Y) -> "What is the probability that the email is spam?"$
2. $Pr(x_i | Y) -> #text[What is the probability that the given word $x_i$ appears in the spam training set.]$
3. $Pr(X) -> "What is the probability of this exact email? (Not really useful it cancels)."$
  - _Why?_ well what is another way of framing if this email is _spam_ or not? It means given an email, is it more likely to be spam or not spam? So literally we are calculating
  $
    Pr(1 | X) > Pr(0 | X) "where 1 is spam, 0 is ham."
  $
  $
    frac(Pr(X | 1) dot Pr(1), Pr(X)) >
    frac(Pr(X | 0) dot Pr(0), Pr(X))
    =>
    frac(Pr(X | 1) dot Pr(1), cancel(Pr(X))) >
    frac(Pr(X | 0) dot Pr(0), cancel(Pr(X)))
  $
We can _estimate_ the probability of each of these values using a training _corpus_. From our training corpus we estimate the values as follows
$
  Pr(Y) = frac("Number of Spam Emails", "Total Number of Emails")
$
$
  Pr(x_i | Y) = frac("The frequency of the given word in class Y emails", "Total number of words in all class Y emails.")
$

=== Data Pipeline
Let's build a miniature data processing pipeline for our naive _bayes classification_ model. We'll take a corpus which for me is just a csv that looks something like this:
```csv
v1,v2,,,
ham,"Go until jurong point, crazy.. Available only in bugis n great world la e buffet... Cine there got amore wat...",,,
ham,Ok lar... Joking wif u oni...,,,
spam,Free entry in 2 a wkly comp to win FA Cup final tkts 21st May 2005. Text FA to 87121 to receive entry question(std txt rate)T&C's apply 08452810075over18's,,,
```
There is around $5,500$ labeled spam vs ham emails. Lets divide the corpus into two datasets _train_ and _test_. Then we can compute the frequencies for each word per label $Y$ _(Spam or Ham)_
```
      spam_count  ham_count  spam_total  ham_total  spam_emails  ham_emails
word
to           552       1229       14300      54567          598        3859
a            304        822       14300      54567          598        3859
call         271        179       14300      54567          598        3859
your         214        337       14300      54567          598        3859
you          205       1347       14300      54567          598        3859
the          165        893       14300      54567          598        3859
for          163        394       14300      54567          598        3859
or           148        183       14300      54567          598        3859
free         146         40       14300      54567          598        3859
is           131        578       14300      54567          598        3859
```
With this table we can effectively answer $Pr(x_i | Y)$ and $Pr(Y)$ for example
$ Pr("call" | 1) = frac(271, 14300) approx 0.019 $
$ Pr(1) = frac(598, 598 + 3859) approx 0.134 $
$ Pr(0) = frac(3859, 598 + 3859) approx 0.866 $
With this table we can calculate the probability of a spam or ham. Take for example this email plucked straight from my spam box
```
[SUBJECT LINE] You Are Our 3rd Winner !! Confirm & Claim 🎁 Lowe's Gorilla Carts

[BODY]
Congratulations!

You are a Winner of a

Gorilla Carts

You have been selected as one of the lucky few for a
unique opportunity to receive a
Gorilla Carts

Get it Now
```
When we tokenize the body of this email, we represent $X$ as a vector for each of the counts in the email. The word frequences look like this
```
                  spam_count  ham_count  in_email  p_given_spam  p_given_ham
word
congratulations!           2          0         1      0.000140     0.000000
you                      205       1347         2      0.014336     0.024685
are                       61        313         1      0.004266     0.005736
a                        304        822         4      0.021259     0.015064
winner                    10          0         1      0.000699     0.000000
of                        74        411         2      0.005175     0.007532
gorilla                    0          0         2      0.000000     0.000000
carts                      0          0         2      0.000000     0.000000
have                     110        349         1      0.007692     0.006396
been                      32         67         1      0.002238     0.001228
selected                  22          2         1      0.001538     0.000037
as                        27        119         1      0.001888     0.002181
one                        6        107         1      0.000420     0.001961
the                      165        893         1      0.011538     0.016365
lucky                      8          4         1      0.000559     0.000073
few                        0         24         1      0.000000     0.000440
for                      163        394         1      0.011399     0.007220
unique                     1          1         1      0.000070     0.000018
opportunity                0          3         1      0.000000     0.000055
to                       552       1229         1      0.038601     0.022523
receive                   26          3         1      0.001818     0.000055
get                       62        238         1      0.004336     0.004362
it                        20        342         1      0.001399     0.006268
now                       75        119         1      0.005245     0.002181
```
So the feature variables will reflect the _in_email_ column. We will also be using a _multinomial classifier_ which means that we will be taking its occurrence in the email into account.
$ X = vec(1, 4, 2, dots.v, 2) = vec(x_1, x_2, x_3, dots.v, x_24) $
$
  Pr(X | 1) dot Pr(1) = Pr(x_1 | 1)^(x_1) dot Pr(x_2 | 1)^(x_2) dots.c Pr(x_24 | 1)^(x_24) dot Pr(1)
$
$
  Pr(X | 0) dot Pr(0) = Pr(x_1 | 0)^(x_1) dot Pr(x_2 | 0)^(x_2) dots.c Pr(x_24 | 0)^(x_24) dot Pr(0)
$
Remember $Pr(x_i | y) = frac("Occurrence of the word in the class data set", "All words in the class data set")$. I won't do this for all $24$ unique words in the spam email but for the first one the word _"congratulations!"_ would be for each
$
  Pr("congratulations!" | 0) = (frac(0, 54567))^1 = 0 \
  Pr("congratulations!" | 1) = (frac(2, 14300))^1 approx 0.000140 \
$
Of course there is an issue, in a product chain $p_1p_2p_3$ if any of the values are zero, the entire product is zero. Which we see for words like _congratulations!_ and _opportunity_. So we will use a technique called #link("https://en.wikipedia.org/wiki/Additive_smoothing")[Laplace Smoothing] which says that for $Pr(x_i | Y)$ we have
$
  Pr(x_i | Y) = frac("Number of times the word appears in class Y" + alpha, "total word count for class Y" + alpha dot "Number of features")
$
Applying _Laplace Smoothing_ with $alpha = 1$ we get
```
                  spam_count  ham_count  in_email  p_given_spam  p_given_ham
word
congratulations!           2          0         1      0.000115     0.000015
you                      205       1347         2      0.007892     0.020310
are                       61        313         1      0.002375     0.004731
a                        304        822         4      0.011684     0.012400
winner                    10          0         1      0.000421     0.000015
of                        74        411         2      0.002873     0.006208
gorilla                    0          0         2      0.000038     0.000015
carts                      0          0         2      0.000038     0.000015
have                     110        349         1      0.004252     0.005273
been                      32         67         1      0.001264     0.001025
selected                  22          2         1      0.000881     0.000045
as                        27        119         1      0.001073     0.001808
one                        6        107         1      0.000268     0.001627
the                      165        893         1      0.006359     0.013470
lucky                      8          4         1      0.000345     0.000075
few                        0         24         1      0.000038     0.000377
for                      163        394         1      0.006283     0.005951
unique                     1          1         1      0.000077     0.000030
opportunity                0          3         1      0.000038     0.000060
to                       552       1229         1      0.021185     0.018532
receive                   26          3         1      0.001034     0.000060
get                       62        238         1      0.002414     0.003601
it                        20        342         1      0.000805     0.005168
now                       75        119         1      0.002912     0.001808
```
$
  P(X|1) dot P(1) = 8.33153414855613 dot 10^(-95) \
  P(X|0) dot P(0) = 2.0094869979539083 dot 10^(-96) \
  ==> P(X | 1) dot P(1) > P(X | 0) dot P(1) \
  ==> "The email should be marked SPAM"
$
This simple technique, although naive works incredibly well in practice!

== Resources
- #link(
    "https://www.geeksforgeeks.org/machine-learning/multinomial-naive-bayes/",
  )[Multinomial Naive Bayes]
- #link(
    "https://www.geeksforgeeks.org/machine-learning/naive-bayes-classifiers/",
  )[Bayes Classifiers]
