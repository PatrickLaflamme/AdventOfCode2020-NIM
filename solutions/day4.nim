import strformat, strutils, sequtils, sugar, tables, re
import ../utils/adventOfCodeClient

proc parseToPassports(input: string): seq[Table[string, string]] =
  let lines = input.splitLines()
  var passports: seq[Table[string, string]] = @[]
  var passport = initTable[string, string]()
  for line in lines:
    if line == "":
      passports.add(passport)
      passport = initTable[string, string]()
      continue
    let keyValuePairs = line.split(" ").map((kv) => kv.split(":"))
    for kv in keyValuePairs:
      if kv[0] == "cid":
        continue
      passport[kv[0]] = kv[1]
  passports

proc partA(input: string): int = 
  let requiredFields = [
    "byr",
    "iyr",
    "eyr",
    "hgt",
    "hcl",
    "ecl",
    "pid"
  ]

  let passports = parseToPassports(input)
  var validCount = 0
  for passport in passports:
    var valid = true
    for field in requiredFields:
      if not passport.haskey(field):
        valid = false
        break
    if valid:
      validCount += 1
  validCount

proc partB(input: string): int = 
  let validations = {
    "byr": (input: string) => input.len == 4 and input.parseInt() >= 1920 and input.parseInt() <= 2002,
    "iyr": (input: string) => input.len == 4 and input.parseInt() >= 2010 and input.parseInt() <= 2020,
    "eyr": (input: string) => input.len == 4 and input.parseInt() >= 2020 and input.parseInt() <= 2030,
    "hgt": proc (input: string): bool = 
      (
        block:
          if input.endsWith("cm"):
            var mutableInput = input
            mutableInput.removeSuffix("cm")
            let height = mutableInput.parseInt()
            height >= 150 and height <= 193
          elif input.endsWith("in"):
            var mutableInput = input
            mutableInput.removeSuffix("in")
            let height = mutableInput.parseInt()
            height >= 59 and height <= 76
          else:
            false
      ),
    "hcl": (input: string) => input.match(re(r"#[0-9a-f]{6}")),
    "ecl": proc (input: string): bool = 
      (
        block:
          let validEcls = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
          for ecl in validEcls:
            if input == ecl:
              return true
          false
      ),
    "pid": (input: string) => input.match(re"^[0-9]{9}$")
  }.toTable

  let passports = parseToPassports(input)
  var validCount = 0
  for passport in passports:
    var valid = true
    for (field, validation) in validations.pairs:
      if not passport.haskey(field):
        valid = false
        break
      let validationFunc = validations[field]
      let passportValue = passport[field]
      if not validationFunc(passportValue):
        valid = false
        break
    if valid:
      validCount += 1
  validCount

proc day4*(client: AoCClient, submit: bool) =
  let input = client.getInput(4)

  let partAResult = partA(input)
  if submit:
    echo client.submitSolution(day = 4, level = 1, answer = partAResult.intToStr)
  else:
    echo fmt("Part A: {partAResult} valid passports")

  let partBResult = partB(input)
  if submit:
    echo client.submitSolution(day = 4, level = 2, answer = partBResult.intToStr)
  else:
    echo fmt("Part B: {partBResult} valid passports")


#############################################
# Test
#############################################
let testInput = """
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
"""

let testInvalidPassports = """
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007

hgt:59in ecl:blu
eyr:2030 hcl:74454a iyr:2013
pid:012345678 byr:2000

hgt:58in ecl:blu
eyr:2030 hcl:#aaaaaa iyr:2013
pid:012345678 byr:2000

hgt:59in ecl:zzz
eyr:2030 hcl:#aaaaaa iyr:2013
pid:012345678 byr:2000

hgt:59in ecl:grn
eyr:2035 hcl:#aaaaaa iyr:2013
pid:012345678 byr:2000

hgt:59in ecl:grn
eyr:2030 hcl:#aaaaaa iyr:2009
pid:012345678 byr:2000

hgt:59in ecl:grn
eyr:2030 hcl:#aaaaaa iyr:2010
pid:01234567 byr:2000

hgt:59in ecl:grn
eyr:2030 hcl:#aaaaaa iyr:2010
pid:0123456789 byr:2000

hgt:59in ecl:grn
eyr:2030 hcl:#aaaaaa iyr:2010
pid:012345678 byr:2003

hcl:#888785
hgt:164cm byr:02001 iyr:02015 cid:88
pid:545766238 ecl:hzl
eyr:02022
"""

let testValidPassports = """
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
"""

doAssert partA(testInput) == 2 
doAssert partB(testInvalidPassports) == 0
doAssert partB(testValidPassports) == 4