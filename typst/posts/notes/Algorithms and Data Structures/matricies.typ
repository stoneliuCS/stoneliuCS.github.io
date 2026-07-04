#metadata((
  title: "matrices",
  date: "2026-07-03",
)) <post-meta>

#import "../../../lib/web.typ": aside, update

_A collection of my most hated and beloved matrix problems for my refreshment._

== 1. Spiral Matrix
#link("https://leetcode.com/problems/spiral-matrix/description/")[Problem] goes like this. We have the following matrix

```
1 2 3
4 5 6
7 8 9
```
We want to iterate over the matrix in the following fashion: $1,2,3,6,9,8,7,4,5$. Conceptually, it means that I want to be able to go through the values of my matrix in the following order, first row, then last column, then last row, then first column, then second row, etc. So literally iterate over the matrix in this _"spiral"_ order. What I am first thinking is lets set up _two pointers_, one pointer for the current row that we are in and one pointer for the current column that we are in. Let's traverse step by step and view the iterations at each step.

```
--- Start
row_ptr = 0, col_ptr = 0, order = []
1 2 3
4 5 6
7 8 9
--- 1st Iteration
row_ptr = 0, col_ptr = 0, order = [1]
x 2 3
4 5 6
7 8 9
--- 2nd Iteration
row_ptr = 0, col_ptr = 1, order = [1,2]
1 x 3
4 5 6
7 8 9
--- 3rd Iteration
row_ptr = 0, col_ptr = 2, order = [1,2,3]
1 2 x
4 5 6
7 8 9
--- 4th Iteration
# Once the col_ptr < m = 2 condition fails we start iterating on the row_ptr
row_ptr = 1, col_ptr = 2, order = [1,2,3,6]
1 2 3
4 5 x
7 8 9
--- 5th Iteration
row_ptr = 2, col_ptr = 2, order = [1,2,3,6,9]
1 2 3
4 5 6
7 8 x
--- 5th Iteration
# Same thing here, once we have row_ptr, col_ptr < n, m = 2 we start iterating backwards from col
row_ptr = 2, col_ptr = 1, order = [1,2,3,6,9,8]
1 2 3
4 5 6
7 x 9
--- 6th Iteration
row_ptr = 2, col_ptr = 0, order = [1,2,3,6,9,8,7]
1 2 3
4 5 6
x 8 9
--- 7th Iteration
# When col_ptr = 0 we want to move back up again
row_ptr = 1, col_ptr = 0, order = [1,2,3,6,9,8,7,4]
1 2 3
x 5 6
7 8 9
--- 7th Iteration
# We already visited row_ptr = 0 and col_ptr = 0 which means we start iterating on the col_ptr now. (Flipping as we go)
row_ptr = 1, col_ptr = 1, order = [1,2,3,6,9,8,7,4,5]
1 2 3
4 x 6
7 8 9
```
Okay nice, so just walking through this one example uncovered a few edge cases. For one, we don't want to go back to positions we have already done before. So maybe keeping a hashset of lookups for positions might be useful. One full spiral iteration involves $4$ things:

1. Go _right_ as much as you can.
2. Go _down_ as much as you can.
3. Go _left_ as much as you can.
4. Go _up_ as much as you can.
5. Repeat.

How to know when to stop? There are probably alot of cases but we can stop when our final output array matches the length of $m times n$ where $m, n$ are the rows and columns or dimensions of our matrix. We want the hashset for lookups since it becomes especially prevalent on larger and larger matricies such as:

#aside[
  Yet again I am wrong! The hash set implementation cannot discern if I have visited (0,1) or (1,0) unless I add an explicit ordering on my set such as a tuple. It is much easier to keep track of my upper, lower, right, and left bounds.
]
```
1  2  3  4
5  6  7  8
9  10 11 12
13 14 15 16
```
We will have to run our spiral loop to completion _twice_ to obtain all the elements.

The working solution below keeps track of the upper, lower, left, and right bounds. Shrinking them at every single iteration.
```c
class Solution {
  public:
    vector<int> spiralOrder(vector<vector<int>>& matrix) {
      int m = matrix.size();
      int n = matrix[0].size();
      vector<int> order = {};
      int upper = 0;
      int lower = m - 1;
      int right = n - 1;
      int left = 0;

      while (order.size() < m * n) {
        // Go right as much as you can
        for (int i = left; i <= right && order.size() < m * n; i++) {
          order.push_back(matrix.at(upper).at(i));
        }
        upper += 1;

        // Go down as much as you can
        for (int i = upper; i <= lower && order.size() < m * n; i++) {
          order.push_back(matrix.at(i).at(right));
        }
        right -= 1;

        // Go left as much as you can
        for (int i = right; i >= left && order.size() < m * n; i--) {
          order.push_back(matrix.at(lower).at(i));
        }
        lower -= 1;

        // Go up as much as you can
        for (int i = lower; i >= upper && order.size() < m * n; i--) {
          order.push_back(matrix.at(i).at(left));
        }

        left += 1;
      }

      return order;
    };
};
```
