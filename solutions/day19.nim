import os, sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc day19*(client: AoCClient, submit: bool) =
  let day = 19
  let input = client.getInput(day)

  let partAmathmathResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAmathmathResult.intToStr)
  else:
    echo fmt("Part A: {partAmathmathResult} is the sum of all values after weird-mathing.")
  discard """
  let partBmathmathResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBmathmathResult.intToStr)
  else:
    echo fmt("Part B: {partBmathmathResult} is the sum of all values after weird-mathing the other way")
"""
#############################################
# Tests
#############################################
let testInput = """
0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"

aba
aab
aaa
bbb
bab
abbaababababa
"""

let testInput2 = """
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb
"""

doAssert partA(testInput) == 2
doAssert partA(testInput2) == 2