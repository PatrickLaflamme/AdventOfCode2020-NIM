import algorithm, re, sequtils, sets, strformat, strutils, sugar, tables
import ../utils/adventOfCodeClient

proc partA(input: string): int {.gcsafe.} =
  var ingredientsByAllergen = initTable[string, HashSet[string]]()
  var allIngredients = initTable[string, int]()
  let allergensRegex = re"(?<=\(contains ).*(?=\))"
  let ingredientsRegex = re"^.*(?= \(contains)"
  for recipe in input.splitLines().filter(x => x != ""):
    let ingredients = recipe.findAll(ingredientsRegex)[0].split(" ").toHashSet()
    let allergens = recipe.findAll(allergensRegex)[0].split(", ").toHashSet()
    for allergen in allergens:
      let existingIngredients = ingredientsByAllergen.mgetOrPut(allergen, ingredients)
      ingredientsByAllergen[allergen] = existingIngredients * ingredients
    for ingredient in ingredients:
      var count = allIngredients.mgetOrPut(ingredient, 0)
      count += 1
      allIngredients[ingredient] = count
  var safeIngredients = toHashSet(toSeq(allIngredients.keys))
  for ingredients in ingredientsByAllergen.values():
    safeIngredients = safeIngredients - ingredients
  var safeIngredientCount = 0
  for safeIngredient in safeIngredients:
    safeIngredientCount += allIngredients[safeIngredient]
  return safeIngredientCount

proc partB(input: string): string {.gcsafe.} =
  var ingredientsByAllergen = initTable[string, HashSet[string]]()
  let allergensRegex = re"(?<=\(contains ).*(?=\))"
  let ingredientsRegex = re"^.*(?= \(contains)"
  for recipe in input.splitLines().filter(x => x != ""):
    let ingredients = recipe.findAll(ingredientsRegex)[0].split(" ").toHashSet()
    let allergens = recipe.findAll(allergensRegex)[0].split(", ").toHashSet()
    for allergen in allergens:
      let existingIngredients = ingredientsByAllergen.mgetOrPut(allergen, ingredients)
      ingredientsByAllergen[allergen] = existingIngredients * ingredients
  var allergenToIngredient = initTable[string, string]()
  var assignedIngredients = initHashSet[string]()
  while allergenToIngredient.len < ingredientsByAllergen.len:
    for (allergen, ingredientSet) in ingredientsByAllergen.pairs:
      if allergen in allergenToIngredient:
        continue
      var unassignedIngredients = ingredientSet - assignedIngredients
      if unassignedIngredients.len == 1:
        let ingredientWithAllergen = unassignedIngredients.pop()
        allergenToIngredient[allergen] = ingredientWithAllergen
        assignedIngredients.incl(ingredientWithAllergen)
  var allergens = toSeq(allergenToIngredient.keys)
  allergens.sort()
  return allergens.map(x => allergenToIngredient[x]).join(",")

proc day21*(client: AoCClient, submit: bool) =
  let day = 21
  let input = client.getInput(day)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = day, level = 1, answer = $partAResult)
  else:
    echo fmt("Part A: {partAResult} is the number of times safe ingredients appear")
  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = day, level = 2, answer = partBResult)
  else:
    echo fmt("Part B: {partBResult} is the canonical dangerous ingredients list")

#############################################
# Tests
#############################################
let testInput = """
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
"""

doAssert partA(testInput) == 5
doAssert partB(testInput) == "mxmxvkd,sqjhc,fvjkl"