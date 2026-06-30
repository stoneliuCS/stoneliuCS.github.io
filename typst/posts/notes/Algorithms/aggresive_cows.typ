#import "@preview/diagraph:0.3.7"

#metadata((
  title: "aggressive cows",
  date: "2026-06-29",
)) <post-meta>

#import "../../../lib/web.typ": aside

The #link("https://www.geeksforgeeks.org/problems/aggressive-cows/1")[problem] goes like this...

#aside[
  Okay so I have $k$ stalls and what i want to be able to do is to find some placement of $k$ stalls such that the minimum distance between any two cows is maximized... I am just restating the problem here. I need to work through more examples.
]

you are given $"stalls"[]$ which is an array of integers. $"stalls"[i]$ represents the position of the $"ith"$ stall. You are also given $k$ to represent the number of aggressive cows. The *goal* is to try and assign all the stalls to $k$ cows such that the minimum distance between any two cows is maximized.

Okay... so lets say we have $k = 3$ cows and we have all the stalls consecutively: $"stalls" = [1,2,3,4]$

I guess I can assign them in any order maybe? Like if I placed cow $1,2,3$ on $i=0,1,2$. Then the min distance would be $1$ for all of them so I would return $1$.

But lets say we go through the provided example:

$ "stalls"[] = [10, 1, 2, 7, 5], k = 3 $
Say I picked the first three numbers in _stalls_. That would mean that all cows would be located at $10,1,2$. Well pair wise I would compute the distances among all $3$ which would be $9, 8, 1$. But $min(9,8,1) = 1$. Clearly this is not the maximum of the sequence. However if I chose the locations $10, 1, 5$ then I can see that my pair wise distances would be $9, 5, 4$  which $min(9,5,4) = 4$. So one brute force way to do this is to just to find all possible combinations of locations and then compute their pairwise conditions. That is pretty bad, its factorial in time so we can disregard the brute force solution.
