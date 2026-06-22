#import "@preview/diagraph:0.3.7"

#metadata((
  title: "Forward Automatic Differentiation",
  date: "2026-06-16",
  featured: true,
)) <post-meta>

== The Chain Rule

Recall that the definition of the derivative of a function $f$ at a given input $x$ is

$ lim_(h -> 0) frac(f(x+h) - f(x), h) $

Let $f(x) = e^x$, $g(x) = -x^2$ and $h(x) = f((g(x)) = (f compose g) (x)$. You can also simply rewrite this as:
$h(x) = f(-x^2) = e^(-x^2)$. I find it very helpful to remember what the derivative is actually _measuring_. Consider the composite function $h(x)$. Let $z = h(x)$ in otherwords, $z$ is the output to $h(x)$. The derivative of $h$ is saying that if you move the input to $h$ which is $x$ by some very small change, call it _delta_ $Delta$, how much does the output of $h$ which is $z$ change?

Now let us assign symbols to the rest of the values of our functions:

$ y = f(x), z = g(y), z = h(x) $

What is the derivative of $h(x)$? that would be
$ frac(dif x, dif z) = frac(dif y, dif z) dot frac(dif x, dif y) $
The chain rule says that it is a product of two derivatives. The more standardized notation would be

$ frac(dif h, dif z) = frac(dif g, dif y) dot frac(dif f, dif x) $
Using this, we find that
$ frac(dif h, dif z) = -2x dot e^x $

== Computational Graphs

Let us define a function of two variables $x, y$.

$ f(x,y) = (x + 2y)^2 dot sin(x y) $

Let us see how the computation flows from $x, y$.

#figure(diagraph.render(
  "digraph {
  rankdir=LR;
  x;
  y;
  a;
  b;
  c;
  d;
  e;

  x -> a;
  y -> a;
  x -> b;
  y -> b;
  a -> c;
  b -> d;
  c -> e;
  d -> e;
}",
  labels: (
    x: $x$,
    y: $y$,
    a: $x + 2y$,
    b: $x y$,
    c: $(x + 2y)^2$,
    d: $sin(x y)$,
    e: $(x + 2y)^2 dot sin(x y)$,
  ),
))

Assigning variables to each of our nodes now we have
$ n_1 = x, n_2 = y, n_3 = x + 2y, n_4 = x y $
$ n_5 = (x + 2y)^2, n_6 = sin(x y), n_7 = (x + 2y)^2 dot sin(x y) $

== Forward Autodifferentiation
What we want to do now is to _differentiate_ with respect to each of our input variables for each of our respective nodes $n$.

$
  frac(partial n_1, partial n_1) = 1, quad frac(partial n_2, partial n_1) = 0, quad frac(partial n_3, partial n_1) = 1, quad frac(partial n_4, partial n_1) = y, \
  frac(partial n_5, partial n_1) = 2(x + 2y), quad frac(partial n_6, partial n_1) = y cos(x y), \
  frac(partial n_7, partial n_1) = (x + 2y)^2 y cos(x y) + 2 sin(x y) (x + 2y)
$

We do the same with $n_2$ since that is another input variable.

$
  frac(partial n_1, partial n_2) = 0, quad frac(partial n_2, partial n_2) = 1, quad frac(partial n_3, partial n_2) = 2, quad frac(partial n_4, partial n_2) = x, \
  frac(partial n_5, partial n_2) = 4(x + 2y), quad frac(partial n_6, partial n_2) = x cos(x y), \
  frac(partial n_7, partial n_2) = (x + 2y)^2 x cos(x y) + 4 sin(x y) (x + 2y)
$

But of course we computed all of these _symbolically_ this is quite inefficient when doing computation so thus we want to be able to reuse previous expressions. If we consider forward autodifferentiation with respect to $n_1$ we get:

$
  dif n_1 = 1, dif n_2 = 0, dif n_3 = n_1 + 2n_2, dif n_4 = n_1 dif n_2 + n_2 dif n_1, dif n_5 = 2 (n_1 + 2n_2) dot dif n_3 \ dif n_6 = cos(dif n_4), dif n_7 = n_5 dot dif n_6 + n_6 dif n_5
$

If we differentiate with respect to $n_2$ then we just have to swap our seed values of $dif n_1 = 0, dif n_2 = 1$.

```python
  def forward_auto_diff(x, y):
      vector = []
      n1 = x
      n2 = y
      n3 = x + 2 * y
      n4 = x * y
      n5 = (x + 2 * y) ** 2
      n6 = math.sin(x * y)
      n7 = n5 * n6

      # Autodif with respect to n1
      dn1 = 1
      dn2 = 0
      dn3 = 1
      dn4 = n1 * dn2 + n2 * dn1
      dn5 = 2 * (n3) * dn3
      dn6 = math.cos(n4) * dn4
      dn7 = n5 * dn6 + n6 * dn5

      vector.append(dn7)

      # Autodif with respect to n2
      dn1 = 0
      dn2 = 1
      dn3 = 2
      dn4 = n1 * dn2 + n2 * dn1
      dn5 = 2 * (n3) * dn3
      dn6 = math.cos(n4) * dn4
      dn7 = n5 * dn6 + n6 * dn5

      vector.append(dn7)
      # return the output of f aswell as the gradient.
      return n7, np.array(vector)
```

So really _forward autodifferentiation_ is just a way to reuse past computations so that it is more efficient.
