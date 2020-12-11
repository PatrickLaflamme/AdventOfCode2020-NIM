import intsets, math, sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc toIntArray(input: string): seq[int] =
  input.splitLines()
    .filter(x => x != "")
    .map(x => x.parseInt())

proc toIntSet(input: string): IntSet =
  var inputSet = initIntSet()
  discard input.toIntArray()
    .map(x => inputSet.containsOrIncl(x))
  inputSet

proc partA(input: string): int = # O(N) runtime
  var inputSet = input.toIntSet()
  var seenAdapterCount = 0
  var joltageDifferenceDist = [0, 0, 0]
  var currentJoltage = 0
  while seenAdapterCount < inputSet.len:
    var found = false
    for joltageDifference in 1..3:
      if inputSet.contains(currentJoltage + joltageDifference):
        currentJoltage += joltageDifference
        joltageDifferenceDist[joltageDifference - 1] += 1
        seenAdapterCount += 1
        found = true
        break
  # add the final difference of 3 to the device
  joltageDifferenceDist[3 - 1] += 1
  return joltageDifferenceDist[0] * joltageDifferenceDist[2]

proc partB(input: string): int = # O(N) runtime
  var inputArray = input.toIntArray()
  var inputSet = input.toIntSet()
  var seenAdapterCount = 0
  var combosThatTouchAdapter = newCountTable[int]()
  combosThatTouchAdapter.inc(0)
  inputSet.incl(0)
  var currentJoltage = inputArray.min
  while seenAdapterCount < inputArray.len:
    for joltageDecrease in 1..3:
      var tempJoltage = currentJoltage - joltageDecrease
      if inputSet.contains(tempJoltage):
        combosThatTouchAdapter.inc(currentJoltage, combosThatTouchAdapter[tempJoltage])
    for joltageIncrease in 1..3:
      var nextJoltage = currentJoltage + joltageIncrease
      if inputSet.contains(nextJoltage):
        currentJoltage = nextJoltage
        break
    seenAdapterCount += 1
  return combosThatTouchAdapter[inputArray.max]


proc day10*(client: AoCClient, submit: bool) =
  let input = client.getInput(10)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 10, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the product of the 1 difference jumps and 3 difference jumps")

  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = 10, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the number of possible adapter combinations")

################################
# Test
###############################
let testInput1 = """
16
10
15
5
1
11
7
19
6
12
4
"""
let testInput2 = """
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
"""

doAssert partA(testInput1) == 35
doAssert partA(testInput2) == 220
doAssert partB(testInput1) == 8
doAssert partB(testInput2) == 19208