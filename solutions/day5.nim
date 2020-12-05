import math, strformat, strutils, sequtils, sugar, algorithm
import ../utils/adventOfCodeClient

type 
  BoardingPass = object
    seatSpecification: string

proc setIndicesToValue[L, T](arr: var array[L, T], indices: seq[int], value: T) = 
  for i in indices:
    arr[i] = value

proc rowNumber(boardingPass: BoardingPass): int =
  let rowSpecfication = boardingPass.seatSpecification[0..6]
  var front = 0
  var back = 127
  var middle = (front + back) / 2
  for rowHalf in rowSpecfication:
    if rowHalf == 'B':
      front = ceil(middle).int
    elif rowHalf == 'F':
      back = floor(middle).int
    else:
      raise Exception.newException(fmt("Invalid row specification. Must only contain ['F', 'B'] but contained '{rowHalf}'"))
    middle = (front + back) / 2
  front

proc columnNumber(boardingPass: BoardingPass): int =
  let colSpecification = boardingPass.seatSpecification[^3..^1]
  var left = 0
  var right = 7
  var middle = (left + right) / 2
  for colHalf in colSpecification:
    if colHalf == 'R':
      left = ceil(middle).int
    elif colHalf == 'L':
      right = floor(middle).int
    else:
      raise Exception.newException(fmt("Invalid row specification. Must only contain ['R', 'L'] but contained '{colHalf}'"))
    middle = (left + right) / 2
  left

proc seatId(boardingPass: BoardingPass): int = 
  let row = boardingPass.rowNumber
  let col = boardingPass.columnNumber
  row * 8 + col

proc partA(input: string): int =
  let seatIds = input.splitLines()
    .filter(line => line.len > 0) # filter out empty lines
    .map(seatSpec => BoardingPass(seatSpecification: seatSpec))
    .map(bp => bp.seatId)
  seatIds[seatIds.maxIndex]

proc partB(input: string): int =
  var seatIds = input.splitLines()
    .filter(line => line.len > 0) # filter out empty lines
    .map(seatSpec => BoardingPass(seatSpecification: seatSpec))
    .map(bp => bp.seatId)
  var seatsArray: array[1024, bool]
  seatsArray.setIndicesToValue(seatIds, true)
  for index in 1..1022:
    if seatsArray[index - 1] and seatsArray[index + 1] and not seatsArray[index]:
      return index

proc day5*(client: AoCClient, submit: bool) =
  let input = client.getInput(5)

  let partAResult = partA(input)
  echo fmt("Part A: {partAResult} is the highest seat ID on a boarding pass")
  if submit:
    echo client.submitSolution(day = 5, level = 1, answer = partAResult.intToStr)
  
  let partBResult = partB(input)
  echo fmt("Part B: {partBResult} is the missing seat ID (probably mine)")
  if submit:
    echo client.submitSolution(day = 5, level = 2, answer = partBResult.intToStr)

#############################################
# Test
#############################################

let testRow = "FBFBBFFRLR"
let testInput = """
FBFBBFFRLR
BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL
"""

doAssert partA(testRow) == 357
doAssert partA(testInput) == 820


# in this test we test a few things: the first row is missing, as are most of the back rows. The missing seat id is 10
let identifySkippedTest = """
FFFFFFBLLL
FFFFFFBLLR
FFFFFFBLRR
FFFFFFBRLL
"""
doAssert partB(identifySkippedTest) == 10
