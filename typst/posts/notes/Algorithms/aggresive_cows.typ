#import "@preview/diagraph:0.3.7"

#metadata((
  title: "aggressive cows",
  date: "2026-06-29",
)) <post-meta>

#import "../../../lib/web.typ": aside
#import "@preview/cetz:0.3.4": canvas, draw

The #link("https://www.geeksforgeeks.org/problems/aggressive-cows/1")[problem] goes like this...

#aside[
  Okay so I have $k$ stalls and what i want to be able to do is to find some placement of $k$ stalls such that the minimum distance between any two cows is maximized... I am just restating the problem here. I need to work through more examples.
]

you are given $"stalls"[]$ which is an array of integers. $"stalls"[i]$ represents the position of the $"ith"$ stall. You are also given $k$ to represent the number of aggressive cows. The *goal* is to try and assign all the stalls to $k$ cows such that the minimum distance between any two cows is maximized.

Okay... so lets say we have $k = 3$ cows and we have all the stalls consecutively: $"stalls" = [1,2,3,4]$

I guess I can assign them in any order maybe? Like if I placed cow $1,2,3$ on $i=0,1,2$. Then the min distance would be $1$ for all of them so I would return $1$.

But lets say we go through the provided example:

$ "stalls"[] = [10, 1, 2, 7, 5], k = 3 $
Say I picked the first three numbers in _stalls_. That would mean that all cows would be located at $10,1,2$. Well pair wise I would compute the distances among all $3$ which would be $9, 8, 1$. But $min(9, 8, 1) = 1$. Clearly this is not the maximum of the sequence. However if I chose the locations $10, 1, 5$ then I can see that my pair wise distances would be $9, 5, 4$  which $min(9, 5, 4) = 4$. So one brute force way to do this is to just to find all possible combinations of locations and then compute their pairwise conditions. That is pretty bad, its factorial in time so we can disregard the brute force solution.

Okay that was kinda easy to just brute force, for that one example, another thing that I have found is that
$
  "stalls"[] = [2, 12, 11, 3, 26, 7], k = 5
$
This one I don't even have to check every single pairwise distance. There are $6$ stalls for $5$ cows, this means that I must choose $2,3$ or $12,11$ which the minimum distance has to be $1$.

Let's start with a smaller example. $k = 2$ on the entire set.
$
  "stalls"[] = [2, 12, 11, 3, 26, 7], k = 2
$
Since this has only $2$ cows, I want to keep them maximally distanced. That would be the stalls located at $2$ and $26$ for a maximum distance of $24$. Okay simple enough. Let's try $3$. In this case intuitively I want to be able to split this and find the middle distance between $2$ and $26$. That would be $frac(26 + 2, 2) = 14$. But since we don't have $14$ we choose its nearest neighbor which is $12$. Now the min distance would be $min(26 - 12, 12 - 2) = 10$. Hmmm this leads me to believe that there is potentially a `binary search`. The task is essentially, for each pair of stalls, we want to perform binary search on each of them and then find the point that maximizes the distance between each of the points on a number line.

#figure(canvas({
  import draw: *

  let stalls = (2, 3, 7, 11, 12, 26)
  let (min, max) = (0, 28)
  let span = max - min
  let s(x) = (x - min) / span * 8 // scale to fit

  line((s(min) - 0.3, 0), (s(max) + 0.3, 0))
  for x in stalls {
    let px = s(x)
    line((px, -0.2), (px, 0.2))
    content((px, -0.5), text(str(x), size: 0.7em))
  }
  line((s(min) - 0.3, 0), (s(min) - 0.1, 0.1))
  line((s(min) - 0.3, 0), (s(min) - 0.1, -0.1))
  line((s(max) + 0.3, 0), (s(max) + 0.1, 0.1))
  line((s(max) + 0.3, 0), (s(max) + 0.1, -0.1))
}))
