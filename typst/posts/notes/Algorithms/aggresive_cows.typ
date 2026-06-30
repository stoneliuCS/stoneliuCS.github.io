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
Since this has only $2$ cows, I want to keep them maximally distanced. That would be the stalls located at $2$ and $26$ for a maximum distance of $24$. Okay simple enough. Let's try $3$. In this case intuitively I want to be able to split this and find the middle distance between $2$ and $26$. That would be $frac(26 + 2, 2) = 14$. But since we don't have $14$ we choose its nearest neighbor which is $12$. Now the min distance would be $min(26 - 12, 12 - 2) = 10$. Hmmm this leads me to believe that there is potentially a _binary search_ going on here. The task is essentially, for each pair of stalls, we want to perform binary search on each of them and then find the point that maximizes the distance between each of the points on a number line.

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

#aside[
  Okay this is where I get stuck, since I am performing binary search on the positions of stalls. Most answers online tell me that its probably better if I perform binary search on some optimal value $d$ and check if its possible to place cows that far apart from one another.
]

If we continue for $k = 4$ the mid distance we have remaining would be $frac(12 + 2, 2) = 7$ which is indeed on our number line. The min distance would then devolve into $min(7 - 2, 12 - 7) = 5$.

#aside[I will note that this particular way of thinking for me is a little _counter-intuitive_ and I would never really approach a problem first-thing like this.]

If we flip the answer around such that we want to optimize and find some distance $d$ such that we can place all the cows under, then run binary search on that value we can reach the solution.

Essentially what is the maximum possible distance you can place cows given stalls? Well that would be the position of the smallest stall vs the largest stall. What is the smallest possible distance you can place two cows? Well that would be $1$. If we do that, then the pseudo-code becomes a lot easier to hash out. Let's first write the function _possible_ that determines given some distance $d$ if its possible to place the cows such that all cows are spaced at-least distance $d$ apart.

```python
def possible(self, stalls, k, d):
  remaining_cows = k
  idx = 0
  prev_cow_pos = None
  # Greedily place cows if the position is possible
  while remaining_cows > 0 and idx < len(stalls):
    curr_pos = stalls[idx]
    if prev_cow_pos is None or (curr_pos - prev_cow_pos) >= d:
      prev_cow_pos = curr_pos
      remaining_cows -= 1
    idx += 1
  return remaining_cows == 0
```

Usually its always good to test these helper functions so lets check...
```python
assert True == possible([2,3,7,11,12,26], 2, 24) # Should be true
assert False == possible([2,3,7,11,12,26], 3, 24) # Should be false
assert False == possible([2,3,7,11,12,26], 3, 12) # Should be false
assert True == possible([2,3,7,11,12,26], 3, 10) # Should be true!
assert False == possible([2,3,7,11,12,26], 4, 7) # Should be false.
assert True == possible([2,3,7,11,12,26], 4, 5) # Should be true.
assert True == possible([2,3,7,11,12,26], 5, 1) # Should be true.
```
With those checks passing we can write the binary search on $d$...
```python
def aggressiveCows(self, stalls, k):
    stalls = sorted(stalls)
    l = 1
    r = stalls[len(stalls) - 1] - stalls[0]
    opt_d = 1
    while l <= r:
      d = (l + r) // 2
      if self.possible(stalls, k, d):
        # try to expand the distance using binary search.
        l = d + 1
        opt_d = d
      else:
        # If its not possible then we would have to make the distance smaller.
        r = d - 1
    return opt_d
```
Testing it out on the rudimentary example above...
```python
val = aggressiveCows([2,3,7,11,12,26], 2)
assert val == 24
val = aggressiveCows([2,3,7,11,12,26], 3)
assert val == 10
val = aggressiveCows([2,3,7,11,12,26], 4)
assert val == 5
```
If we think about the overall time complexity, given $n$ stalls and $k$ cows, we would perform binary search a total of $k$ times. So the overall time complexity would have to be $O(k log(n))$.
