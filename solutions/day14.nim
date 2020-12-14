import deques, os, parseutils, re, sequtils, strutils, strformat, sugar, system, tables
import ../utils/adventOfCodeClient

proc partA(input: string): int = 
  let inputCommands = input.splitLines()
    .filter(x => x != "")
    .map(x => x.split(" = "))
  let memoryLocRe = re"[0-9]+"
  var memoryTable = initTable[int, string]()
  var bitMask = ""
  for command in inputCommands:
    case command[0]:
      of "mask":
        bitMask = command[1]
      else:
        let memoryLocation = command[0].findAll(memoryLocRe)[0].parseInt()
        var value = command[1].parseInt().toBin(bitMask.len)
        for index, character in bitMask:
          if character != 'X':
            value[index] = character
        memoryTable[memoryLocation] = value
  var sum = 0
  for value in memoryTable.values():
    sum += fromBin[int](value)
  return sum

proc partB(input: string): int = 
  let inputCommands = input.splitLines()
    .filter(x => x != "")
    .map(x => x.split(" = "))
  let memoryLocRe = re"[0-9]+"
  var memoryTable = initTable[string, int]()
  var bitMask = ""
  for command in inputCommands:
    case command[0]:
      of "mask":
        bitMask = command[1]
      else:
        var memoryLocation = command[0].findAll(memoryLocRe)[0].parseInt().toBin(bitMask.len)
        let value = command[1].parseInt()
        for index, character in bitMask:
          if character == 'X' or character == '1':
            memoryLocation[index] = character
            
        var floatingBitDeque = initDeque[string]()
        floatingBitDeque.addLast(memoryLocation)
        while floatingBitDeque.len > 0:
          let memoryLocFloating = floatingBitDeque.popFirst()
          var hasFloating = false
          for index, character in memoryLocFloating:
            if character == 'X':
              var memoryLocCopy0 = memoryLocFloating
              memoryLocCopy0[index] = '0'
              var memoryLocCopy1 = memoryLocFloating
              memoryLocCopy1[index] = '1'
              floatingBitDeque.addLast(memoryLocCopy0)
              floatingBitDeque.addLast(memoryLocCopy1)
              hasFloating = true
              break
          if not hasFloating:
            memoryTable[memoryLocFloating] = value
  var sum = 0
  for value in memoryTable.values():
    sum += value
  return sum

proc day14*(client: AoCClient, submit: bool) =
  let day = 14
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the sum of all remaining values in memory.")

  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the sum of all remaining values in memory.")
    

#####################################
# Test
#####################################

let testInput = """
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
"""

let testInput2 = """
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
"""

doAssert partA(testInput) == 165
doAssert partB(testInput2) == 208