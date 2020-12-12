import deques, sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

type 
  SpaceState = enum
    EMPTY
    OCCUPIED
    FLOOR

  WaitingLobbySpace = object
    spaceState: SpaceState
    adjacentSpaces: seq[Coords]

  WaitingLobby = 
    seq[seq[WaitingLobbySpace]]
  
  Coords = tuple
    row: int
    col: int

proc simpleNeighborStrat(hIndex: int, wIndex: int, lobby: WaitingLobby): seq[Coords] =
  var adjacentSpaces: seq[Coords]= @[]
  for i in -1..1:
    for j in -1..1:
      if i != 0 or j != 0:
        var adjacentRow = hIndex + i
        var adjacentCol = wIndex + j
        if adjacentCol >= 0 and adjacentRow < lobby.len and adjacentRow >= 0 and adjacentCol < lobby[0].len:
          adjacentSpaces.add((adjacentRow, adjacentCol))
  adjacentSpaces

proc plus(self: Coords, other: Coords): Coords =
  (self.row + other.row, self.col + other.col)

proc minus(self: Coords, other: Coords): Coords =
  (self.row - other.row, self.col - other.col)

proc unitDirection(self: Coords, reff: Coords): Coords = 
  let xy = self.minus(reff)
  if xy.row < 0 and xy.col < 0:
    (-1, -1)
  elif xy.row < 0 and xy.col == 0:
    (-1, 0)
  elif xy.row < 0 and xy.col > 0:
    (-1, 1)
  elif xy.row == 0 and xy.col > 0:
    (0, 1)
  elif xy.row > 0 and xy.col > 0:
    (1, 1)
  elif xy.row > 0 and xy.col == 0:
    (1, 0)
  elif xy.row > 0 and xy.col < 0:
    (1, -1)
  elif xy.row == 0 and xy.col < 0:
    (0, -1)
  else:
    raise newException(ValueError, fmt("{xy} is not a direction!"))

proc visibleSeatStrat(hIndex: int, wIndex: int, lobby: WaitingLobby): seq[Coords] =
  let seatCoords = (hIndex, wIndex)
  var adjacentSpaces: seq[Coords]= @[]
  var spacesToCheck = initDeque[Coords]()
  for i in -1..1:
    for j in -1..1:
      if i != 0 or j != 0:
        var adjacentRow = hIndex + i
        var adjacentCol = wIndex + j
        if adjacentCol >= 0 and adjacentCol < lobby[0].len and adjacentRow >= 0 and adjacentRow < lobby.len:
          spacesToCheck.addLast((adjacentRow, adjacentCol))
  while spacesToCheck.len > 0:
    let spaceToCheck = spacesToCheck.popFirst()
    if lobby[spaceToCheck.row][spaceToCheck.col].spaceState == SpaceState.FLOOR:
      let newSpaceToCheck = spaceToCheck.plus(spaceToCheck.unitDirection(seatCoords))
      if newSpaceToCheck.row >= 0 and newSpaceToCheck.row < lobby.len and newSpaceToCheck.col >= 0 and newSpaceToCheck.col < lobby[0].len:
        spacesToCheck.addLast(newSpaceToCheck)
    else:
      adjacentSpaces.add(spaceToCheck)
  adjacentSpaces

proc toWaitingLobby(
  input: string, 
  adjacentSeatStrat: proc (hIndex: int, wIndex: int, lobby: WaitingLobby): seq[Coords]
): WaitingLobby =
  let lobbyRows = input.splitLines().filter(x => x != "")
  var waitingLobby: WaitingLobby = @[]
  for hIndex, row in lobbyRows:
    var waitingLobbyRow: seq[WaitingLobbySpace] = @[]
    for wIndex, space in row:
      var spaceState: SpaceState
      case space:
        of '.': 
          spaceState = SpaceState.FLOOR
        of 'L':
          spaceState = SpaceState.EMPTY
        of '#':
          spaceState = SpaceState.OCCUPIED
        else:
          raise newException(ValueError, fmt("Invalid space state string: {space}"))
      let newSpace = WaitingLobbySpace(
        spaceState: spaceState,
        adjacentSpaces: @[]
      )
      waitingLobbyRow.add(newSpace)
    waitingLobby.add(waitingLobbyRow)
  for hIndex, row in waitingLobby:
    for wIndex, space in row:
      let adjacentSpaces = adjacentSeatStrat(hIndex, wIndex, waitingLobby)
      for indices in adjacentSpaces:
        waitingLobby[hIndex][wIndex].adjacentSpaces.add(indices)
  waitingLobby

proc timeStepWithNeighborTolerance(lobby: WaitingLobby, neighborTolerance: int): WaitingLobby =
  var nextLobby = lobby
  for hIndex, row in nextLobby:
    for wIndex, space in row:
      let oldSpace = lobby[hIndex][wIndex]
      var nextSpace = space
      var occupiedNeighbors = 0
      for adjacentSpaceIndex in oldSpace.adjacentSpaces:
        let (adjacentSpaceH, adjacentSpaceW) = adjacentSpaceIndex
        let adjacentSpace = lobby[adjacentSpaceH][adjacentSpaceW]
        if adjacentSpace.spaceState == SpaceState.OCCUPIED:
          occupiedNeighbors += 1
      if space.spaceState == SpaceState.EMPTY and occupiedNeighbors == 0:
        nextSpace.spaceState = SpaceState.OCCUPIED
      elif space.spaceState == SpaceState.OCCUPIED and occupiedNeighbors >= neighborTolerance:
        nextSpace.spaceState = SpaceState.EMPTY
      nextLobby[hIndex][wIndex] = nextSpace
  nextLobby

proc occupiedSeats(lobby: WaitingLobby): int =
  var occupiedSeatCount = 0
  for row in lobby:
    for space in row:
      if space.spaceState == SpaceState.OCCUPIED:
        occupiedSeatCount += 1
  return occupiedSeatCount

proc partA(input: string): int =
  let initialLobby = input.toWaitingLobby(simpleNeighborStrat)
  var lobbyStates = @[initialLobby, initialLobby.timeStepWithNeighborTolerance(4)]
  while lobbyStates[^1] != lobbyStates[^2]:
    lobbyStates.add(lobbyStates[^1].timeStepWithNeighborTolerance(4))
  lobbyStates[^1].occupiedSeats

proc partB(input: string): int =
  let initialLobby = input.toWaitingLobby(visibleSeatStrat)
  var lobbyStates = @[initialLobby, initialLobby.timeStepWithNeighborTolerance(5)]
  while lobbyStates[^1] != lobbyStates[^2]:
    lobbyStates.add(lobbyStates[^1].timeStepWithNeighborTolerance(5))
  lobbyStates[^1].occupiedSeats

proc day11*(client: AoCClient, submit: bool) =
  let input = client.getInput(11)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 11, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} are seated in the waiting lobby in its stable state")

  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = 11, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} are seated in the waiting lobby in its stable state with the new rules")

######################################
# Test
######################################

let testInput = """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
"""

doAssert partA(testInput) == 37
doAssert partB(testInput) == 26 