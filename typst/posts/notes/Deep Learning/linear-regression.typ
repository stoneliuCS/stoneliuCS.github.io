#metadata((
  title: "Linear Regression",
  date: "2026-06-23",
)) <post-meta>

#import "../../../lib/web.typ": aside
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

#aside[I will be following the book _Introduction to Linear Regression Analysis_ as well as the video series made by #link("https://www.youtube.com/watch?v=3g-e2aiRfbU")[Jason Jiao] _really great stuff!_]

== The Slope of the Regression Line
Lets consider a table of values here, where $x$ is called the independent variable and $y$ is called the dependent variable.

#figure(
  table(
    columns: 7,
    [x], [11], [17], [18], [22], [31], [50],
    [y], [10], [14], [20], [27], [33], [82],
  ),
)

If we collected these data points out in the wild, then the easiest thing to do is to assume that these data points have a _Linear Relationship_. If we assume that the data points have a linear relationship then we have our very simple linear regression model:

$ hat(y) = hat(beta)x + hat(beta_0) $

Notice that we have a $hat$ to mark off each of the $beta$ and $y$ values. This is because that it is expected that we can only approximate the relationship between the two variables, since it is very rare to gather data in the real world with a true linear relationship. We can approximate $hat(beta)$ with the following formula

$
  hat(beta) = frac(sum_(i = 1)^n (x_i - overline(x)) (y_i - overline(y)), sum_(i = 1)^n (x_i - overline(x))^2)
$

Jason does a really nice job visualizing what this formula is describing, consider the horizontal line $overline(x)$ and the vertical line $overline(y)$. These are the averages of all the $x$ and $y$ data points. For our current sample that would be

$
  overline(x) = frac(11 + 17 + 18 + 22 + 31 + 50, 6) approx 24.8 \
  overline(y) = frac(10 + 14 + 20 + 27 + 33 + 82, 6) approx 31 \
$

#let data = ((11, 10), (17, 14), (18, 20), (22, 27), (31, 33), (50, 82))

#figure(
  cetz.canvas({
    plot.plot(
      size: (9, 6),
      x-label: $x$,
      y-label: $y$,
      x-min: 0,
      x-max: 55,
      y-min: 0,
      y-max: 90,
      {
        plot.add(
          data,
          mark: "o",
          mark-size: 0.22,
          style: (stroke: none),
        )
        plot.add-vline(24.8, style: (stroke: (paint: red, dash: "dashed")))
        plot.add-hline(31, style: (stroke: (paint: blue, dash: "dashed")))
        // regression line: y-hat = 1.845 x - 14.82
        plot.add(
          domain: (0, 55),
          samples: 2,
          x => 1.845 * x - 14.82,
          style: (stroke: rgb("#2e8b57") + 1.2pt),
        )
      },
    )
  }),
)

If we were to directly calculate $hat(beta)$ for $n = 6$ we would see that

```python
data_points = [(11, 10), (17, 14), (18, 20), (22, 27), (31, 33), (50, 82)]
x = [point[0] for point in data_points]
y = [point[1] for point in data_points]
beta_hat, beta_hat_intercept = np.polyfit(x, y, deg=1) # degree 1 polynomial
```

$
  hat(beta) = frac((11 - 24.8)(10 - 31) + (17 - 24.8)(14 - 31) + dots + (50 - 24.8)(82 - 31), (11 - 24.8)^2 + dots + (50 - 24.8)^2) approx 1.845 \
  hat(beta_0) approx -14.82
$
So the regression line is of the form $hat(y) = 1.845x - 14.82$.

== Linear Transformations
Let's take a _slight_ tangent and explore the concept of the _Linear Transformation_ in Linear Algebra. Visualizing this in _2D_ space, all linear transformations must preserve the original basis vectors. in $RR^2$ we have
$
  e_1 = vec(1, 0) "and" e_2 = vec(0, 1)
