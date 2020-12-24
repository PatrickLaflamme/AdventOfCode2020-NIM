import re, sequtils, sets, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

type 
  Neighbor = enum
    e, ne, nw, w, sw, se
  
  TileLoc = tuple
    x: int
    y: int

const neighborLocs: Table[Neighbor, TileLoc] = {
    e:  (x: 2, y: 0),
    ne: (x: 1, y: 1),
    nw: (x: -1, y: 1),
    w:  (x: -2, y: 0),
    sw: (x: -1, y: -1),
    se: (x: 1, y: -1)
  }.toTable

proc parseInput(input: string): seq[seq[Neighbor]] =
  let neighborSplitRegex = re"(?=[ew])"
  return input.splitLines()
    .filter(x => x != "")
    .map(x => x.split(neighborSplitRegex).map(y => parseEnum[Neighbor](y)))

proc flipTile(flippedTiles: var HashSet[TileLoc], tilePath: seq[Neighbor], referenceTile: TileLoc = (0, 0)) =
  var currentTile = referenceTile
  for neighbor in tilePath:
    currentTile = (currentTile.x + neighborLocs[neighbor].x, currentTile.y + neighborLocs[neighbor].y)
  if flippedTiles.missingOrExcl(currentTile): flippedTiles.incl(currentTile)

proc setInitialState(input: string): HashSet[TileLoc] =
  var flippedTiles = initHashSet[TileLoc]()
  for tilePath in input.parseInput():
    flippedTiles.flipTile(tilePath)
  return flippedTiles

proc computeTilesForDay(flippedTiles: HashSet[TileLoc]): HashSet[TileLoc] =
  var tomorrowsTiles = flippedTiles
  var adjacentWhiteTiles = initHashSet[TileLoc]()
  for tile in flippedTiles:
    var adjacentBlackTileCount = 0
    for neighbor in neighborLocs.values():
      let adjacentTile = (tile.x + neighbor.x, tile.y + neighbor.y)
      if adjacentTile in flippedTiles: 
        adjacentBlackTileCount += 1
      else:
        adjacentWhiteTiles.incl(adjacentTile)
    if adjacentBlackTileCount == 0 or adjacentBlackTileCount > 2:
      tomorrowsTiles.excl(tile)
  for tile in adjacentWhiteTiles:
    var adjacentBlackTileCount = 0
    for neighbor in neighborLocs.values():
      let adjacentTile = (tile.x + neighbor.x, tile.y + neighbor.y)
      if adjacentTile in flippedTiles: 
        adjacentBlackTileCount += 1
    if adjacentBlackTileCount == 2:
      tomorrowsTiles.incl(tile)
  return tomorrowsTiles


proc partA(input: string): int =
  return input.setInitialState().card()

proc partB(input: string): int =
  var flippedTiles = input.setInitialState()
  for _ in 1..100:
    flippedTiles = flippedTiles.computeTilesForDay()
  return flippedTiles.card()

proc day24*(client: AoCClient, submit: bool) {.gcsafe.} =
  let day = 24
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} is the number of initially flipped tiles")
  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the number of black tiles after 100 days")

#############################################
# Tests
#############################################
let testInput = """
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
"""

doAssert partA(testInput) == 10
doAssert partB(testInput) == 2208