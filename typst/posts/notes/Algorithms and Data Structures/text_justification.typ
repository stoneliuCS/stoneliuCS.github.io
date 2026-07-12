#metadata((
  title: "text justification",
  date: "2026-07-11",
)) <post-meta>

#link("https://leetcode.com/problems/text-justification/description/")[Problem] goes like this, we get a list of words and integer representing the maximum width for each line.

1. Format the words such that each line has exactly `maxWidth` characters and is fully left and right justified.
2. Pack as many words as we can on each line (greedy) and should pad extra spaces to fit the maximum characters as needed.
3. Extra spaces between words must be _distributed_ as evenly as possible. If it does not divide evenly then the number of empty spaces on the left must be more than on the right.
4. Finally, for the last line of text it should be _left-justified_ with no extra space inserted between them.

Okay so this seems to be a very interesting problem. The first thing that I can think of is to just step through some examples.

```
words = [this, is, an, example, of, text, justification.]
maxWidth = 16

# First list we will keep appending words until we cannot anymore.

"this" # 4 characters
"this is" # 7 characters
"this is an" # 10 characters
"this is an example" # Greater than 16 characters

"this is an      " # Pad the word until we have maxWidth length.
# Now there are two gaps between the words, one is between this is and the other between is an.
# What we can do is increase the gaps?
```
Damn I'm already kinda stuck here since the padding between each word needs to be as even as possible. Perhaps I can maintain a seperate array to represent the gaps between words? It would go like this:
```
gaps = []
""
# Add "this" and there are no gaps
gaps = []
"this"

# Add "is", add a single 1 to represent the space between this is.
gaps = [1]
"this is"

# Add "an", add a single 1 again to represent the space between is an.
gaps = [1,1]
"this is an"

# Now we need to pad these spaces such that we reach the width limit. This is easy since 2 divides 10 we increase each by 5.

"this     is     an"
```
What about the odd case where we have say $3$ gaps? 
```
gaps = [1,1,1]
"this is a do"
# 3 does not divide 4. It seems that we can just incrementally add these gaps going from left to right.

gaps = [3,2,2]
"this   is  a  do"
```
In pseudo-code essentially what we want to do is...
1. Greedily pack each word into a line until we cannot anymore
2. Between each word we insert a blank space
3. Increase each blank space until we cannot anymore (From left to right).

```c
int countWords(vector<string>& words) {
  int count = 0;

  for (const auto &word: words) {
    count += word.size();
  }
  return count;
}

string backToString(vector<string>& words) {
  string word = "";

  for (int i = 0; i < words.size(); i ++) {
    word += words[i];
  }
  return word;
}


tuple<string,int,vector<string>> greedyAppend(int idx, vector<string>& words, int maxWidth) {
  vector<string> justifiedLine;
  int currSize = 0;
  int i = idx;
  // 1: Greedily append each line until we cannot fit anymore.
  while (currSize < maxWidth && i < words.size()) {
      if (currSize + words[i].size() <= maxWidth) {
        justifiedLine.push_back(words[i]);
        currSize += words[i].size() + 1;
        i++;
      } else {
        break;
      }
  }
  vector<string> finalJustifiedLine;
  vector<int> spaces;

  // 2: Take each word in justified line and add a space between them.
  if (justifiedLine.size() == 1) {
    finalJustifiedLine.push_back(justifiedLine[0]);
    if (countWords(finalJustifiedLine) != maxWidth) {
      finalJustifiedLine.push_back(" ");
      spaces.push_back(finalJustifiedLine.size() - 1);
    }
  } else {
    for (int index = 0; index < justifiedLine.size(); index++) {
      finalJustifiedLine.push_back(justifiedLine[index]);
      if (index != justifiedLine.size() - 1) {
        finalJustifiedLine.push_back(" ");
        spaces.push_back(finalJustifiedLine.size() - 1);
      }
    }
  }
  
  // 3: Greedily distribute the spaces until we reach the maxWidth
  int currentSize = countWords(finalJustifiedLine);

  while (currentSize < maxWidth) {
    for (const auto index : spaces) {
      if (currentSize < maxWidth) {
        finalJustifiedLine[index] = finalJustifiedLine[index] + " ";
        currentSize += 1;
      } else {
        break;
      } 
    }
  }
  return tuple<string, int, vector<string>>{backToString(finalJustifiedLine), i, justifiedLine};
}

string justifyFinalLine(vector<string> & words, int maxWidth) {
  string line = "";
  int idx = 0;

  while (line.size() < maxWidth) {
    if (idx < words.size() && line.size() + words[idx].size() <= maxWidth) {
      line += words[idx];
      idx++;
    }

    if (line.size() + 1 <= maxWidth){
      line += " ";
    }
  }

  return line;
}

vector<string> fullJustify(vector<string>& words, int maxWidth) {
  int i = 0;
  vector<string> answer;

  while (i < words.size()) {
    auto [justifiedLine, idx, usedWords] = greedyAppend(i, words, maxWidth);
    if (idx == words.size()) {
      answer.push_back(justifyFinalLine(usedWords, maxWidth));
    } else {
      answer.push_back(justifiedLine);
    }
    i = idx;
  }
  return answer;
}
```
This works if we handle all the edge cases appropriately. For example ensuring that the last word is _left justified_. Ensuring that for a single word that is exactly the size of _maxWidth_ we do not add more spaces between them, and so on.
