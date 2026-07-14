#metadata((
  title: "mergesort",
  date: "2026-07-14",
)) <post-meta>

The merge sort algorithm goes as follows. It is a divide and conquer algorithm, meaning that it will repeatedly divide the problem into smaller _sub-problems_, merging individual sub-problems into larger sub problems (conquering).

Take for example the following list:

```
[30,50,10,90]
// Split into two halves
[30,50], [10, 90]
// Split again into two halves
[30], [50], [10], [90]
// Every individual one is sorted so we merge
[30,50], [10,90]
// Merge these again. Using a pointer and a temporary array. X represents a spot to be filled in
temp = [X,X,X,X]
// Take two pointers and third pointer into our temp array and compare compare. i = 0, j = 0, k = 0.
[30,50][0] = 30, [10,90][0] = 10, 10 < 30, temp[0] = 10.
// Increment j += 1 and k += 1.
[30,50][0] = 30, [10,90][1] = 90. 30 < 90, temp[1] = 30.
// Increment i += 1 and k += 1.
[30,50][1] = 50, [10,90][1] = 90. 50 < 90, temp[2] = 50.
// Increment i += 1 and k += 1. Fill in the remaining slot with 90.
temp = [10,30,50,90]
```
Since we split in half every single time, the most we will ever divide is $log_2(n)$ times. We can potentially do worse case $n$ merges in the worse case. So overall the time complexity is $n log(n)$.

```c
vector<int> merge(vector<int> &left, vector<int> &right) {
  int i = 0;
  int j = 0;
  int k = 0;
  vector<int> res(left.size() + right.size());

  while (k < res.size()) {
    if (i < left.size() && j < right.size()) {
      int left_val = left[i];
      int right_val = right[j];

      if (left_val < right_val) {
        res[k] = left_val;
        i++;
      } else {
        res[k] = right_val;
        j++;
      }
    } else if (i < left.size()) {
      res[k] = left[i];
      i++;
    } else {
      res[k] = right[j];
      j++;
    }
    k++;
  }
  return res;
}

vector<int> mergesort(vector<int> & nums) {
  int n = nums.size();
  if (n == 1) {
    return nums;
  }

  // Divide...
  auto mid = nums.begin() + nums.size() / 2;

  vector<int> left(nums.begin(), mid);
  vector<int> right(mid, nums.end());

  vector<int> sorted_left = mergesort(left);
  vector<int> sorted_right = mergesort(right);

  // Conquer...
  return merge(sorted_left, sorted_right);
}
```
