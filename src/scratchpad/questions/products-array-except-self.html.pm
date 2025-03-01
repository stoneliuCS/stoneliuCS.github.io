#lang pollen

◊(require pollen/unstable/pygments)

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
