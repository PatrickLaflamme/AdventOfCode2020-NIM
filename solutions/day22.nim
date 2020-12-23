import deques, math, sequtils, sets, strformat, strutils, sugar
import ../utils/adventOfCodeClient, ../utils/savedSessionId

type
  PendingRound = tuple
    c1: int
    c2: int

  GameState = tuple
    p1: Deque[int]
    p2: Deque[int]
    seenStates: HashSet[string]
    gameNumber: int
    roundNumber: int
    pending: PendingRound

const noPending: PendingRound = (-1, -1)

proc parseInput(input: string): tuple[p1: Deque[int], p2: Deque[int]] =
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

proc recursiveCombat(p1start: Deque[int], p2start: Deque[int]): int =
  let initialGameState: GameState = (p1: p1start, p2: p2start, seenStates: initHashSet[string](), gameNumber: 1, roundNumber: 1, pending: noPending)
  var gameStates = initDeque[GameState]()
  gameStates.addFirst(initialGameState)
  var winner: int
  var winningDeck: Deque[int]
  var gameCount = 1
  while gameStates.len > 0:
    var (p1, p2, seenStates, gameNumber, roundNumber, pending) = gameStates.popFirst()
    # echo fmt("Round {roundNumber} (Game {gameNumber}): {p1} - {p2} seenStates: {seenStates}")
    let currentState = fmt("{p1}{p2}")
    if currentState in seenStates:
      winningDeck = p1
      break
    else:
      seenStates.incl(currentState)
    let c1 = if pending.c1 >= 0: pending.c1 else: p1.popFirst()
    let c2 = if pending.c2 >= 0: pending.c2 else: p2.popFirst()
    if pending != noPending:
      if winner < 0:
        p1.addLast(c1)
        p1.addLast(c2)
      elif winner > 0:
        p2.addLast(c2)
        p2.addLast(c1)
      else:
        raise newException(ValueError, "something went really wrong over here...")
      winner = 0
    elif p1.len >= c1 and p2.len >= c2:
      gameStates.addFirst((p1, p2, seenStates, gameNumber, roundNumber, (c1: c1, c2: c2)))
      var p1copy = p1
      p1copy.shrink(fromLast = p1copy.len - c1)
      var p2copy = p2 
      p2copy.shrink(fromLast = p2copy.len - c2)
      inc gameCount
      gameStates.addFirst((p1copy, p2copy, initHashSet[string](), gameCount, 1, noPending))
      # echo fmt("new game: {gameCount}, nested inside {gameNumber} on round {roundNumber}. nested depth: {gameStates.len}")
      continue
    elif c1 > c2:
      p1.addLast(c1)
      p1.addLast(c2)
    else:
      p2.addLast(c2)
      p2.addLast(c1)
    
    if p1.len > 0 and p2.len > 0:
      gameStates.addFirst((p1, p2, seenStates, gameNumber, roundNumber + 1, noPending))
    elif p1.len > 0:
      winner = -1
      winningDeck = p1
    elif p2.len > 0:
      winner = 1
      winningDeck = p2
    else:
      raise newException(ValueError, "something went really wrong...")
  if gameStates.len > 0:
    var lastState = gameStates.popFirst()
    winningDeck = lastState.p1
    if lastState.pending != noPending:
      winningDeck.addFirst(lastState.pending.c1)
    echo lastState
    echo winningDeck
  var remainingCards = winningDeck.len
  while remainingCards > 0:
    result += winningDeck.popFirst() * remainingCards
    dec remainingCards

proc partA(input: string): int =
  var (p1, p2) = input.parseInput()
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
  let (p1, p2) = input.parseInput()
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