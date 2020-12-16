import math, os, sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc partA(input: string, targetIndex = 2020): int =
  let startNumbers = input.split(",")
    .map(x => x.replace("\n", ""))
    .map(x => x.parseInt())
  var seenNumbers = initOrderedTable[int, int]()
  for i, startNum in startNumbers:
    seenNumbers[startNum] = i + 1
  var index = startNumbers.len + 1
  var currentDigit: int
  var previousDigit = startNumbers[^1]
  while index <= targetIndex:
    let lastSeen = seenNumbers.getOrDefault(previousDigit)
    if lastSeen > 0:
      currentDigit = index - 1 - lastSeen
    else:
      currentDigit =  0
    seenNumbers[previousDigit] = index - 1
    previousDigit = currentDigit
    index += 1
  return currentDigit

proc nextNumber(numberHistory: var OrderedTable[int, int], currentTurn: int,
  lastNumber: int): int =
  let lastTurn = numberHistory.getOrDefault(lastNumber)
  let nextNumber = (if lastTurn == 0: 0 else: currentTurn - lastTurn)
  numberHistory[lastNumber] = currentTurn
  return nextNumber

proc partB(input: string): int =
  let puzzleInput = input.split(",")
      .map(x => x.replace("\n", ""))
      .map(x => x.parseInt())
  var numberHistory = initOrderedTable[int, int]()
  for turn, number in puzzleInput[0..^2]:
    numberHistory[number] = turn + 1
  var lastNumber = puzzleInput[^1]
  let startingTurn = numberHistory.len + 1
  for currentTurn in startingTurn .. 30000000 - 1 :
    lastNumber = nextNumber(numberHistory, currentTurn, lastNumber)
  return lastNumber

proc day15*(client: AoCClient, submit: bool) =
  let day = 15
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the 2020th number spoken")
  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the 30,000,000th number spoken")
    
#############################################
# Tests
#############################################

let testInput = "0,3,6"
let testInput2 = "1,3,2"
let testInput3 = "2,1,3"
let testInput4 = "1,2,3"
let testInput5 = "2,3,1"
let testInput6 = "3,2,1"
let testInput7 = "3,1,2"

doAssert partA(testInput) == 436
doAssert partA(testInput2) == 1
doAssert partA(testInput3) == 10
doAssert partA(testInput4) == 27
doAssert partA(testInput5) == 78
doAssert partA(testInput6) == 438
doAssert partA(testInput7) == 1836

doAssert partB(testInput) == 175594
discard """
doAssert partB(testInput2) == 2578
doAssert partB(testInput3) == 3544142
doAssert partB(testInput4) == 261214
doAssert partB(testInput5) == 6895259
doAssert partB(testInput6) == 18
doAssert partB(testInput7) == 362
"""