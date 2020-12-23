import sequtils, sets, strformat, strutils, sugar
import ../utils/adventOfCodeClient, ../utils/savedSessionId

type
  Cup = ref object
    next: Cup
    prev: Cup
    id: int
  
  CupCircle = ref object
    cups: seq[Cup]
    size: int
    currentCupId: int

template loop(body: untyped): typed =
  while true:
    body

template until(cond: typed): typed =
  if cond: break

proc createCupCircle(input: string, size: int): CupCircle =
  var cupIds = input.filter(x => x != '\n').map(x => fmt("{x}").parseInt())
  if size > cupIds.len:
    for i in cupIds.len + 1..size:
      cupIds.add(i)
  var cups = newSeq[Cup](size + 1)
  for id in cupIds:
    var cup: Cup
    new(cup)
    cup[].id = id
    cups[id] = cup

  for i in 0..<size:
    cups[cupIds[i]][].next = if i == size - 1: cups[cupIds[0]] else: cups[cupIds[i + 1]]
    cups[cupIds[i]][].prev = if i == 0: cups[cupIds[^1]] else: cups[cupIds[i - 1]]
  
  new(result)
  result[].cups = cups
  result[].size = size
  result[].currentCupId = cupIds[0]

proc playRound(cupCircle: var CupCircle) =
  let nToRemove = 3
  var removedCupIds = newSeqUninitialized[int](nToRemove)
  let currentCup = cupCircle.cups[cupCircle[].currentCupId]
  # --- Action 1 ---
  var newNextCup: Cup = currentCup[].next
  for i in 0..<nToRemove:
    removedCupIds[i] = newNextCup[].id
    newNextCup = newNextCup[].next
  currentCup[].next = newNextCup
  # --- Action 2 ---
  var destinationCupId = currentCup[].id
  loop:
    dec destinationCupId
    if destinationCupId < 1:
      destinationCupId = cupCircle[].size
    until destinationCupId notin removedCupIds
  # -- Action 3 ---
  let prevNextCup = cupCircle[].cups[destinationCupId].next
  var lastRemovedCup = cupCircle[].cups[removedCupIds[^1]]
  lastRemovedCup[].next = prevNextCup
  let firstRemovedCup = cupCircle[].cups[removedCupIds[0]]
  cupCircle[].cups[destinationCupId].next = firstRemovedCup
  # --- Action 4 ---
  cupCircle[].currentCupId = newNextCup[].id
  
proc fromId(cupCircle: CupCircle, targetCupId: int): int =
  var resultSeq = newSeqUninitialized[int](cupCircle[].size - 1)
  let targetCup = cupCircle[].cups[targetCupId]
  var viewingCup = targetCup[].next
  var i: int
  while viewingCup[].id != targetCupId:
    resultSeq[i] = viewingCup[].id
    viewingCup = viewingCup[].next
    inc i
  resultSeq.map(x => x.intToStr).join("").parseInt()

proc partA(input: string): int = 
  var cupCircle = input.createCupCircle(size = input.len)
  for _ in 1..100:
    cupCircle.playRound()
  cupCircle.fromId(targetCupId = 1)

proc partB(input: string): int = 
  var cupCircle = input.createCupCircle(size = 1_000_000)
  for i in 1..10_000_000:
    cupCircle.playRound()
  let cup1 = cupCircle[].cups[1]
  cup1[].next[].id * cup1[].next[].next[].id

proc day23*(client: AoCClient, submit: bool) {.gcsafe.} =
  let day = 23
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the order after 100 rounds.")

  let partBResult = if hasCachedResult(input, 2): getCachedResult(input, 2) else: partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is product of the next two cup IDs after cup 1")

#############################################
# Tests
#############################################

let testInput = "389125467"

doAssert partA(testInput) == 67384529
doAssert partB(testInput) == 149245887792