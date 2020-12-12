import os, sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

let north = (0,1)
let south = (0,-1)
let east = (1,0)
let west = (-1,0)

proc right(direction: tuple[ew: int, ns: int], angle: int): tuple[ew: int, ns: int] = 
  var currentAngle = 0
  var outputDirection = direction
  while currentAngle < angle:
    outputDirection = (outputDirection[1], -outputDirection[0])
    currentAngle += 90
  outputDirection

proc left(direction: tuple[ew: int, ns: int], angle: int): tuple[ew: int, ns: int] = 
  var currentAngle = 0
  var outputDirection = direction
  while currentAngle < angle:
    outputDirection = (-outputDirection[1], outputDirection[0])
    currentAngle += 90
  outputDirection

proc partA(input: string): int =
  let instructions: seq[tuple[action: char, value: int]] = input.splitLines()
    .filter(x => x != "")
    .map(x => (x[0], x[1..^1].parseInt()))
  var direction = east
  var location = (0,0)
  for instruction in instructions:
    var movement: tuple[ew: int, ns: int]
    case instruction.action:
      of 'F':
        movement = direction
      of 'R':
        direction = right(direction, instruction.value)
        movement = (0,0)
      of 'L':
        direction = left(direction, instruction.value)
        movement = (0,0)
      of 'N':
        movement = north
      of 'E':
        movement = east
      of 'S':
        movement = south
      of 'W':
        movement = west
      else:
        raise newException(ValueError, fmt("[ {instruction.action} ] is not a valid action."))
    location = (location[0] + movement[0] * instruction.value, location[1] + movement[1] * instruction.value)
  abs(location[0]) + abs(location[1])

proc partB(input: string): int =
  let instructions: seq[tuple[action: char, value: int]] = input.splitLines()
    .filter(x => x != "")
    .map(x => (x[0], x[1..^1].parseInt()))
  var direction = (10,1)
  var location = (0,0)
  for instruction in instructions:
    var movement: tuple[ew: int, ns: int] = (0,0)
    case instruction.action:
      of 'F':
        movement = direction
      of 'R':
        direction = right(direction, instruction.value)
      of 'L':
        direction = left(direction, instruction.value)
      of 'N':
        direction = (direction[0] + north[0] * instruction.value, direction[1] + north[1] * instruction.value)
      of 'E':
        direction = (direction[0] + east[0] * instruction.value, direction[1] + east[1] * instruction.value)
      of 'S':
        direction = (direction[0] + south[0] * instruction.value, direction[1] + south[1] * instruction.value)
      of 'W':
        direction = (direction[0] + west[0] * instruction.value, direction[1] + west[1] * instruction.value)
      else:
        raise newException(ValueError, fmt("[ {instruction.action} ] is not a valid action."))
    location = (location[0] + movement[0] * instruction.value, location[1] + movement[1] * instruction.value)
  abs(location[0]) + abs(location[1])

proc day12*(client: AoCClient, submit: bool) =
  let input = client.getInput(12)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 12, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the manhattan travel distance")
  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = 12, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the manhattan travel distance with the new rules")

#########################################
# Test
#########################################
let testInput = """
F10
N3
F7
R90
F11
"""

doAssert partA(testInput) == 25
doAssert partB(testInput) == 286