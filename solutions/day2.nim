import sequtils, strformat, strutils, sugar
import ../utils/adventOfCodeClient

type RepeatReq = object
  repeatRange: array[2, int]
  letter: char

type PositionReq = object
  index: int
  letter: char

type PwdWithRepeatReq = object
  req: RepeatReq
  pwd: string

type PwdWithPositionReqs = object
  reqs: seq[PositionReq]
  pwd: string

proc pwdMatchesRepeatReq(pwdWithRepeatReq: PwdWithRepeatReq): bool =
  let pwd = pwdWithRepeatReq.pwd
  let req = pwdWithRepeatReq.req
  var charCount = 0
  for pwdChar in pwd:
    if pwdChar == req.letter:
      charCount += 1
      if charCount > req.repeatRange[1]:
        return false
  if charCount >= req.repeatRange[0]:
    return true
  return false

proc pwdMatchesPositionReqs(pwdWithPositionReqs: PwdWithPositionReqs): bool =
  let pwd = pwdWithPositionReqs.pwd
  let reqs = pwdWithPositionReqs.reqs
  var matchCount = 0
  for req in reqs:
    if req.letter == pwd[req.index]:
      matchCount += 1
      if matchCount > 1:
        return false
  if matchCount == 1:
    return true
  return false
    

proc toPwdWithRepeatReq(inputLine: string): PwdWithRepeatReq =
  let inputSplit = inputLine.split(sep = ": ")
  let reqString = inputSplit[0]
  let pwd = inputSplit[1]
  let reqStringSplit = reqString.split(sep = " ")
  let rangeString = reqStringSplit[0]
  let letter = reqStringSplit[1].mapIt(it)[0]
  let rangeStringSplit = rangeString.split(sep = "-")
  let minCount = rangeStringSplit[0]
  let maxCount = rangeStringSplit[1]
  let repeatRange = [minCount.parseInt(), maxCount.parseInt()]
  let req = RepeatReq(repeatRange: repeatRange, letter: letter)
  PwdWithRepeatReq(req: req, pwd: pwd)

proc toPwdWithPositionReqs(inputLine: string): PwdWithPositionReqs =
  let inputSplit = inputLine.split(sep = ": ")
  let reqString = inputSplit[0]
  let pwd = inputSplit[1]
  let reqStringSplit = reqString.split(sep = " ")
  let positionString = reqStringSplit[0]
  let letter = reqStringSplit[1].mapIt(it)[0]
  let positionStringSplit = positionString.split(sep = "-")
  let firstLoc = positionStringSplit[0].parseInt() - 1
  let secondLoc = positionStringSplit[1].parseInt() - 1
  let req1 = PositionReq(index: firstLoc, letter: letter)
  let req2 = PositionReq(index: secondLoc, letter: letter)
  PwdWithPositionReqs(reqs: @[req1, req2], pwd: pwd)


proc partA(input: string): int =
  input.splitLines()
    .filter(inputLine => len(inputLine) > 1)
    .map(inputLine => inputLine.toPwdWithRepeatReq())
    .filter(pwdWithRepeatReq => pwdWithRepeatReq.pwdMatchesRepeatReq)
    .len

proc partB(input: string): int =
  input.splitLines()
    .filter(inputLine => len(inputLine) > 1)
    .map(inputLine => inputLine.toPwdWithPositionReqs())
    .filter(pwdWithPositionReqs => pwdWithPositionReqs.pwdMatchesPositionReqs)
    .len

proc day2*(client: AoCClient, submit: bool): void =
  let input = client.getInput(2)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day=2, level=1, answer=intToStr(partAResult))
  else:
    echo fmt("part A: {partAResult} valid passwords")
  
  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day=2, level=2, answer=intToStr(partBResult))
  else:
    echo fmt("part B: {partBResult} valid passwords")

##########################################
# Tests
##########################################

let testInput1 = """
  1-3 a: abcde
  1-3 b: cdefg
  2-9 c: ccccccccc
""".unindent()

let testInput2 = """
  1-3 a: abcde
  1-3 a: cbade
  1-3 b: cdefg
  2-9 c: ccccccccc
""".unindent()

doAssert partA(testInput1) == 2
doAssert partB(testInput2) == 2