$
For example, take the vector $v = vec(2, 3)$, it can be written as $v = 2 e_1 + 3 e_2$. Now say we that apply some linear transformation, call it $T$. I really love how #link("https://www.google.com/search?q=3blue1brown&oq=&gs_lcrp=EgZjaHJvbWUqBggAEEUYOzIGCAAQRRg7MgYIARBFGDkyDggCEEUYJxg7GIAEGIoFMgwIAxAAGEMYgAQYigUyDAgEEAAYFBiHAhiABDIMCAUQABhDGIAEGIoFMgYIBhBFGDwyBggHEEUYPNIBCDIwNzZqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8#:~:text=Web%20results-,3Blue1Brown,8.4M%2B%20followers,-Videos%20here%20cover")[3Blue1Brown] describes the point of linear transformations. We don't really have to _"watch"_ where the vector $v$ lands in the transformation $T$, we just have to observe where its basis vectors $e_1$ and $e_2$ land.

$
  T(v) = T(2e_1 + 3e_2) = 2 T(e_1) + 3 T(e_2)
$

Say that $T$ is a function that maps
$
  T(e_1) = vec(3, 3) "and" T(e_2) = vec(1, 2)
  => T(v) = 2 vec(3, 3) + 3 vec(1, 2) = vec(9, 12)
$
Notice that we did not calculate $T(v)$ explicitly, we simply calculated where $T$ sent the basis vectors for $v$ and then deduced that must be where $T(v)$ is going to land. Now we can describe how matricies can be served as a linear transformation. Say we put the column vectors of $T(e_1)$ and $T(e_2)$ into a matrix, then we get
$
  M = mat(
    bar.v, bar.v;
    T(e_1), T(e_2);
    bar.v, bar.v;
  )
  =
  mat(
    3, 1;
    3, 2;
  )
$
What happens when we multiply this matrix with our $v$? We get
$
  mat(
    3, 1;
    3, 2;
  )
  vec(2, 3)
  =
  2 vec(3, 3) + 3 vec(1, 2)
  =
  mat(
    3 dot 2 + 1 dot 3;
    3 dot 2 + 2 dot 3
  )
  = vec(9, 12)
$
So literally the $mat(3, 1; 3, 2)$ is the transformation $T$ since we can multiply $M$ with any vector in $RR^2$ and that will describe the linear transformation $T$.

== The Normal Equation
Consider the same data points as last time.
#figure(
  table(
    columns: 7,
    [x], [11], [17], [18], [22], [31], [50],
    [y], [10], [14], [20], [27], [33], [82],
  ),
)
We could represent this as a series of linear equations as such
$
  10 = 11 beta + beta_0 \
  14 = 17 beta + beta_0 \
  dots.v \
  82 = 50 beta + beta_0
$
Simply eye-balling the graph above, we know that clearly there is no singular line that passes through all data points. But we can approximately get the value of $beta$ and $beta_0$ that will get us the _closest_. Lets convert this system of equations into matrix form by taking the coefficients on each side.

$
  y = X b =
  mat(10; 14; 20; 27; 33; 82) = mat(
    11, 1;
    17, 1;
    18, 1;
    22, 1;
    31, 1;
    50, 1;
  )
  mat(
    beta;
    beta_0
  )
$
What happens when we multiply both sides by the transpose on both sides? Well that means that we are effectively applying a _Linear Transformation_ $X^T$ where the columns of $X^T$ are indeed made up of the transformations of the basis vectors in $RR^2$.
$
  mat(
    11, 17, 18, 22, 31, 50;
    1, 1, 1, 1, 1, 1;
  )
  mat(10; 14; 20; 27; 33; 82) =
  mat(
    11, 17, 18, 22, 31, 50;
    1, 1, 1, 1, 1, 1;
  )
  mat(
    11, 1;
    17, 1;
    18, 1;
    22, 1;
    31, 1;
    50, 1;
  )
  mat(
    beta;
    beta_0
  )
$
The transformation we have applied will send the column vectors of $X$ which live in $RR^6 -> RR^2$. If we carry out all of these multiplications and inverses _(Done with the help of numpy)_ then we can see that we get
```python
X = np.array(
    [
        [11, 1],
        [17, 1],
        [18, 1],
        [22, 1],
        [31, 1],
        [50, 1],
    ]
)
y = np.array(y)
# Normal Equation
XTX = X.T @ X
XTY = X.T @ y
b = np.linalg.inv(XTX) @ XTY

=> [1.84505364, -14.81883194]
```
Which is precisely what we get from computing the slope of the line and intercepts beforehand.
