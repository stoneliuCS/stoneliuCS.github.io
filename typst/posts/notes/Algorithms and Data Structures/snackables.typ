#metadata((
  title: "Snackables",
  date: "2026-07-06",
)) <post-meta>

== Zigzag Problem
A tuple $(a,b,c)$ is a _zigzag_ if it satisfies one of these conditions
- $a < b > c$
- $a > b < c$

The goal is to construct a binary array for each consecutive triplet where:
- $1$ represents that triplet is a zig zag.
- $0$ represents that triple is not a zig zag. 

Pretty tame problem just scan every triplet pair and check if they satisfy the constraints of the problem.

```c
bool check_zigzag(int a, int b, int c) {
  return ((a < b) && (b > c)) || ((a > b) && (b < c));
}

vector<int> solution(vector<int> numbers) {
  int n = numbers.size();
  vector<int> zigzags(n - 2);

  for (int i = 0; i < n - 2; i ++) {
    // zig zag
    bool is_zigzag = check_zigzag(numbers[i], numbers[i + 1], numbers[i + 2]);
    if (is_zigzag) {
      zigzags[i] = 1;
    } else {
      zigzags[i] = 0;
    }
  }
  return zigzags;
}
```
If we run through a few examples like such
```
[1,2,1,3,4]
-> (1,2,1) is definitely a zig zag.
-> (2,1,3) is definitely a zig zag.
-> (1,3,4) is not a zig zag.
==> [1,1,0]

[1,2,3,4]
-> (1,2,3) is not a zig zag.
-> (2,3,4) is not a zig zag.
===> [0,0].
```
Easy enough!

== Sum of Digits

Problem is simple enough, given some two digit integer $n$ return the sum of its digits. Usually I am tempted to just convert this to a string and do it that way but there is a much simpler way we can get the digits of a number using modular arthimetic. 

For example $29$, taking it modulo $10$ will give us the first digit $9$ since $29 mod 10 equiv 9$. To get the leading digit we can simply do integer division by $10$. So $29 / 10 = 2$.

```c
int solution(int n) {
  int last_digit = n % 10;
  int first_digit = n / 10;
  return first_digit + last_digit;
}
```

== Two Sum
Ah the classic #link("https://leetcode.com/problems/two-sum/")[two sum] problem. We are given an array of numbers and a target. We want to return the indicies of the _two_ numbers such that they add up to target.

We want to do this in linear time worse case, which means that the natural solution is to use a hashmap. We can hash the number as the key and its index as its value. Then all we would have to do is check if its complement exists in the hashmap and if it does return them both.
```
[2,7,11,15] with a target = 9
// Clearly the indexes of the two numbers are 0 and 1 since 2 + 7 = 9.
// Build the map:
{
  2 : 0,
  7 : 1,
  11 : 2,
  15 : 3
}
// 9 - 2 = 7, 7 exists within the map, return its index and 0.
```
One question is if all the values in the input array are unique. But since they gurantee as an invariant that there will always be a unique solution it should be okay to assume that they can be.

```c
vector<int> twoSum(vector<int>& nums, int target) {
  int n = nums.size();
  unordered_map<int, int> lookups;

  for (int i = 0; i < n; i++) {
    int num = nums[i];
    lookups[num] = i;
  }

  for (int i = 0; i < n; i ++){
    int num = nums[i];
    int complement = target - num;

    if (lookups.find(complement) != lookups.end() && lookups[complement] != i) {
      return vector<int>{i, lookups[complement]};
    }
  }
  return vector<int>{};
}
```
