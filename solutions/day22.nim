import deques, math, sequtils, sets, strformat, strutils, sugar
import ../utils/adventOfCodeClient, ../utils/savedSessionId

type
  PendingRound = tuple
    c1: int
    c2: int

  GameState = ref object
    p1: seq[int]
    p2: seq[int]
    seenStates: HashSet[string]
    gameNumber: int
    roundNumber: int
    pending: PendingRound

const noPending: PendingRound = (-1, -1)

proc parseInputDeque(input: string): tuple[p1: Deque[int], p2: Deque[int]] =
  let twoPlayers = input.split("\n\n")
    .map(p => (
      block:
        let cards = p.splitLines()
          .filter(x => x != "" and ":" notin x)
          .map(x => x.parseInt())
        var deque = initDeque[int]()
        for val in cards:
          deque.addLast(val)
        return deque
      )
    )
  return (p1: twoPlayers[0], p2: twoPlayers[1])

proc parseInputSeq(input: string): tuple[p1: seq[int], p2: seq[int]] =
  let twoPlayers = input.split("\n\n")
    .map(p => (
      block:
        p.splitLines()
          .filter(x => x != "" and ":" notin x)
          .map(x => x.parseInt())
      )
    )
  return (p1: twoPlayers[0], p2: twoPlayers[1])

proc recursiveCombat(p1start: seq[int], p2start: seq[int]): int =
  var gameState: GameState
  new(gameState)
  gameState.p1 = p1start
  gameState.p2 = p2start
  gameState.seenStates = initHashSet[string]()
  gameState.gameNumber = 1
  gameState.roundNumber = 1
  gameState.pending = noPending

  var gameStates = @[gameState]
  var winner: int
  var winningDeck: seq[int]
  var gameCount = 1
  while gameStates.len > 0:
    var state = gameStates[^1]
    let currentState = fmt("{state.p1}{state.p2}")
    if currentState in state.seenStates and state.pending == noPending:
      winningDeck = state.p1
      winner = -1
      gameStates.delete(gameStates.len - 1, gameStates.len - 1)
      continue
    else:
      state.seenStates.incl(currentState)
    let c1 = if state.pending.c1 >= 0: state.pending.c1 else: state.p1[0]
    let c2 = if state.pending.c2 >= 0: state.pending.c2 else: state.p2[0]
    if state.pending != noPending:
      state.p1.delete(0, 0)
      state.p2.delete(0, 0)
      if winner < 0:
        state.p1.add(c1)
        state.p1.add(c2)
      elif winner > 0:
        state.p2.add(c2)
        state.p2.add(c1)
      else:
        raise newException(ValueError, "something went really wrong over here...")
      winner = 0
      state.pending = noPending
    elif state.p1.len > c1 and state.p2.len > c2:
      state.pending = (c1: c1, c2: c2)
      gameStates[^1] = state
      inc gameCount
      var childGame: GameState
      new(childGame)
      childGame.p1 = state.p1[1..c1]
      childGame.p2 = state.p2[1..c2]
      childGame.seenStates = initHashSet[string]()
      childGame.gameNumber = gameCount
      childGame.roundNumber = 1
      childGame.pending = noPending
      gameStates.add(childGame)
      continue
    elif c1 > c2:
      state.p1.delete(0, 0)
      state.p2.delete(0, 0)
      state.p1.add(c1)
      state.p1.add(c2)
    else:
      state.p1.delete(0, 0)
      state.p2.delete(0, 0)
      state.p2.add(c2)
      state.p2.add(c1)
    
    if state.p2.len == 0 and state.p1.len > 0:
      winner = -1
      winningDeck = state.p1
      gameStates.delete(gameStates.len - 1, gameStates.len - 1)
    elif state.p1.len == 0 and state.p2.len > 0:
      winner = 1
      winningDeck = state.p2
      gameStates.delete(gameStates.len - 1, gameStates.len - 1)
    else:
      inc state.roundNumber
  var remainingCards = winningDeck.len
  while remainingCards > 0:
    result += winningDeck[^remainingCards] * remainingCards
    dec remainingCards

proc partA(input: string): int =
  var (p1, p2) = input.parseInputDeque()
  while p1.len > 0 and p2.len > 0:
    let c1 = p1.popFirst()
    let c2 = p2.popFirst()
    if c1 > c2:
      p1.addLast(c1)
      p1.addLast(c2)
    else:
      p2.addLast(c2)
      p2.addLast(c1)
  var winningDeck = if p1.len > 0: p1 else: p2
  var remainingCards = winningDeck.len
  while remainingCards > 0:
    result += winningDeck.popFirst() * remainingCards
    dec remainingCards

proc partB(input: string): int =
  let (p1, p2) = input.parseInputSeq()
  result = recursiveCombat(p1, p2)
  # echo result

proc day22*(client: AoCClient, submit: bool) {.gcsafe.} =
  let day = 22
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the winning player's score in the game of Combat")
  
  let partBResult = if hasCachedResult(input, 2): getCachedResult(input, 2) else: partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the winning player's score in the game of Recursive Combat")

#############################################
# Tests
#############################################
let testInput = """
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
"""

let testInput2 = """
Player 1:
43
19

Player 2:
2
29
14
"""

doAssert partA(testInput) == 306
doAssert partB(testInput) == 291
doAssert partB(testInput2) == 105