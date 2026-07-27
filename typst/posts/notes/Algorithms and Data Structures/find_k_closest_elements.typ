#metadata((
  title: "find k closest elements",
  date: "2026-07-25",
)) <post-meta>

#import "../../../lib/web.typ": aside

#link("https://leetcode.com/problems/find-k-closest-elements/description/")[Problem] goes like this...

We have a sorted int array, and we have two integers `k` and `x`. We want to return the `k` closest integers to `x` in the array. The output should also be sorted in ascending order.

By definition, an integer `a` is closer to `x` then an integer `b`:
1. $|a - x| < |b - x|$ or
2. $|a - x| == |b - x|$ and $a < b$. _The tie breaker_.

Lets walk through some examples...

```
arr = [1,1,2,5,6,9], k = 3, x = 9
// In plain english this means return the 3 closest numbers to 9 in arr.
// The array is sorted... which tells me that I could potentially use binary search to find these elements.
// Since the array is sorted, naturally won't the closest elements fall within 9? Meaning that we can just take a// two pointer approach and compare them side by side.
// We compare integers from both the left and right of 9.
// In this case it would be just 2, 5, 6.
// Then we can use a deque! A deque enables pushing and popping on both ends really efficiently. That will help
// us maintain the order of the elemetns.

// If x = 5 and k = 3 then
// deque = []
// compare 2 and 6, clearly 6 is better since 6 - 5 = 1. Move right pointer by 1.
// deque = [6]
// compare 2 and 9, 2 is better so append to the front. Move left pointer by 1 to the left.
// deque = [2,6]
// compare 1 and 9 to 5, 5 - 1 =4, and 9 - 5 = 4 but 1 < 9 so we take 1. Append 1 to the front.
// deque = [1,2,6] -> Done!
```
#aside[Oh wait, the number isn't guranteed to be within the array... I misread the problem wrong. We should definitely be using binary search since the array is sorted but now im thinking...]

Okay scratch that algorithm, what we need to do is to be able to binary search and find the kth closest element to some element $x$. There should be some $k$ sized window within `arr` that contains the $k$ closest elements. We start at `l = 0` and `r = len(arr) - k`. Then we check at every single iteration at `arr[mid]` and `arr[mid + k]`, which is the first element in our window with the next element outside of the window. If it is closer then we shift our window to the right if not

```
arr = [1,1,2,2,2,2,2,3,3], k = 3, x = 3
l = 0
r = 9 - 3 = 6
mid = 6 + 0 // 2 = 3

3 + 3 = 6. From mid to mid + 3 = 6 => arr[3] vs arr[6] is 2 vs 2. They are the same. a is to the left and b is to the right. Notice though that x is 3 so therefore a - x vs b - x since a is further left and b is further right.
```

Expected run time, our bounds are limited to $n - k$ elements so binary search on those will be $log(n - k)$.

```java
private int check(int a, int b, int x) {
  if (Math.abs(a - x) == Math.abs(b - x)) {
    if (a < b) {
      return a;
    } else {
      return b;
    }
  } else if (Math.abs(a - x) < Math.abs(b - x)) {
    return a;
  } else {
    return b;
  }
}

public List<Integer> findClosestElements(int[] arr, int k, int x) {
  int left = 0;
  int right = arr.length - k;

  while (left < right) {
    int mid = (left + right) / 2;
    int a = arr[mid];
    int b = arr[mid + k];
    if (a == b) {
      if (x > a) {
        left = mid + 1;
      } else {
        right = mid;
      }
    } else if (this.check(a,b,x) == a) {
      // a is closer move left
      right = mid;
    } else {
      left = mid + 1;
    }
  }
  return Arrays.stream(arr, left, left + k).boxed().collect(Collectors.toList());
}
```
