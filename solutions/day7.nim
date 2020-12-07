import deques,
       hashes,
       re, 
       sequtils, 
       strformat, 
       strutils, 
       sugar, 
       tables
import ../utils/adventOfCodeClient

type Bag = ref object
  color: string
  parentBags: seq[Bag]
  childBags: TableRef[Bag, int]

proc hash(x: Bag): Hash =
  ## Piggyback on the already available string hash proc.
  ##
  ## Without this proc nothing works!
  result = x.color.hash
  result = !$result

proc initBag(color: string): Bag =
  var bag: Bag
  new(bag)
  bag.color = color
  bag.parentBags = @[]
  bag.childBags = newTable[Bag, int]()
  bag

proc buildBagGraph(input: string): TableRef[string, Bag] =
  var bagsByColor = newTable[string, Bag]()
  let bagRules = input.splitLines().filter(x => x != "")
  let parentBagColorRE = re".*(?= bags contain)"
  let childBagCountsRE = re"[0-9]+(?=[a-zA-Z ]+ bag[s]{0,1})"
  let childBagColorsRE = re"(?<=[0-9] )[a-zA-Z ]+(?= bag[s]{0,1})"
  for rule in bagRules:
    var parentBagColor = rule.findAll(parentBagColorRE)[0]
    var parentBag = bagsByColor.mgetOrPut(parentBagColor, initBag(parentBagColor))
    let childBagColors = rule.findAll(childBagColorsRE)
    let childBagCounts = rule.findAll(childBagCountsRE)
    for (childBagColor, childBagCountString) in zip(childBagColors, childBagCounts):
      let childBagCount = childBagCountString.parseInt()
      var childBag = bagsByColor.mgetOrPut(childBagColor, initBag(childBagColor))
      childBag.parentBags.add(parentBag)
      parentBag.childBags[childBag] = childBagCount
  bagsByColor

proc partA(input: string): int =
  let bagGraph = buildBagGraph(input)
  var bagsToCheck = initDeque[Bag]()
  for bag in bagGraph["shiny gold"].parentBags:
    bagsToCheck.addLast(bag)
  var bagsContainingShinyGold: seq[Bag] = @[]
  while bagsToCheck.len > 0:
    var currentBag = bagsToCheck.popFirst()
    for bag in currentBag.parentBags:
      bagsToCheck.addLast(bag)
    bagsContainingShinyGold.add(currentBag)
  bagsContainingShinyGold.deduplicate().len

proc partB(input: string): int =
  let bagGraph = buildBagGraph(input)
  var bagsToCheck = initDeque[tuple[bag: Bag, count: int]]()
  for (bag, count) in bagGraph["shiny gold"].childBags.pairs:
    bagsToCheck.addLast((bag: bag, count: count))
  var requiredBags = 0
  while bagsToCheck.len > 0:
    let (currentBag, currentBagCount) = bagsToCheck.popFirst()
    for (bag, count) in currentBag.childBags.pairs:
      bagsToCheck.addLast((bag: bag, count: count * currentBagCount))
    requiredBags += currentBagCount
  requiredBags

proc day7*(client: AoCClient, submit: bool) =
  let input = client.getInput(7)

  let partAResult = partA(input)
  echo fmt("Part A: {partAResult} bags could contain a shiny gold bags")
  if submit:
    echo client.submitSolution(day = 7, level = 1, answer = partAResult.intToStr)

  let partBResult = partB(input)
  echo fmt("Part B: {partBResult} bags are required inside a single shiny gold bag")
  if submit:
    echo client.submitSolution(day = 7, level = 2, answer = partBResult.intToStr)



######################################################
# Test
######################################################

let testInput = """
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
"""
let testInput2 = """
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
"""

doAssert buildBagGraph(testInput).len == 9
doAssert partA(testInput) == 4
doAssert partB(testInput) == 32
doAssert partB(testInput2) == 126