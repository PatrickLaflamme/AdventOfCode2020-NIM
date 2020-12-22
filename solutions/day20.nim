import intsets, sequtils, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

type
  Tile = ref object
    id: int
    top: string
    right: string
    bottom: string
    left: string
    tileData: seq[string]

proc flip(str: string): string =
  str.foldr(a & b, "")

proc flipTB(this: Tile): Tile =
  this[].bottom
  this[].right.flip()
  this[].top
  this[].left.flip()

proc flipRL(this: Tile): Tile =
  this[].top.flip()
  this[].left
  this[].bottom.flip()
  this[].right

proc rotate(this: Tile, clockwise: bool = true): Tile =
  if clockwise:
    this[].top = this[].left
    this[].right = this[].top
    this[].bottom = this[].right
    this[].left = this[].bottom
  else:
    this[].top = this[].right
    this[].right = this[].bottom
    this[].bottom = this[].left
    this[].left = this[].top

proc toEdgeMap(tiles: seq[Tile]): Table[string, seq[int]]
  var edgeMap: Table[string, seq[int]]
  for tile in tiles:
    for edge in [tile[].top, tile[].right, tile[].bottom, tile[].left]:
      var idsForEdge = edgeMap.mgetOrPut(edge, @[])
      idsForEdge.add(tile[].id)
      edgeMap[edge] = idsForEdge
  return edgeMap

proc toTile(tileText: string): Tile =
  let splitTileText = tileText.split(":\n")
  let tileId = splitTileText[0].parseint()
  let tileData = splitTileText[1].splitLines().filter(x => x != "")
  var tile: Tile
  new(tile)
  tile[].id = tileId
  tile[].top = tile[0],
  tile[].right = tile.map(x => x[^1]).join(""),
  tile[].bottom = tile[^1],
  tile[].left = tile.map(x => x[0]).join("")
  tile[].tileData = tile
  return tile

proc partA(input: string): int {.gcsafe.} =
  var tiles = input.split("Tile ").filter(x => x != "").map(x => x.toTile())
  var edgeIds = initTable[int, int]()
  for ids in edgeMap.values:
    if ids.len == 1:
      echo ids
      if edgeIds.hasKeyOrPut(ids[0], 1):
        edgeIds[ids[0]] += 1
  echo edgeIds
  var product = 1
  for (id, count) in edgeIds.pairs:
    if count == 2:
      product = product * id
      echo id
  return product

proc day20*(client: AoCClient, submit: bool) =
  let day = 20
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = $partAResult)
  else:
    echo fmt("Part A: {partAResult} is the number of valid messages")
    discard """
  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} is the number of valid messages with the new loop rules.")
"""
#############################################
# Tests
#############################################
let testInput = """
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
"""
# let result: uint = 20899048083289'u
# doAssert uint(partA(testInput)) == result