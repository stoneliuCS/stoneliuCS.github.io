#metadata((
  title: "matrices",
  date: "2026-07-03",
)) <post-meta>

#import "../../../lib/web.typ": aside, edit, update
#import "../../../lib/drawings.typ": draw-matrix, draw-matrix-row

== Spiral Matrix
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
#update(date: "July 5th 2026")[Continuing with the matrix problems...]

== Shortest Path in Binary Matrix
#link("https://leetcode.com/problems/shortest-path-in-binary-matrix/description/?envType=problem-list-v2&envId=matrix")[Problem] goes like this:

1. We are given an $n times n$ matrix with binary entries. We want to return the length of the shortest clear path in the matrix.
2. A _Clear Path_ must satisfy
  - It must go from the top left corner to the bottom right corner $(0,0) -> (n-1,n-1)$.
  - All the visited cells are $0$.
  - Adjacent cells are $8$ directionally connected.

Okay so the first thing that we can check is that if the top left corner or the bottom right corner are either 1s we can immediately return $-1$ since clearly there is no clear path.

Is this _DP (Dynamic Programming)_? I feel like I could solve this with a $2$ dimensional dynamic programming approach. As in, I can compute the shortest clear path from $(0,0)$ to each entry in my matrix. Take for example the following

#draw-matrix-row(
  (
    (
      (0, 0, 0),
      (1, 1, 0),
      (1, 1, 0),
    ),
    (
      (1, $infinity$, $infinity$),
      ($infinity$, $infinity$, $infinity$),
      ($infinity$, $infinity$, $infinity$),
    ),
  ),
)
The left side matrix represents the actual matrix and the right side represents my 2-dimensional dynamic programming table. The update rule should be as follows (in a nut-shell):
$
  "dp"(i,j) = min("dp"(i,j), 1 + "dp"_"previous")
$
What is $"dp"_"previous"$? Really since we can move in $8$ possible directions that just means we can just diagonally. We never really want to backtrack on our answer since that would mean that we would add an additional step which is never optimal. Meaning the previous optimal jump that we were at. So if we follow the _DP_ algorithm as follows we can get:
#aside[
  First move one to the right so $min(1 + 1 = 2, infinity) = 2$
]
#draw-matrix(
  (
    (1, 2, $infinity$),
    ($infinity$, $infinity$, $infinity$),
    ($infinity$, $infinity$, $infinity$),
  ),
)
#aside[
  Next we will move to the adjacent right and also diagonal
]
#draw-matrix(
  (
    (1, 2, 3),
    ($infinity$, $infinity$, $3$),
    ($infinity$, $infinity$, $infinity$),
  ),
)
#aside[
  Since $min(3 + 1, 3) = 3$ we won't update the corresponding row, col.
]
#draw-matrix(
  (
    (1, 2, 3),
    ($infinity$, $infinity$, $3$),
    ($infinity$, $infinity$, $infinity$),
  ),
)
#aside[
  Finally $3 + 1 = 4$ which is of course smaller than infinity.
]
#draw-matrix(
  (
    (1, 2, 3),
    ($infinity$, $infinity$, $3$),
    ($infinity$, $infinity$, $4$),
  ),
)
Our base case for our matrix will be that the top left corner must be $1$ since that counts as a single path in our matrix.

#aside[
  I am wrong again! Because we can move in $8$ seperate directions we cannot use traditional dynamic programming here because we cannot rely on our previous solutions. It may have worked for these smaller examples. But it cannot work here Take for example the following matrix:

  #draw-matrix(
    (
      (0, 1, 0, 1),
      (0, 1, 0, 1),
      (1, 0, 1, 0),
      (1, 1, 1, 1),
    ),
  )
  We would need to visited the cell $i = 1, j = 2$ twice to get the optimal solution!
]

Okay after working through a few more examples and admittingly coding up the wrong solution, the dynamic programming approach will not work here. Which leads me to believe that we should just simply build a graph from our matrix and then run dijkstra's from the top left to the bottom right cells. For _reference_ here is my wrong solution
```c
class Solution {
public:
  int shortestPathBinaryMatrix(vector<vector<int>>& grid) {
    int n = grid.size();
    vector<vector<int>> dp(n, vector<int>(n,numeric_limits<int>::max() / 2));
    if (grid[0][0] == 1 || grid[n-1][n-1] == 1) {
      return - 1;
    }
    dp[0][0] = 1; // base case
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i][j] != 0 || (i == 0 && j == 0)) {
          continue; // skip if its a 1 since there is clearly no clear path here.
        }
        if (i - 1 >= 0) {
          // Check top
          dp[i][j] = min(dp[i][j], 1 + dp[i - 1][j]);
        }
        if (j - 1 >= 0) {
          // Check left
          dp[i][j] = min(dp[i][j], 1 + dp[i][j - 1]);
        }
        if (i - 1 >= 0 && j - 1 >= 0) {
          // Check left diagonal
          dp[i][j] = min(dp[i][j], 1 + dp[i-1][j-1]);
        }
      }
    }
    if (dp[n-1][n-1] == numeric_limits<int>::max() / 2) {
      return -1;
    } else {
      return dp[n-1][n-1];
    }
  }
};
```
A better solution would be to build a _graph_ and perform a breadth first search since all the edge weights are equal. We will use level order traversal of the graph to get this done. Every time we finish a level we will increase our distance by $1$.
#aside[
  I'm still a novice when it comes to c++ so there are many things that I need to hash out before I can write clean and efficient c++ code.
]
```c
int shortestPathBinaryMatrix(vector<vector<int>>& grid) {
  unordered_map<long long, vector<pair<int,int>>> graph = this->buildGraph(grid);
  // We can just run a bfs since we all the edge weights are going to be 1.
  queue<pair<int,int>> grid_queue;
  int n = grid.size();
  grid_queue.push({0,0}); // Push the root node in our graph
  unordered_set<long long> visited;
  int dist = 1;
  if (grid[0][0] == 1 || grid[n - 1][n -1] == 1) {
    return -1;
  }

  while (grid_queue.size() > 0) {
    queue<pair<int,int>> level;
    int level_size = grid_queue.size();
    for (int i = 0; i < level_size; i ++) {
      pair<int,int> curr = grid_queue.front();
      grid_queue.pop();
      if (visited.find(key(curr.first, curr.second)) != visited.end()) {
        continue;
      }
      visited.insert(key(curr.first, curr.second));
      if (curr.first == n - 1 && curr.second == n - 1) {
        return dist;
      }
      const auto &neighbors = graph[key(curr.first, curr.second)];
      for (const auto& neighbor: neighbors) {
        if (visited.find(key(neighbor.first, neighbor.second)) != visited.end()) {
          continue;
        }
        grid_queue.push(neighbor);
      }
    }
    dist += 1;
  }
  return -1;
}
```
