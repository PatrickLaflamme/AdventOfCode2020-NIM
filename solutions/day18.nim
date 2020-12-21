import os, sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

proc doMathPartA(tokens: seq[string]): int =
  var bracketDepth = 0
  var bracketContents: seq[string] = @[]
  var operation = " "
  var mathmathResult = -1
  var currentValue = -1
  for index, token in tokens:
    if token.startsWith('('):
      if bracketDepth == 0:
        bracketContents.add(token[1..^1])
      elif bracketDepth > 0:
        bracketContents.add(token)
      bracketDepth += token.count('(')
      continue
    elif token.endsWith(')'):
      bracketDepth -= token.count(')')
      if bracketDepth == 0:
        bracketContents.add(token[0..^2])
        currentValue = doMathPartA(bracketContents)
        bracketContents = @[]
      else:
        bracketContents.add(token)
    elif bracketDepth > 0:
      bracketContents.add(token)
      continue
    
    if token.all(x => x.isDigit()):
      currentValue = token.parseInt()

    case token:
      of "*":
        operation = token
      of "+":
        operation = token
      else:
        if currentValue >= 0 and mathmathResult < 0:
          mathmathResult = currentValue
        if currentValue >= 0:
          case operation:
            of "*":
              mathmathResult = mathmathResult * currentValue
            of "+":
              mathmathResult = mathmathResult + currentValue
        currentValue = -1
  return mathmathResult
          
proc doMathPartB(tokens: seq[string]): int =
  var bracketDepth = 0
  var bracketContents: seq[string] = @[]
  var mathResult = -1
  var currentValue = -1
  var flattenedCalc: seq[string] = @[]
  for index, token in tokens:
    if token.startsWith('('):
      if bracketDepth == 0:
        bracketContents.add(token[1..^1])
      elif bracketDepth > 0:
        bracketContents.add(token)
      bracketDepth += token.count('(')
      continue
    elif token.endsWith(')'):
      bracketDepth -= token.count(')')
      if bracketDepth == 0:
        bracketContents.add(token[0..^2])
        currentValue = doMathPartB(bracketContents)
        flattenedCalc.add(currentValue.intToStr())
        bracketContents = @[]
      else:
        bracketContents.add(token)
      continue
    elif bracketDepth > 0:
      bracketContents.add(token)
      continue
    
    flattenedCalc.add(token)
  var tokensAfterAddition: seq[string] = @[]
  var index: int
  var token: string
  var tempSum: int
  while index < flattenedCalc.len:
    token = flattenedCalc[index]
    if token == "+":
      let next = flattenedCalc[index + 1].parseInt()
      tempSum += next
      index += 1
    elif flattenedCalc.len > index + 1 and flattenedCalc[index + 1] != "+":
      if tempSum > 0:
        tokensAfterAddition.add(tempSum.intToStr())
        tempSum = 0
      else:
        tokensAfterAddition.add(token)
    elif flattenedCalc.len > index + 1 and flattenedCalc[index + 1] == "+":
      tempSum = token.parseInt()
    else:
      tokensAfterAddition.add(token)
    index += 1
  if tempSum > 0:
    tokensAfterAddition.add(tempSum.intToStr())
  
  mathResult = 1
  for token in tokensAfterAddition:
    if token != "*":
      mathResult = mathResult * token.parseInt()
  return mathResult

proc partA(input: string): int = 
  let tokenizedInputLines = input.splitLines().filter(x => x != "").map(x => x.split(" "))
  var sum = 0
  for line in tokenizedInputLines:
    sum += doMathPartA(line)
  return sum

proc partB(input: string): int = 
  let tokenizedInputLines = input.splitLines().filter(x => x != "").map(x => x.split(" "))
  var sum = 0
  for line in tokenizedInputLines:
    sum += doMathPartB(line)
  return sum

proc day18*(client: AoCClient, submit: bool) =
  let day = 18
  let input = client.getInput(day)

  let partAmathmathResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAmathmathResult.intToStr)
  else:
    echo fmt("Part A: {partAmathmathResult} is the sum of all values after weird-mathing.")
  let partBmathmathResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBmathmathResult.intToStr)
  else:
    echo fmt("Part B: {partBmathmathResult} is the sum of all values after weird-mathing the other way")

#############################################
# Tests
#############################################

let testInput = """
1 + 2 * 3 + 4 * 5 + 6
"""

let testInput2 = """
1 + (2 * 3) + (4 * (5 + 6))
"""

let testInput3 = """
2 * 3 + (4 * 5)
"""

let testInput4 = """
5 + (8 * 3 + 9 + 3 * 4 * 3)
"""

let testInput5 = """
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
"""

let testInput6 = """
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
"""

let testInput7 = testInput & testInput2 & testInput3 & testInput4 & testInput5 & testInput6

doAssert partA(testInput) == 71
doAssert partA(testInput2) == 51
doAssert partA(testInput3) == 26
doAssert partA(testInput4) == 437
doAssert partA(testInput5) == 12240
doAssert partA(testInput6) == 13632
doAssert partA(testInput7) == 26457

doAssert partB(testInput) == 231
doAssert partB(testInput2) == 51
doAssert partB(testInput3) == 46
doAssert partB(testInput4) == 1445
doAssert partB(testInput5) == 669060
doAssert partB(testInput6) == 23340
doAssert partB(testInput7) == 694173