import re, sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

type
  RuleNode = ref object
    number: int
    validValues: seq[seq[RuleNode]] # outer seq is a set of OR conditions. inner seq is a set of sequential AND conditions.
    value: char

proc regexForRule(this: RuleNode): string =
  if this.validValues.len < 1:
    return fmt("{this.value}")
  var ors: seq[string] = @[]
  for values in this.validValues:
    var ands = ""
    var lastWasThis = false
    for value in values:
      if value == this:
        ands = fmt("(({ands})+)")
        lastWasThis = true
      elif lastWasThis:
          ands = fmt("{ands}(({value.regexForRule()})+)")
          break
      else:
        ands = ands & value.regexForRule()
    if lastWasThis:
      ors = @[ands]
      break
    ors.add(ands)
  let regexString = ors.join("|")
  return fmt("({regexString})")

proc toString(this: RuleNode): string = 
  var ruleSet = this.validValues.map(x => x.map(x => x.number.intToStr()).join(" ")).join(" | ")
  if ruleSet.len == 0:
    ruleSet = fmt("\"{this.value}\"")
  fmt("{this.number}: {ruleSet}")

proc createRuleSet(input: string): Table[int, RuleNode] =
  let ruleLines = input.splitLines().filter(x => x.len >= 1).filter(x => x[0].isDigit())
  var ruleSet: Table[int, RuleNode]
  for line in ruleLines:
    let splitLine = line.split(": ")
    let ruleNumber = splitLine[0].parseInt()
    var ruleNode: RuleNode
    new(ruleNode)
    ruleNode = ruleSet.mgetOrPut(ruleNumber, ruleNode)
    ruleNode.number = ruleNumber
    var ruleString = splitLine[1]
    if ruleString.startsWith('"'):
      ruleString.removeSuffix('"')
      ruleString.removePrefix('"')
      ruleNode.value = ruleString[0]
      continue
    var possibleRuleConditions: seq[seq[RuleNode]] = @[]
    for ruleConditions in ruleString.split(" | "):
      var ruleConditionPointers: seq[RuleNode] = @[]
      for rule in ruleConditions.split(" "):
        let ruleInt = rule.parseInt()
        var ruleConditionNode: RuleNode
        new(ruleConditionNode)
        ruleConditionNode = ruleSet.mgetOrPut(ruleInt, ruleConditionNode)
        ruleConditionPointers.add(ruleConditionNode)
      possibleRuleConditions.add(ruleConditionPointers)
    ruleNode.validValues = possibleRuleConditions
  return ruleSet  

proc partA(input: string): int = 
  let messages = input.splitLines().filter(x => x.len >= 1).filter(x => not x[0].isDigit())
  let ruleSet = input.createRuleSet()
  let generatedRegex = ruleSet[0].regexForRule()
  let regexForRule = re(fmt("^{generatedRegex}$"))
  return messages.filter(x => x.contains(regexForRule)).len

proc partB(input: string): int = 
  let messages = input.splitLines()
    .filter(x => x.len >= 1)
    .filter(x => not x[0].isDigit())
  let ruleSet = input.createRuleSet()
  let generatedRegex42 = ruleSet[42].regexForRule()
  let generatedRegex31 = ruleSet[31].regexForRule()
  let regexForRule42 = re(generatedRegex42)
  let regexForRule31 = re(generatedRegex31)
  var validMessages: int
  for message in messages:
    var match = true
    var index, count42, count31: int
    while index < message.len:
      let matchLoc = message.findBounds(regexForRule42, start=index)
      if matchLoc.first != index:
        break
      index += matchLoc.last - matchLoc.first + 1
      inc count42
    while index < message.len:
      let matchLoc = message.findBounds(regexForRule31, start=index)
      if matchLoc.first != index:
        break
      index += matchLoc.last - matchLoc.first + 1
      inc count31
    if index == message.len and count42 > count31 and count31 > 0:
      inc validMessages
  return validMessages

proc day19*(client: AoCClient, submit: bool) =
  let day = 19
  let input = client.getInput(day)

  let partAmathmathmatchValue = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAmathmathmatchValue.intToStr)
  else:
    echo fmt("Part A: {partAmathmathmatchValue} is the number of valid messages")
  let partBmathmathmatchValue = partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBmathmathmatchValue.intToStr)
  else:
    echo fmt("Part B: {partBmathmathmatchValue} is the number of valid messages with the new loop rules.")

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
abaababababa
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

let testInput3 = """
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
"""

doAssert partA(testInput) == 2
doAssert partA(testInput2) == 2
doAssert partA(testInput3) == 3
echo partB(testInput3)
doAssert partB(testInput3) == 12