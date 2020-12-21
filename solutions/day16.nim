import os, re, sequtils, intsets, sets, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc partA(input: string): int = 
  var validNumbers = initIntSet()
  for line in input.splitLines():
    if line == "":
      break
    let ranges = line.split(": ")[1].split(" or ")
    for validRange in ranges:
      let minMax = validRange.split("-").map(x => x.parseInt())
      for validNumber in minMax[0]..minMax[1]:
        validNumbers.incl(validNumber)
  var ticketNumbers: seq[int] = @[]
  input.split("nearby tickets:\n")[1]
    .splitLines()
    .filter(x => x != "")
    .map(x => x.split(",").map(x => x.parseInt()).filter(x => x notin validNumbers))
    .foldl(a & b, ticketNumbers)
    .foldl(a + b, 0)

proc partB(input: string): int =
  let inputSections = input.split("\n\n")
  var fieldRanges: Table[string, ref IntSet]
  var validNumbers = initIntSet()
  for field in inputSections[0].splitLines():
    let splitByName = field.split(": ")
    var validNumbersForField = new(IntSet)
    for validRange in splitByName[1].split(" or "):
      let ints = validRange.split("-").map(x => x.parseInt())
      for i in ints[0]..ints[1]:
        validNumbersForField[].incl(i)
        validNumbers.incl(i)
    fieldRanges[splitByName[0]] = validNumbersForField
  
  let validNearbyTickets = input.split("nearby tickets:\n")[1]
    .splitLines()
    .filter(x => x != "")
    .map(x => x.split(",").map(x => x.parseInt()))
    .filter(x => x.all(x => x in validNumbers))

  var valuesByFieldNumber: seq[ref IntSet]
  for ticket in validNearbyTickets:
    for fieldNumber, value in ticket:
      if fieldNumber < valuesByFieldNumber.len:
        valuesByFieldNumber[fieldNumber][].incl(value)
      else:
        var intset: ref IntSet
        new(intset)
        intset[].incl(value)
        valuesByFieldNumber.add(intset)
  
  var possibleFieldsByFieldNumber: seq[ref HashSet[string]]
  var assignedFields = initTable[string, int]()
  for fieldNumber, valuesForFieldNumber in valuesByFieldNumber:
    var newHashSet: ref HashSet[string]
    new(newHashSet)
    possibleFieldsByFieldNumber.add(newHashSet)
    for (field, fieldRange) in fieldRanges.pairs:
      if valuesForFieldNumber[].difference(fieldRange[]).len == 0 and field notin assignedFields:
        possibleFieldsByFieldNumber[fieldNumber][].incl(field)
    if possibleFieldsByFieldNumber[fieldNumber][].len == 1:
      assignedFields[possibleFieldsByFieldNumber[fieldNumber][].pop()] = fieldNumber 
    
  while assignedFields.len < valuesByFieldNumber.len:
    for fieldNumber, valuesForFieldNumber in valuesByFieldNumber:
      for possibleField in possibleFieldsByFieldNumber[fieldNumber][]:
        if possibleField in assignedFields:
          possibleFieldsByFieldNumber[fieldNumber][].excl(possibleField)
      if possibleFieldsByFieldNumber[fieldNumber][].len == 1:
        assignedFields[possibleFieldsByFieldNumber[fieldNumber][].pop()] = fieldNumber
  
  let findMyTicketNumberRegex = re"(?<=your ticket:\n)[0-9,]+(?=\n)"
  let myTicket = input.findAll(findMyTicketNumberRegex)[0]
    .split(",")
    .map(x => x.parseInt())
  
  var product = 1
  for (field, fieldLoc) in assignedFields.pairs:
    if "departure" in field:
      product = product * myTicket[fieldLoc]
  return product

proc day16*(client: AoCClient, submit: bool) =
  let day = 16
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the scanning error rate")
  let partBResult = partB(input)
  if submit:
    os.sleep(1000) # in order to avoid being rate limited
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the 30,000,000th number spoken")

#############################################
# Tests
#############################################

let testInput = """class: 1-3 or 5-7
departure row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
"""

doAssert partA(testInput) == 71
doAssert partB(testInput) == 7