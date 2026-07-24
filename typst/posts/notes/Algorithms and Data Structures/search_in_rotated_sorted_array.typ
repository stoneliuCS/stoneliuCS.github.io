#metadata((
  title: "search in a rotated sorted array",
  date: "2026-07-24",
)) <post-meta>

#import "../../../lib/web.typ": link-post

#link("https://leetcode.com/problems/search-in-rotated-sorted-array/description/")[Problem] goes like this...

We have a possibly left rotated array which just means that the elements are wrapped around back to the left after a shift. I call it a _left shift_ of sorts. So an example of a left rotated array after being shifted $3$ times would be
$ [1,2,3,4,5,6,7] -> [5,6,7,1,2,3,4] $
Okay simple enough. Now I need to be able to find a `target` value's index or $-1$ if not found. The time complexity is a huge hint since there is really only one algorithm that I know of that runs in $log(n)$ time. That would be binary search. Now binary search only works on sorted arrays however we would still need to be able to perform binary search on this array. The one key thing is that for any left rotated array, it must be the case that _(unless its sorted)_ there must be a pivot where everything to the left of the pivot is in descending order and everything to the right is in ascending order.

```
array = [5,6,7,1,2,3,4], target = 4

// Normal binary search would have mean intitalize a left and right pointer to my array.
left = 0
right = 6
mid = 3
// array[3] = 1. The thing is I need to know if I am at a pivot! Because if I am, then I can safely determine if I can drop my left or right pointers.

// Perhaps I can compare my left and right pointers? If left val > right val what does that tell me? That means that the pivot is still within our search range.
// Hmm... Lets start with the simple case... Our array is sorted in ascending order. That means we have
// [1,2,3,4,5,6,7]
// Obviously this is when we would use the typical binary search method, if our left < right pointer then that means we are guranteed that we can perform binary search on those indexes.
// If our left > right pointer then maybe we would have to check our left and right values against the target. Which ever one is larger or smaller than the target would we increment.

a = [5,6,7,1,2,3,4]
l = 0
r = 6
m = 3
target = 2
a[l] = 5
a[r] = 4
a[m] = 1
a[m] != 1 so we need to binary search.
Since a[l] < a[r] and a[l] > target that means that there must be a pivot somewhere. We can toss out half of the left array.

l = 3
r = 6
target = 2
At this point this would be standard binary search.
```

Essentially the algorithm breaks down into the following...
1. If the values at `l` and `r` are $l < r$ then we can perform standard binary search.
2. Else, check if the subarray from l to mid is sorted, if it is check if the target is in there else toss it.
3. Symmetrically on the right side as well.

I realized that the key insight here is that we are really binary searching on the portions of the array that have the target in it and are sorted, since there are portions of the array that are sorted after all!
```java
public int search(int[] nums, int target) {
  int n = nums.length;
  int l = 0;
  int r = n - 1;
  while (l <= r) {
    int mid = (l + r) / 2;
    if (nums[mid] == target) {
      return mid;
    } else if (nums[l] < nums[r]) {
      // This is standard binary search
      if (nums[mid] > target) {
        r = mid - 1;
      } else {
        l = mid + 1;
      }
    } else {
      // Unique case, the pivot is contained somewhere in here.
      if (nums[l] <= nums[mid]) {
        // Left half is sorted
        if (target >= nums[l] && target <= nums[mid]) {
          // Target is in this sorted half
          r = mid - 1;
        } else {
          l = mid + 1;
        }
      } else {
        if (target >= nums[mid] && target <= nums[r]) {
          l = mid + 1;
        } else {
          r = mid - 1;
        }
      }
    }
  }
  return -1;
}
```

This is just a more advanced spin on the problem I have done #link-post("snackables", [here], anchor: "guess-number-higher-or-lower").
