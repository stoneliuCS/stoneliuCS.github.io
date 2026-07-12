#metadata((
  title: "reg exp matching",
  date: "2026-07-12",
)) <post-meta>

#link("https://leetcode.com/problems/regular-expression-matching/description/")[Problem] starts with the following...

We are given two strings $s$ and $p$ and we want to be able to match $s$ and $p$ given two special rules:
1. "." matches any single character.
2. "\*" matches zero or more of the preceding element.

Okay so this isn't so bad... It's a lot simpler than typical regular expression matching since we only implement $2$ rules. Let's work through some test cases _(We will allow the left string to be p and the right string to be s)_.

```
a = a // Of course these match
a* = a // These must match
a*a != a // We need two as
a*a == aaaa...a // This can match any number of atleast two as.
a.a == aba // . can replace any character.
```
Hm, so the hard part will be this "\*" operator since we can match zero or more times. This is pretty tricky, but it kind of reminds me of a state machine. I have never really implemented a state machine before so I'm not really sure where to begin. We probably need two pointers. One pointer for each string. Take for example...

```
a*a == aa
i -> p
j -> s
// We match a = a and we consume it!
// We see * and a, obviously this is acceptable but we if increment again we are out.
```
Hmm... So the problem lies in the fact that we need to be able to match any amount of the preceeding character when we encounter a "\*". We should create a DFA _(Deterministic Finite Automata)_ but the problem is that we are given any arbitrary pattern. Could we potentially do a decision tree? This could be quite expensive but what we could do is have a particular state $(i,j)$ where $i$ and $j$ represent our pointers to our strings. The decision tree rules are as follows:

1. if we have no more pattern to match and we still have input string to match we can return `false`.
2. if we are both out of pattern and input then we can return `true`
3. if we are out of input string but still have the pattern we can match if the pattern we have is $*$.
4. If we have both then we need to match with the following:
  - if `s[i]` and `p[j]` are alphabetical then match only if they are equal and increment. (backtrack)
  - if `p[j] == '.'` then match and increment both. (backtrack)
  - if `p[j + 1] == '*'` then we need to branch out:
    - One match by doing nothing
    - Another match by checking if `p[j] == .` and then recurring on `s[i+1]` but fix `j`.
    - Another match by checking if `p[j] == s[i]`
    - All ORed together by the empty clause.

A few problems that I realized, it's useful to cache our values in a memoization table since that will allow us to prevent memory overflow errors (from the recursive calls). C++ requires forward declaration of function calls since we are using mutally recursive function definitions.

```c
bool backtrackImpl(const string& s, const string& p, int i, int j,
                   vector<vector<optional<bool>>>& memo); 

bool backtrack(const string& s, const string& p, int i, int j,
               vector<vector<optional<bool>>>& memo);

bool backtrack(const string& s, const string& p, int i, int j, vector<vector<optional<bool>>>& memo) {
  if (memo[i][j]) {
    return memo[i][j].value();
  }
  bool val = backtrackImpl(s,p,i,j,memo);
  memo[i][j] = val;
  return val;
}

bool backtrackImpl(const string& s, const string& p, int i, int j, vector<vector<optional<bool>>>& memo) {
  if (i < s.size() && j < p.size()) {
    char s_symb = s[i];
    char p_symb = p[j];
    // Guranteed for a valid character to precede a '*'.
    if (j + 1 < p.size() && p[j + 1] == '*') {
      // Run backtrack but if anyone of these match then we are good.
      // Case 1: Empty Match, consume both characters
      bool empty_match = backtrack(s,p,i, j + 2, memo);
      // Case 2: Match on one char of the prev
      if (p_symb == '.') {
        return empty_match || backtrack(s,p, i + 1, j, memo);
      }   
      return empty_match || p_symb == s_symb && backtrack(s,p,i+1,j, memo);
    }
    if (p_symb == '.') {
      return backtrack(s, p, i + 1, j + 1, memo);
    }
    return s_symb == p_symb && backtrack(s,p,i+1,j+1, memo);
  } else if (i < s.size() && j == p.size()) {
    return false;
  } else if (i == s.size() && j < p.size()) {
    if (j + 1 < p.size() && p[j + 1] == '*') {
      return backtrack(s,p,i,j+2, memo);
    } else {
      return false;
    }
  } else {
    return true;
  }
}

bool isMatch(string s, string p) {
  vector<vector<optional<bool>>> memo(s.size() + 1, vector<optional<bool>>(p.size() + 1));
  return backtrack(s,p,0,0, memo);
}
```
