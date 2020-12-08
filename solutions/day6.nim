import math, strformat, strutils, sequtils, tables
import ../utils/adventOfCodeClient

proc partA(input: string): int =
  let responses = input.splitLines()
  var sumCount = 0
  var seenResponses = initTable[char, int]()
  for response in responses:
    if response == "":
      sumCount += toSeq(seenResponses.keys).len
      seenResponses = initTable[char, int]()
    else:
      for question in response:
        if question in toSeq(seenResponses.keys):
          seenResponses[question] += 1
        else:
          seenResponses[question] = 0
  return sumCount

proc partB(input: string): int =
  let responses = input.splitLines()
  var sumCount = 0
  var groupSize = 0
  var seenResponses = initTable[char, int]()
  for response in responses:
    if response == "":
      for question, yesCount in seenResponses.pairs:
        if yesCount == groupSize:
          sumCount += 1
      groupSize = 0
      seenResponses = initTable[char, int]()
    else:
      groupSize += 1
      for question in response:
        if question in toSeq(seenResponses.keys):
          seenResponses[question] += 1
        else:
          seenResponses[question] = 1
  return sumCount

proc day6*(client: AoCClient, submit: bool) =
  let input = client.getInput(6)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 6, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} total \"yes\" responses")

  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = 6, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} total group-wide \"yes\" responses")

######################################
# Tests
######################################

let testInput = """abc

a
b
c

ab
ac

a
a
a
a

b
"""

doAssert partA(testInput) == 11
doAssert partB(testInput) == 6