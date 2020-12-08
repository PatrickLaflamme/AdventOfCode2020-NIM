import deques, sequtils, sets, strformat, strutils, sugar, system
import ../utils/adventOfCodeClient

type 
  Action = enum
    nop
    acc
    jmp
  
  Instruction = object
    action: Action
    value: int
  
  InstructionNode = ref object
    index: int
    instruction: Instruction
    parentNodes: seq[InstructionNode]
    childNode: InstructionNode
    alternativeChildNode: InstructionNode
    isConnectedToEnd: bool
    isEnd: bool
  
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

proc toInstructionGraph(instructionSet: seq[Instruction]): seq[InstructionNode] =
  var mutableInstructionSet = instructionSet

  var endNode: InstructionNode
  new(endNode)
  endNode.isEnd = true
  endNode.isConnectedToEnd = true
  endNode.parentNodes = @[]

  let instructionGraph = mutableInstructionSet.map(x => (block:
    var node: InstructionNode
    new(node)
    node.instruction = x
    node.parentNodes = @[]
    node
  ))

  # Build graph with each element pointing to is parents, its child, and its alternativeChild (if any)
  for index, node in instructionGraph:
    node.index = index
    if node.instruction.action == Action.jmp:
      if index + node.instruction.value < instructionGraph.len:
        node.childNode = instructionGraph[index + node.instruction.value]
      else:
        node.childNode = endNode
        node.isConnectedToEnd = true
      node.childNode.parentNodes.add(node)

      if index + 1 < instructionGraph.len:
        node.alternativeChildNode = instructionGraph[index + 1]
      else:
        node.alternativeChildNode = endNode
      continue

    if node.instruction.action == Action.nop:
      if index + node.instruction.value < instructionGraph.len:
        node.alternativeChildNode = instructionGraph[index + node.instruction.value]
      else:
        node.alternativeChildNode = endNode
        
    if index + 1 < instructionGraph.len:
        node.childNode = instructionGraph[index + 1]
    else:
      node.childNode = endNode
      node.isConnectedToEnd = true
    node.childNode.parentNodes.add(node)
  
  # ensure that any node whose child and further children ultimately connect to the end are marked as such
  var connectedToEndNodeDeque = initDeque[InstructionNode]()
  for node in endNode.parentNodes:
    connectedToEndNodeDeque.addLast(node)
  while connectedToEndNodeDeque.len > 0:
    var nodeOfInterest = connectedToEndNodeDeque.popFirst()
    for parentNode in nodeOfInterest.parentNodes:
      if parentNode != nil:
        parentNode.isConnectedToEnd = true
        connectedToEndNodeDeque.addLast(parentNode)
  
  instructionGraph

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

proc partA(input: string): int =
  let instructionSet = input.toInstructionSet()
  instructionSet.finalAccValue

proc partB(input: string): int = 
  let instructionSet = input.toInstructionSet()
  let instructionGraph = instructionSet.toInstructionGraph()
  var indexToFlip: int = -1
  var seenNodeIndices = initHashSet[int]()
  var nodeIndex = 0
  var node = instructionGraph[nodeIndex]
  while seenNodeIndices.len < instructionGraph.len:
    nodeIndex = node.index
    if node.alternativeChildNode != nil and node.alternativeChildNode.isConnectedToEnd:
      indexToFlip = instructionGraph.find(node)
      break
    node = node.childNode
    if seenNodeIndices.containsOrIncl(nodeIndex):
      break
  if indexToFlip >= 0:
    return instructionSet.withFlippedIndex(indexToFlip).finalAccValue
  else:
    raise newException(SolveFailureError, "Could not find the right index to flip!")

proc day8*(client: AoCClient, submit: bool) =
  let input = client.getInput(8)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 8, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the value of acc immediately before the loop begins")

  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = 8, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the value of acc when the instructions are change to exit an infinite loop")

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
