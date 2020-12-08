import sequtils, sets, strformat, strutils, sugar, system
import ../utils/adventOfCodeClient

type 
  Action = enum
    nop
    acc
    jmp
  
  Instruction = object
    action: Action
    value: int
  
  SolveFailureError = object of ValueError

proc toAction(actionStr: string): Action =
  result = case actionStr:
    of "nop":
      Action.nop
    of "acc":
      Action.acc
    of "jmp":
      Action.jmp
    else:
      raise newException(ValueError, fmt("invalid input {actionStr}"))

proc flipAction(instr: Instruction): Instruction = 
  var mutableInstr = instr
  case instr.action:
    of Action.jmp:
      mutableInstr.action = Action.nop
    of Action.nop:
      mutableInstr.action = Action.jmp
    of Action.acc:
      discard
  mutableInstr

proc toInstructionSet(input: string): seq[Instruction] =
  input.splitLines()
    .filter(line => line.len > 0)
    .map(line => Instruction(action: line.split(" ")[0].toAction, value: line.split[1].parseInt))

proc flippableIndices(instructionSet: seq[Instruction]): seq[int] =
  var flippableIndices: seq[int] = @[]
  for index, instruction in instructionSet:
    if instruction.action == Action.jmp or instruction.action == Action.nop:
      flippableIndices.add(index)
  flippableIndices

proc withFlippedIndex(instructionSet: seq[Instruction], index: int): seq[Instruction] =
  var mutableInstructionSet = instructionSet
  mutableInstructionSet[index] = instructionSet[index].flipAction
  mutableInstructionSet

proc finalAccValue(instructionSet: seq[Instruction]): int =
  var acc = 0
  var index = 0
  var seenIndices = initHashSet[int]()
  while seenIndices.len < instructionSet.len and index < instructionSet.len:
    if seenIndices.containsOrIncl(index):
      return acc
    let currentInstruction = instructionSet[index]
    case currentInstruction.action:
      of Action.acc:
        acc += currentInstruction.value
      of Action.jmp:
        index += currentInstruction.value
        continue
      of Action.nop:
        discard
    index += 1
  acc

proc finishesAtEnd(instructionSet: seq[Instruction]): bool =
  var acc = 0
  var index = 0
  var seenIndices = initHashSet[int]()
  while index < instructionSet.len:
    if seenIndices.containsOrIncl(index):
      return false
    let currentInstruction = instructionSet[index]
    case currentInstruction.action:
      of Action.acc:
        acc += currentInstruction.value
      of Action.jmp:
        index += currentInstruction.value
        continue
      of Action.nop:
        discard
    index += 1
  return true

proc partA(input: string): int =
  let instructionSet = input.toInstructionSet()
  instructionSet.finalAccValue

proc partB(input: string): int = 
  let instructionSet = input.toInstructionSet()
  let flippableIndices = instructionSet.flippableIndices
  for index in flippableIndices:
    let flippedInstructionSet = instructionSet.withFlippedIndex(index)
    if flippedInstructionSet.finishesAtEnd:
      return flippedInstructionSet.finalAccValue
  raise newException(SolveFailureError, "Could not find the right index to flip!")

proc day8*(client: AoCClient, submit: bool) =
  let input = client.getInput(8)

  let partAResult = partA(input)
  echo fmt("Part A: {partAResult} is the value of acc immediately before the loop begins")
  if submit:
    echo client.submitSolution(day = 8, level = 1, answer = partAResult.intToStr)

  let partBResult = partB(input)
  echo fmt("Part B: {partBResult} is the value of acc when the instructions are change to exit an infinite loop")
  if submit:
    echo client.submitSolution(day = 8, level = 2, answer = partBResult.intToStr)

#########################################################
# Tests
#########################################################

let testInput1 = """
jmp +1
acc -1
nop +0
"""

let testInput2 = """
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
"""

doAssert testInput1.toInstructionSet().len == 3
doAssert partA(testInput2) == 5
doAssert partB(testInput2) == 8