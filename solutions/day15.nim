import os, sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

proc partA(input: string, targetIndex = 2020): int =
  let startSequence = input.split(",")
    .map(x => x.replace("\n", ""))
    .map(x => x.parseInt())
  var seenNumbers = newSeq[int](targetIndex)
  for i, n in startSequence: seenNumbers[n] = i + 1
  for i in startSequence.len + 1 ..< targetIndex:
    let diff = i - seenNumbers[result]
    seenNumbers[result] = i
    result = if diff == i: 0 else: diff

proc partB(input: string): int =
  partA(input, targetIndex = 30_000_000)

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