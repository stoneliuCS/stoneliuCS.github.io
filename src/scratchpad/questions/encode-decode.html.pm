#lang pollen

◊(require pollen/unstable/pygments)

◊strong{Encode and Decode Strings}

◊p{
The following is a recursive solution to a popular leetcode question. Inspiration comes from neetcode for walking me through the solution.

The idea involves encoding the string by first prefixing each string by the length of the string itself and then a special delimiter.

By doing it this way, we can effectively read how much more to parse after our delimiter without worrying about whether or not it shows up in the actual string.

An interesting edge case comes from if a possible string can be of arbitrary length. We would need to somehow read that many digits + 1 (To account for our delimiter) before reading the string itself.

My code does it in a very scuffed way, here is the relevant portion:

◊highlight['python]{
    num_parser = ""
    for c in s:
        if c == "%":
            break;
        num_parser += c
  }
}

The final solution does an accumulator approach, similar to ◊em{fundamentals one}, whether I did it properly is up for interpretation.

◊highlight['python]{
  def encode(self, strs: List[str]) -> str:
      result = ""
      for string in strs:
          length = len(string)
          result += f"{length}%{string}"
      return result

  def decode(self, s: str) -> List[str]:
      def decodeHelper(self, s: str, acc: list[str]):
          if len(s) == 0:
              return acc
          else:
              num_parser = ""
              for c in s:
                  if c == "%":
                      break;
                  num_parser += c
              num = int(num_parser)
              start = len(num_parser) + 1
              substr = s[start:num + start]
              reststr = s[num + start:]
              acc.append(substr)
              return decodeHelper(self, reststr, acc)
      return decodeHelper(self, s, [])
}

