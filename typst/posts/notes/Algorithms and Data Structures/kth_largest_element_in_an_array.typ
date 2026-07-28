#metadata(
  (
    title: "kth largest element in an array",
    date: "2026-07-28",
  ),
) <post-meta>

#import "../../../lib/web.typ": aside

#link("https://leetcode.com/problems/kth-largest-element-in-an-array/description/")[Problem] goes like this...

We want to be able to find the _Kth_ largest element in an _unsorted array_.

#aside[
  Note that I did not think of this algorithm on the spot, this was something that I did not even know existed...
]

Okay... Easy enough to understand. The very first thought would be to simply sort the array. But that would take on average $n log(n)$ time complexity. An efficient implementation of doing this would probably have to be using the _quickselect_ item. It is very reminiscient of the quick-sort algorithm which utilizes something called a _pivot_ index. The pivot is usually randomly chosen and then something called a partition is called which will group the numbers smaller than the pivot on the left and the numbers greater than the pivot on the right. Doing so gurantees that the pivot is in its proper sorted position. Quicksort will do this on the left and right side recursively resulting in the array being entirely sorted but for our purposes we can just recur on which ever side contains the index $k$.

== Partitioning
Say we have an array of numbers from $[4,1,2,8,6,1]$. The sorted order of this array would be $[1,1,2,4,6,8]$. If we choose some pivot say $i = 0$ that would mean that need to find the correct position of the $0$th index of the array which would be $4$. We start by swapping $4$ to the end of the array and subsequently swapping all the numbers that are less than $4$ in the array to its left.

```
[4,1,2,8,6,1], i = 0.
[1,1,2,8,6,4] // First swap, left = 0, right = 5
[1,1,2,6,8,4] // left = 3 and right = 4.
[1,1,2,4,8,6] // 4 is now in the correct position and all the numbers to the left are smaller than it, and all the numbers to the right are larger.
```

#aside[
  This particular implementation is simpler but does not fair very well against duplicate elements.
]
```java
private int partition(int[] nums, int l, int r, int rand) {
  // Identify the random index
  int pivot = nums[rand];
  int end = nums[r];

  // Swap the value of the pivot to the end.
  nums[r] = pivot;
  nums[rand] = end;
  int left = l;

  for (int i = left; i < r; i ++) {
    if (nums[i] <= pivot) {
      int idxVal = nums[i];
      int leftVal = nums[left];
      nums[i] = leftVal;
      nums[left] = idxVal;
      left += 1;
    }
  }
  int temp = nums[left];
  nums[left] = nums[r];
  nums[r] = temp;
  return left;
}
```
Once we find the correct pivot index, we can just check to see if the index is greater than, equal to, or less than $k$. If it is greater than, then we know that $k$ must be in the left half of the list. If it is less than we must look at the right half of the list. If it is equal to then we have found $k$. One thing to note is that the algorithm is usually intended for finding the smallest element in the list. If we substract the length of the list by $k$ then we can find the greatest element.

#aside[
  A simpler solution involves using a minHeap.
  ```java
public int findKthLargest(int[] nums, int k) {
  PriorityQueue<Integer> minHeap = new PriorityQueue<>();
  for (int i = 0; i < nums.length; i++) {
    if (minHeap.size() < k) {
      minHeap.offer(nums[i]);
    } else if (minHeap.peek() < nums[i]) {
      minHeap.poll();
      minHeap.offer(nums[i]);
    }
  }
  return minHeap.peek();
}
  ```

]
```java
private int select(int[] nums, int l, int r, int k) {
  if (l == r) {
    return nums[l];
  }
  Random random = new Random();
  int rand = random.nextInt(l, r);
  // Partition the list nums
  int pivotIdx = partition(nums, l, r, rand);

  if (pivotIdx == k) {
    return nums[pivotIdx];
  } else if (k > pivotIdx) {
    return select(nums, pivotIdx + 1, r, k);
  } else {
    return select(nums, l, pivotIdx - 1, k);
  }
}

public int findKthLargest(int[] nums, int k) {
  int l = 0;
  int r = nums.length - 1;
  return select(nums, l, r, nums.length - k);
}
```
