import re, sequtils, sets, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

const subjectNumber = 7
const divisor = 20201227

proc partA(input: string): int =
  let handshake = input.splitLines().filter(x=> x != "").map(x => x.parseInt())
  var value = 1
  var loopSize = 0
  while value notin handshake:
    value = (value * subjectNumber).mod(divisor)
    loopSize += 1
  let otherHandshake = if value == handshake[0]: handshake[1] else: handshake[0]
  var key = 1
  for _ in 1..loopSize: 
    key = (key * otherHandshake).mod(divisor)
  return key

proc day25*(client: AoCClient, submit: bool) {.gcsafe.} =
  let day = 25
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the encryption key the door is looking for.")

#############################################
# Tests
#############################################
let testInput = """
5764801
17807724
"""

doAssert partA(testInput) == 14897079