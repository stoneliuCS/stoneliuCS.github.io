#metadata((
  title: "text justification",
  date: "2026-07-10",
)) <post-meta>

#link("https://leetcode.com/problems/text-justification/description/")[Problem] goes like this, we get a list of words and integer representing the maximum width for each line.

1. Format the words such that each line has exactly `maxWidth` characters and is fully left and right justified.
2. Pack as many words as we can on each line (greedy) and should pad extra spaces to fit the maximum characters as needed.
3. Extra spaces between words must be _distributed_ as evenly as possible. If it does not divide evenly then the number of empty spaces on the left must be more than on the right.
4. Finally, for the last line of text it should be _left-justified_ with no extra space inserted between them.

Okay so this seems to be a very interesting problem. The first thing that I can think of is 
