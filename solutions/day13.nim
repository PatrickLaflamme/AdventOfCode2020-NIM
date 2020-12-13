import os, sequtils, strutils, strformat, sugar, system
import ../utils/adventOfCodeClient

type
  Req = tuple[freq: int, offset: int]
  Constraint = tuple[mult: int, plus: int]

proc createMultipleConstraints(reqs: seq[Req], largestReq: Req): seq[Constraint] =
  let allButLargestReq = reqs.filter(x => x != largestReq)
  var constraints: seq[Constraint] = @[]
  for req in allButLargestReq:
    var desiredOffset = largestReq.offset - req.offset
    if desiredOffset < 0:
      desiredOffset += req.freq
    for i in 1..req.freq:
      if (largestReq.freq * i).mod(req.freq) == desiredOffset:
        constraints.add((req.freq, i))
  constraints

proc partA(input: string): int = 
  let earliestTime = input.splitLines()
    .filter(x => x != "")[0]
    .parseInt()
  let waitTimesAndBusIds = input.splitLines()
    .filter(x => x != "")[1]
    .split(",")
    .filter(x => x != "x")
    .map(x => x.parseInt())
    .map(x => (x, x - earliestTime.mod(x)))
  
  var minBus = waitTimesAndBusIds[0]
  for (busId, waitTime) in waitTimesAndBusIds:
    if waitTime < minBus[1]:
      minBus = (busId, waitTime)
  return minBus[0] * minBus[1]

proc partB(input: string): int =
  let busIds = input.splitLines()
    .filter(x => x != "")[1]
    .split(",")
  var requirements: seq[Req]
  var largestFreqRequirement: Req = (0, 0)
  for index, busId in busIds:
    if busId != "x":
      requirements.add((busId.parseInt(), index))
      if requirements[^1].freq > largestFreqRequirement[0]:
        largestFreqRequirement = requirements[^1]
  let multipleConstraints: seq[Constraint] = createMultipleConstraints(requirements, largestFreqRequirement)
  var largestConstraint: Constraint = (0,0)
  for constraint in multipleConstraints:
    if constraint.mult > largestConstraint.mult:
      largestConstraint = constraint
  let maximumTimeStamp = requirements.map(x => x.freq).foldl(a * b, 1)
  var curTimeStamp = 0
  var curMultiple = 1
  while curTimeStamp < maximumTimeStamp:
    curTimeStamp = largestFreqRequirement.freq * (largestConstraint.mult * curMultiple + largestConstraint.plus) - largestFreqRequirement.offset
    var isValid = true
    for req in requirements:
      if (curTimeStamp + req.offset).mod(req.freq) != 0:
        isValid = false
        break
    if isValid:
      return curTimeStamp
    curMultiple += 1

proc day13*(client: AoCClient, submit: bool) =
  let input = client.getInput(13)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 13, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the product of the busID and wait time.")
  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = 13, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the first timestamp matching the desired pattern")

#########################################
# Test
#########################################
let testInput = """
939
7,13,x,x,59,x,31,19
"""
let testInput2 = """
---
17,x,13,19
"""
let testInput3 = """
---
67,7,59,61
"""
let testInput4 = """
---
67,x,7,59,61
"""
let testInput5 = """
---
67,7,x,59,61
"""
let testInput6 = """
---
1789,37,47,1889
"""

doAssert partA(testInput) == 295
doAssert partB(testInput) == 1068781
doAssert partB(testInput2) == 3417
doAssert partB(testInput3) == 754018
doAssert partB(testInput4) == 779210
doAssert partB(testInput5) == 1261476
doAssert partB(testInput6) == 1202161486