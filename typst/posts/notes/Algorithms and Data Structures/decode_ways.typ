#metadata((
  title: "Decode Ways",
  date: "2026-07-24",
)) <post-meta>

#link("https://leetcode.com/problems/decode-ways/description/")[Problem] goes like this...

We have a standard mapping of numbers ranging from $(1,26)$ inclusive to the letters of the english alphabet. But there are numerous ways to represent a decryption. For example, the number $11106$ can be decrypted as $1,1,10,6$ or $11, 10, 6$. We want to be able to return the number of ways we can decrypt the given numeric string.

So the first thing that sticks out to me is that we can essentially build a decision tree. At the very first step we can choose to take the first digit or skip and take the next digit. We are however limited to only well formed numeric digits. Since we don't care about the actual decrypted message, just the number of ways we can decrypt it, we can keep track of an index into our string.

```
This is our input string
s = "11106"

We can either choose to pick 1, or 11. If the resulting decision leads up to be invalid such as 06 then we terminate that branch. Each branch is only valid if the branch terminates at the end of the string without violating any possible decryption rule. At the end we can sum up all the terminal nodes which contribute a single valid decryption of the input string.
```

Since the state of our decision tree only involves looking either at the current index or $"index" + 1$ and terminating a branch we can cache subsequent calls by our index key. This is called #link("https://en.wikipedia.org/wiki/Memoization")[Top Down Memoization].

```java
class Solution {
  private boolean isValid(String digits) {
    if (digits.startsWith("0")) {
      return false;
    } else if (Integer.parseInt(digits) > 26) {
      return false;
    }
    return true;
  }

  private int backtrackWrapper(String s, int i, HashMap<Integer,Integer> cache) {
    if (cache.containsKey(i)) {
      return cache.get(i);
    } else {
      int res = this.backtrack(s, i, cache);
      cache.put(i, res);
      return res;
    }
  }

  private int backtrack(String s, int i, HashMap<Integer,Integer> cache) {
    if (i == s.length()) {
      return 1;
    }
    String decisionOne = s.substring(i, i + 1);
    int numberOfWays = 0;
    if (this.isValid(decisionOne)) {
      numberOfWays += this.backtrackWrapper(s, i + 1, cache);
    }
    if (i + 1 < s.length()) {
      String decisionTwo = s.substring(i, i + 2);
      if (this.isValid(decisionTwo)) {
        numberOfWays += this.backtrackWrapper(s, i + 2, cache);
      }
    }
    return numberOfWays;
  }
  public int numDecodings(String s) {
    HashMap<Integer, Integer> cache = new HashMap<>();
    return this.backtrackWrapper(s, 0, cache);
  }
```

With the subsequent test cases here...
```java
  public static void main(String[] args) {
    Solution sol = new Solution();
    // Test 1
    String s = "0";
    int actual = sol.numDecodings(s);
    System.out.println("s = 0");
    System.out.println(actual == 0);
    System.out.println();

    // Test 2
    s = "06";
    actual = sol.numDecodings(s);
    System.out.println("s = 06");
    System.out.println(actual == 0);
    System.out.println();

    // Test 3
    s = "6";
    actual = sol.numDecodings(s);
    System.out.println("s = 6");
    System.out.println(actual == 1);
    System.out.println();

    // Test 4
    s = "66";
    actual = sol.numDecodings(s);
    System.out.println("s = 66");
    System.out.println(actual == 1);
    System.out.println();

    // Test 5
    s = "12";
    actual = sol.numDecodings(s);
    System.out.println("s = 12");
    System.out.println(actual == 2);
    System.out.println();

    // Test 6
    s = "226";
    actual = sol.numDecodings(s);
    System.out.println("s = 226");
    System.out.println(actual == 3);
    System.out.println();

    // Test 7
    s = "2206";
    // 2, 20, 6
    actual = sol.numDecodings(s);
    System.out.println("s = 2206");
    System.out.println(actual == 1);
    System.out.println();

    // Test 8
    s = "0671";
    actual = sol.numDecodings(s);
    System.out.println("s = 0671");
    System.out.println(actual == 0);
    System.out.println();

    // Test 9
    s = "808";
    actual = sol.numDecodings(s);
    System.out.println("s = 808");
    System.out.println(actual == 0);
    System.out.println();
  }
}
```
Here I use a similar technique to what I did with #link("/2026/07/12/reg-exp-matching.html")[Regular Expression Matching]. This technique is called mutually recursive function definitions. I use the outer most function to store the work performed on the inner function call in a table.
