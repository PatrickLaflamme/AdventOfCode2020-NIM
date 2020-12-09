import intsets, sequtils, strformat, strutils, sugar, system
import ../utils/adventOfCodeClient

proc toInputArray(input: string): seq[int] =
  input.splitLines()
    .filter(x => x != "")
    .map(x => x.parseInt())

proc identifyInvalidValue(inputArray: seq[int], windowSize: int): int =
  var currentIndex = windowSize
  var windowLeft = currentIndex - windowSize
  var windowRight = currentIndex - 1
  var windowSet = initIntSet()
  discard inputArray[windowLeft..windowRight].map(x => windowSet.containsOrIncl(x))
  var currentValue: int
  var otherReqValue: int
  var indexIsValid: bool
  while currentIndex < inputArray.len:
    windowSet.incl(inputArray[windowRight])
    currentValue = inputArray[currentIndex]
    indexIsValid = false
    for windowValue in windowSet:
      otherReqValue = currentValue - windowValue
      if windowSet.contains(otherReqValue):
        indexIsValid = true
        break
    if not indexIsValid:
      return currentValue
    windowSet.excl(inputArray[windowLeft])
    windowLeft.inc()
    windowRight.inc()
    currentIndex.inc()
  return -1

proc identifySubArraySumsTo(inputArray: seq[int], value: int): seq[int] =
  var left = 0
  var right = 1
  var sum = inputArray[0] + inputArray[1]
  var leftValue: int
  var nextRightValue: int
  while right < inputArray.len:
    leftValue = inputArray[left]
    nextRightValue = inputArray[right + 1]
    if sum < value:
      sum += nextRightValue
      right.inc()
    elif sum > value:
      sum -= inputArray[left]
      left.inc()
    elif left == right:
      sum += nextRightValue
      right.inc()
    else:
      return inputArray[left..right]

proc partA(input: string, windowSize: int): int =
  input.toInputArray()
    .identifyInvalidValue(windowSize)

proc partB(input: string, windowSize: int): int =
  let inputArray = input.toInputArray()
  let invalidValue = inputArray
    .identifyInvalidValue(windowSize)
  let contiguousSubArray = inputArray
    .identifySubArraySumsTo(invalidValue)
  if contiguousSubArray.len > 2:
    let minIndex = contiguousSubArray.minIndex
    let maxIndex = contiguousSubArray.maxIndex
    return contiguousSubArray[minIndex] + contiguousSubArray[maxIndex]

proc day9*(client: AoCClient, submit: bool) =
  let input = client.getInput(9)

  let partAResult = partA(input, 25)
  if submit:
    echo client.submitSolution(day = 9, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} the invalid value in the input")

  let partBResult = partB(input, 25)
  if submit:
    echo client.submitSolution(day = 9, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the sum of the first and last element of the contiguous sub array adding to the invalid value")

######################################
# Test
######################################
let testInput1 = """
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
"""

doAssert partA(testInput1, 5) == 127
doAssert partB(testInput1, 5) == 62