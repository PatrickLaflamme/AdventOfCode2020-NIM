import os, sequtils, sets, strformat, strutils, sugar
import ../utils/adventOfCodeClient

type 

  Coords = tuple
    x: int
    y: int
    z: int
    w: int

  CubeSpace = tuple
    min: Coords
    max: Coords

  PocketDimension = object
    activeCubes: HashSet[Coords]
    relevantSpace: CubeSpace

proc neighbors(self: Coords, dims: int = 3): seq[Coords] =
  var neighbors: seq[Coords] = @[]
  var wRange: seq[int] = @[0]
  if dims > 3:
    wRange = wRange.concat(@[-1, 1])
  for x in -1..1:
    for y in -1..1:
      for z in -1..1:
        for w in wRange:
          if (x, y, z, w) != (0, 0, 0, 0):
            neighbors.add((self.x + x, self.y + y, self.z + z, self.w + w))
  neighbors

proc inc(self: Coords, dims: int = 3): Coords =
  case dims:
    of 3:
      (self.x + 1, self.y + 1, self.z + 1, self.w)
    else:
      (self.x + 1, self.y + 1, self.z + 1, self.w + 1)

proc dec(self: Coords, dims: int = 3): Coords =
  case dims:
    of 3:
      (self.x - 1, self.y - 1, self.z - 1, self.w)
    else:
      (self.x - 1, self.y - 1, self.z - 1, self.w - 1)

proc allCoords(space: CubeSpace): seq[Coords] =
  var allCoordsSeq: seq[Coords] = @[]
  for x in space.min.x..space.max.x:
    for y in space.min.y..space.max.y:
      for z in space.min.z..space.max.z:
        for w in space.min.w..space.max.w:
          allCoordsSeq.add((x: x, y: y, z: z, w: w))
  allCoordsSeq

proc toPocketDimension(input: string, dims: int = 3): PocketDimension = 
  var activeCoords: seq[Coords] = @[]
  let z = 0
  let w = 0
  let inputLines = input.splitLines().filter(x => x != "")
  for y, line in inputLines:
    for x, cubeState in line:
      case cubeState:
        of '#':
          activeCoords.add((x, y, z, w))
        else:
          discard
  var minW = 0
  var maxW = 0
  if dims > 3:
    minW = -1
    maxW = 1
  let mincoord = (x: -1, y: -1, z: -1, w: minW) # 0,0,0 minus 1
  let maxCoord = (x: inputLines[0].len, y: inputLines.len, z: 1, w: maxW) # max index + 1 on all dimensions. 
  return PocketDimension(
    activeCubes: activeCoords.toHashSet(),
    relevantSpace: (
      min: mincoord,
      max: maxCoord
    )
  )

proc timeStep(currentState: PocketDimension, dims: int = 3): PocketDimension =
  var nextActiveCubes: seq[Coords] = @[]
  for coord in currentState.relevantSpace.allCoords():
    var activeNeighbors = 0
    for neighbor in coord.neighbors(dims):
      if neighbor in currentState.activeCubes:
        activeNeighbors += 1
    if coord in currentState.activeCubes and activeNeighbors in [2, 3]:
      nextActiveCubes.add(coord)
    elif activeNeighbors == 3:
      nextActiveCubes.add(coord)
  return PocketDimension(
    activeCubes: nextActiveCubes.toHashSet(),
    relevantSpace: (
      min: currentState.relevantSpace.min.dec(dims),
      max: currentState.relevantSpace.max.inc(dims)
    )
  )

proc partA(input: string): int =
  var currentState = input.toPocketDimension()
  for i in 1..6:
    currentState = currentState.timeStep()
  currentState.activeCubes.len

proc partB(input: string): int =
  var currentState = input.toPocketDimension(dims = 4)
  for i in 1..6:
    currentState = currentState.timeStep(dims = 4)
  currentState.activeCubes.len

proc day17*(client: AoCClient, submit: bool) =
  let day = 17
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the number of active cubes after 6 time-steps in 3D")

  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the number of active cubes after 6 time-steps in 4D")

#############################################
# Tests
#############################################

let testInput = """
.#.
..#
###
"""

doAssert partA(testInput) == 112
doAssert partB(testInput) == 848