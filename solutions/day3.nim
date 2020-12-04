import strformat, strutils, sequtils, sugar
import ../utils/adventOfCodeClient

type Game = object
  board: seq[string]
  xMax: int
  yMax: int
  xLoc: int
  yLoc: int
  treesHit: int

const tree = '#'

proc move(game: Game, move: tuple[x: int, y:int]) : Game =
  let xLoc = (game.xLoc + move.x) mod game.xMax
  let yLoc = game.yLoc + move.y
  let charAtLoc = game.board[yLoc][xLoc]
  var treesHit = game.treesHit
  if charAtLoc == tree:
    treesHit += 1
  Game(
    board: game.board,
    xMax: game.xMax,
    yMax: game.yMax,
    xLoc: xLoc,
    yLoc: yLoc,
    treesHit: treesHit
  )

proc toGame(input: string): Game = 
  let board = input.splitLines().filter(x => x.len > 0)
  let xMax = board[0].len
  # Ensure all rows in the board are of equal length
  doAssert board.filter(x => x.len == xMax).len == board.len
  let yMax = board.len - 1
  let xLoc = 0
  let yLoc = 0
  let treesHit = 0
  Game(
    board: board,
    xMax: xMax,
    yMax: yMax,
    xLoc: xLoc,
    yLoc: yLoc,
    treesHit: treesHit
  )

proc findTreesHitForConstantMove(game: Game, move: tuple[x: int, y:int]): int =
  var mutableGame = game
  while mutableGame.yLoc < game.yMax:
    mutableGame = mutableGame.move(move)
  mutableGame.treesHit

proc partA(input: string): int =
  let game = input.toGame()
  let move = (x: 3, y: 1)
  game.findTreesHitForConstantMove(move)

proc partB(input: string): int = 
  let game = input.toGame()
  let moves = @[
    (x: 1, y: 1),
    (x: 3, y: 1),
    (x: 5, y: 1),
    (x: 7, y: 1),
    (x: 1, y: 2)
  ]
  var product = 1
  for move in moves:
    product *= game.findTreesHitForConstantMove(move)
  product
    
proc day3*(client: AoCClient, submit: bool) =
  let input = client.getInput(3)

  let partAResult = partA(input)
  echo fmt("Part A: {partAResult} trees hit")
  if submit:
    echo client.submitSolution(day = 3, level = 1, answer = partAResult.intToStr)
  
  let partBResult = partB(input)
  echo fmt("Part B: {partBResult} is the product of all trees hit for the 5 contant moves")
  if submit:
    echo client.submitSolution(day = 3, level = 2, answer = partBResult.intToStr)



############################################################
# Tests
############################################################
let testInput = """
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
"""

doAssert partA(testInput) == 7
doAssert partB(testInput) == 336