import sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc day20*(client: AoCClient, submit: bool) =
  let day = 20
  let input = client.getInput(day)

  let partAmathmathmatchValue = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAmathmathmatchValue.intToStr)
  else:
    echo fmt("Part A: {partAmathmathmatchValue} is the number of valid messages")
    discard """
  let partBmathmathmatchValue = partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBmathmathmatchValue.intToStr)
  else:
    echo fmt("Part B: {partBmathmathmatchValue} is the number of valid messages with the new loop rules.")

#############################################
# Tests
#############################################
let testInput = """