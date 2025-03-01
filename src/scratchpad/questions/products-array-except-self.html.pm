#lang pollen

◊p{
Given an integer array nums, return an array output where output[i] is the product of all the elements of nums except nums[i].

Using a recursive/accumulator based approach to the problem:
}

◊code-block["language-python"]{
def productExceptSelf(self, nums: List[int]) -> List[int]:
    return self.productExceptSelfHelper(nums, [0] * len(nums), 0)
def productExceptSelfHelper(self, nums: List[int], acc: List[int], idx: int):
    if idx == len(nums):
        return acc
    else:
        firstHalf : List[int] = nums[0:idx]
        secondHalf : List[int] = nums[idx + 1: len(nums)]
        num1 = 1 if len(firstHalf) == 0 else math.prod(firstHalf)
        num2 = 1 if len(secondHalf) == 0 else math.prod(secondHalf)
        acc[idx] = num1 * num2
        return self.productExceptSelfHelper(nums, acc, idx + 1)
}

◊p{
Okay this solution is pretty bad, its ◊em{O(n)} space complexity because I am initializing an array of zeros as one of my accumulators.

In addition, I am recurring up to ◊em{n} times, and doing potentially a product of n elements.
}

◊code-block["language-python"]{
  def productExceptSelf(self, nums: List[int]) -> List[int]:
      # create a prefix array
      length = len(nums)
      result = [1] + [0] * (length - 1)

      # first pass, compute the prefixes
      for i in range(length):
          prefix = nums[0 : i]
          product = 1 if len(prefix) == 0 else math.prod(prefix)
          result[i] = product
      
      # second pass, compute the postfixes
      for i in range(length):
          postfix = nums[i + 1 : length]
          product = 1 if len(postfix) == 0 else math.prod(postfix)
          result[i] = product * result[i]
      return result
}

◊p{
  This solution is much more ◊em{pythonic}, and its completely imperative, as opposed to my previous solution which was mostly functional. This was has both ◊em{O(n)} space and complexity.
}
