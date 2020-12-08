import strformat, strutils, sequtils, sugar, algorithm
import ../utils/adventOfCodeClient

#################################
# Part 1
#################################

proc findTwoNumbersThatSumTo(input: seq[int], sumTo: int): array[2, int] =

  var right = input.len - 1
  var left = 0
  var leftInt = 0
  var rightInt = 0
  var sum = 0

  while left < right:
    leftInt = input[left]
    rightInt = input[right]

    sum = leftInt + rightInt
    if sum < sumTo:
      left += 1
    elif sum > sumTo:
      right -= 1
    else:
      return [leftInt, rightInt]
  return [0, 0]

proc partA(input: seq[int], submit: bool, client: AoCClient) =
  let ints = findTwoNumbersThatSumTo(input, 2020)
  let answer = ints[0] * ints[1]
  if submit:
    echo client.submitSolution(day=1, level=1, answer=intToStr(answer))
  else:
    echo fmt("part A: {ints} multiply to {answer}")


########################################
# Part 2
########################################

proc findThreeNumbersThatSumTo(input: seq[int], sumTo: int): array[3, int] =

  var right = input.len - 1
  var middle = 0
  var left = 0
  var middleInt = 0
  var rightInt = 0
  var leftInt = 0
  var sumTwo = 0

  while middle < right:
    middleInt = input[middle]
    rightInt = input[right]

    sumTwo = middleInt + rightInt
    if sumTwo < sumTo:
      left = 0
      leftInt = input[left]
      while left < middle:
        var sumThree = leftInt + sumTwo
        if sumThree == sumTo:
          return [leftInt, middleInt, rightInt]
        left += 1
        leftInt = input[left]
      middle += 1
    else:
      right -= 1
      middle = 0
  return [0, 0, 0]

proc partB(input: seq[int], submit: bool, client: AoCClient) = 
  let ints = findThreeNumbersThatSumTo(input, 2020)
  let answer = ints[0] * ints[1] * ints[2]
  if submit:
    echo client.submitSolution(day=1, level=2, answer=intToStr(answer))
  else:
    echo fmt("part B: {ints} multiply to {answer}")

#####################################################
# Day 1 solutions
#####################################################

proc day1*(client: AoCClient, submit: bool): void =
  let input = client.getInput(1)

  var inputIntArray = input.splitLines()
      .filter(x => not x.isEmptyOrWhitespace())
      .map(x => x.parseInt)

  inputIntArray.sort()

  partA(inputIntArray, submit, client)
  partB(inputIntArray, submit, client)