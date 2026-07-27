#metadata((
  title: "encode and decode strings",
  date: "2026-07-27",
)) <post-meta>

#import "../../../lib/web.typ": aside
#link("https://leetcode.com/problems/encode-and-decode-strings/description/")[Problem] goes like this...

We want to design an algorithm that can encode a `list` of `string` into a single `string`. The decoding algorithm can then take that
single `string` and then decode that into the list of strings back. This is a pretty interesting challenge since the key part that makes this tricky is the fact that the encoded and decoded strings have all the valid ASCII encodings.

My first thought was that I could somehow utilize a delimiter such as a `$` or `#` to signal a break in the strings. But what if the problem was that the string itself contained the `#` or `$` special character? Then I would have no way of telling whether this is the string itself or whether or not this is the delimiter. Could I maybe perhaps add more information like a number to it? If that is the case, I could append a number to the beginning of the string everytime I see it, that way I can just jump ahead of time and I will know that is the exact string that I have.

```
strs = ["Hello", "World"]
// Encryption just involves prepending the length of the string to the actual string.
encoded = "5Hello5World"
// Decryption Process
strs = ["Hello", "World"]
// Just create a pointer into the string and then each time read the number, jump that many places into the encoded string and read the next number. Each time you would record that string into the decoded array.
```
#aside[I chose the delimiter "\#" but really you can go with any kind of delimiter here.]

I realized that there is a slight problem with this current algorithm and that is that we probably want an artificial delimiter after we pre-append the number into our string. This is because if we have a for example a decryption of the following string `12345`. How do we know if either number is the length of the string? We would need something like a delimiter guranteed after a number to seperate out any possible edge cases.

```java
class Solution {
  public static boolean isNumeric(String str) {
      if (str == null || str.isEmpty()) {
          return false;
      }
      try {
          Double.parseDouble(str);
          return true;
      } catch (NumberFormatException e) {
          return false;
      }
  }

  public String encode(List<String> strs) {
    StringBuilder encoding = new StringBuilder();
    for (String str : strs) {
      String encodingString = String.valueOf(str.length()) + "#" + str;
      encoding.append(encodingString);
    }
    return encoding.toString();
  }

  public List<String> decode(String str) {
    int ptr = 0;
    List<String> decoding = new ArrayList<String>();
    while (ptr < str.length()) {

      String sizeString = "";
      int ptr_int = ptr;
      while (!str.substring(ptr_int, ptr_int + 1).equals("#")) {
        sizeString += str.substring(ptr_int, ptr_int + 1);
        ptr_int += 1;
      }
      ptr = ptr_int;
      int size = Integer.valueOf(sizeString);
      String decoded = str.substring(ptr + 1, ptr + size + 1);
      decoding.add(decoded);
      ptr = ptr + size + 1;
    }
    return decoding;
  }
}
```
