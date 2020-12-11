import deques, sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

type 
  SpaceState = enum
    EMPTY
    OCCUPIED
    FLOOR

  WaitingLobbySpace = object
    spaceState: SpaceState
    adjacentSpaces: seq[tuple[row: int, col: int]]

  WaitingLobby = 
    seq[seq[WaitingLobbySpace]]

proc print(lobby: WaitingLobby) =
  var rowStrings: seq[string] = @[]
  for row in lobby:
    var rowString = ""
    for col in row:
      var colChar: char
      case col.spaceState:
        of SpaceState.EMPTY:
          colChar = 'L'
        of SpaceState.OCCUPIED:
          colChar = '#'
        of SpaceState.FLOOR:
          colChar = '.'
      rowString.add(colChar)
    rowStrings.add(rowString)
  echo "---------"
  echo rowStrings.join("\n")

proc simpleNeighborStrat(hIndex: int, wIndex: int, lobby: WaitingLobby): seq[tuple[row: int, col: int]] =
  var adjacentSpaces: seq[tuple[row: int, col: int]]= @[]
  for i in -1..1:
    for j in -1..1:
      if i != 0 or j != 0:
        var adjacentRow = hIndex + i
        var adjacentCol = wIndex + j
        if adjacentCol >= 0 and adjacentCol < lobby.len and adjacentRow >= 0 and adjacentRow < lobby[0].len:
          adjacentSpaces.add((adjacentRow, adjacentCol))
  adjacentSpaces

proc plus(self: tuple[row: int, col: int], other: tuple[row: int, col: int]): tuple[row: int, col: int] =
  (self.row + other.row, self.col + other.col)

proc unitDirection(xy: tuple[row: int, col: int]): tuple[row: int, col: int] = 
  # todo: flip the checks so the col/row order matches the tuple.
  if xy.col < 0 and xy.row < 0:
    (-1, -1)
  elif xy.col == 0 and xy.row < 0:
    (-1, 0)
  elif xy.col > 0 and xy.row < 0:
    (-1, 1)
  elif xy.col > 0 and xy.row == 0:
    (0, 1)
  elif xy.col > 0 and xy.row > 0:
    (1, 1)
  elif xy.col == 0 and xy.row > 0:
    (1, 0)
  elif xy.col < 0 and xy.row > 0:
    (1, -1)
  elif xy.col < 0 and xy.row == 0:
    (0, -1)
  else:
    raise newException(ValueError, fmt("{xy} is not a direction!"))

proc visibleSeatStrat(hIndex: int, wIndex: int, lobby: WaitingLobby): seq[tuple[row: int, col: int]] =
  var adjacentSpaces: seq[tuple[row: int, col: int]]= @[]
  var spacesToCheck = initDeque[tuple[row: int, col: int]]()
  for i in -1..1:
    for j in -1..1:
      if i != 0 or j != 0:
        var adjacentRow = hIndex + i
        var adjacentCol = wIndex + j
        if adjacentCol >= 0 and adjacentCol < lobby.len and adjacentRow >= 0 and adjacentRow < lobby[0].len:
          spacesToCheck.addLast((adjacentRow, adjacentCol))
  while spacesToCheck.len > 0:
    let spaceToCheck = spacesToCheck.popFirst()
    case lobby[spaceToCheck.row][spaceToCheck.col]:
      of SpaceState.FLOOR:
        spacesToCheck.addLast(spaceToCheck.plus(spaceToCheck.unitDirection))
      else:
        adjacentSpaces.add(spaceToCheck)
  adjacentSpaces

proc toWaitingLobby(
  input: string, 
  adjacentSeatStrat: proc (hIndex: int, wIndex: int, lobby: WaitingLobby): seq[tuple[row: int, col: int]]
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

proc timeStep(lobby: WaitingLobby): WaitingLobby =
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
      elif space.spaceState == SpaceState.OCCUPIED and occupiedNeighbors >= 4:
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
  var lobbyStates = @[initialLobby, initialLobby.timeStep()]
  while lobbyStates[^1] != lobbyStates[^2]:
    lobbyStates.add(lobbyStates[^1].timeStep())
  lobbyStates[^1].occupiedSeats

proc partB(input: string): int =
  let initialLobby = input.toWaitingLobby(visibleSeatStrat)
  var lobbyStates = @[initialLobby, initialLobby.timeStep()]
  while lobbyStates[^1] != lobbyStates[^2]:
    lobbyStates.add(lobbyStates[^1].timeStep())
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