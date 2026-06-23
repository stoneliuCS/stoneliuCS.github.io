#metadata((
  title: "Linear Regression",
  date: "2026-06-22",
)) <post-meta>

#import "../../../lib/web.typ": aside

#aside[I will be following the book _Introduction to Linear Regression Analysis_]

Lets deep dive into a seemingly basic and introductory technique called _Linear Regression_. I first learned this in a high school maths class. It's essentially a technique to measure the relationships among variables. Yeah very vague but It will become a lot more clear as time moves on.

=== The Equation of the Line
We all know this, its the very first thing we learn to plot on a graph.
$ y = m x + b $
The coefficient on the $x$ term is $m$ and its what we call the slope of the line, it determines the direction and _steepness_ of the line. The other term is $b$, and its commonly referred to as the intercept, because that is where the line intercepts the _y-axis_. This is pretty intuitive since at $x = 0 => y = b$.

Obviously if we sample specific data points out in the real world (like with scatter plots) we will never ever truly get a perfect line of data points that we can fit a line through. Which is why the classic linear regression model adds an error term $epsilon$.

$
  y = m x + b + epsilon
$

*WIP (Work in Progress)*
