#metadata((
  title: "reorg string",
  date: "2026-07-23",
)) <post-meta>
#import "../../../lib/web.typ": aside

#link("https://leetcode.com/problems/reorganize-string/description/")[Problem] goes like this...

Given a string `s`, we want to _rearrange_ the characters of the string `s` such that any two adjacent characters are not the same. We can return any possible rearrangement of `s` or the `""` if its not possible.

This sounds pretty interesting, lets work through some examples...

```java
String s = "aab";
// Expected that we would put the string as "aba"
String s = "aaa"
// We cannot rearrange this string so therefore we return the empty string ""
String s = "abba"
// We can return "abab"
```

#aside[
  Okay this is not true, since this
  ```
  s = "ababac"
  map = {
    "a" : 3,
    "b" : 1,
    "c" : 1
  }
  ```
  can be rearranged as such...
]

Now the problem states that we can return any possible rearrangement of `s`. Which means that ideally what we can do is create a counter for every single character and its frequency in a hashmap. That will give us the characters we can use. I noticed that for a given string `s`, its possible to rearrange its characters in this manner if and only if the differences between each of the character frequencies is no greater than 1.

The algorithm now is we would need to be able to go through our remaining characters and build a string such that no two characters overlap. We could do this pairwise? Start with the frequency that is the highest and pair them off one by one.
```
map = {
  "a" : 3,
  "b" : 3,
  "c" : 1,
  "d" : 4
}
d a d b d a d b c a b
```
But we would also need to be able to scan every single unique character in the hashmap and check if its the largest. In otherwords we can alternate between the letters.

```java
public String[] getAlternatingPairs(Map<String, Long> freqMap) {
  List<Map.Entry<String,Long>> sortedList = new ArrayList<>(freqMap.entrySet());
  sortedList.sort((a,b) -> b.getValue().compareTo(a.getValue()));
  String first = sortedList.size() > 0 ? sortedList.get(0).getKey() : null;
  String second = sortedList.size() > 1 ? sortedList.get(1).getKey() : null;
  return new String[]{first, second};
}

public String reorganizeString(String s) {
  Map<String, Long> freqMap = s.chars()
    .mapToObj(c -> String.valueOf((char) c))
    .collect(Collectors.groupingBy(
      Function.identity(),
      Collectors.counting()
    ));

  String res = "";

  while (res.length() != s.length()) {
    // Alternate pairwise on the string.
    String[] pair = getAlternatingPairs(freqMap);
    String first = pair[0];
    String second = pair[1];
    // Consume the first string
    if (first != null) {
      res += String.valueOf(first);
      freqMap.computeIfPresent(first, (k, v) -> v - 1);
      if (freqMap.get(first) <= 0) {
        freqMap.remove(first);
      }
    }

    // Consume the second string
    if (second != null) {
      res += String.valueOf(second);
      freqMap.computeIfPresent(second, (k, v) -> v - 1);
      if (freqMap.get(second) <= 0) {
        freqMap.remove(second);
      }
    }

    if (res.length() >= 2 && res.charAt(res.length() - 1) == res.charAt(res.length() - 2)) {
      return "";
    }
  }
  return res;
}
```
This is a pretty ugly function definition but it simply processes the two most frequent pairs of elements at once and appends them in alternating order. Here are some of my test cases:

#aside[
  The optimal solution here would be maintaining a max heap. Will code that up next time if I see a similar pattern!
]
```java
public static void main(String[] args) {
  // Test 1
  String s1 = "s";
  Solution sol = new Solution();
  String actual1 = sol.reorganizeString(s1);
  System.out.println(actual1.equals("s"));
  System.out.println(sol.reorganizeStringProp(actual1));

  // Test 2
  String s2 = "ass";
  String actual2 = sol.reorganizeString(s2);
  System.out.println(actual2.equals("sas"));
  System.out.println(sol.reorganizeStringProp(actual2));

  // Test 3
  String s3 = "ssa";
  String actual3 = sol.reorganizeString(s3);
  System.out.println(actual3.equals("sas"));
  System.out.println(sol.reorganizeStringProp(actual3));

  // Test 4
  String s4 = "ssaa";
  String actual4 = sol.reorganizeString(s4);
  System.out.println(actual4.equals("asas"));
  System.out.println(sol.reorganizeStringProp(actual4));

  // Test 5 with an impossible string
  String s5 = "ss";
  String actual5 = sol.reorganizeString(s5);
  System.out.println(actual5.equals(""));
  System.out.println(sol.reorganizeStringProp(actual5));

  // Test 6
  String s6 = "ssbbs";
  String actual6 = sol.reorganizeString(s6);
  System.out.println(actual6.equals("sbsbs"));
  System.out.println(sol.reorganizeStringProp(actual6));

  // Test 7
  String s7 = "sssb";
  String actual7 = sol.reorganizeString(s7);
  System.out.println(actual7.equals(""));
  System.out.println(sol.reorganizeStringProp(actual7));
}
```

