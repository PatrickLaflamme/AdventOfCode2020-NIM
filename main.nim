import httpclient, system, strformat, strutils, sugar
import utils/savedSessionId
import solutions/day1, 
       solutions/day2, 
       solutions/day3,
       solutions/day4,
       solutions/day5,
       solutions/day6,
       solutions/day7,
       solutions/day8,
       solutions/day9,
       solutions/day10
import utils/adventOfCodeClient

let solutions = @[ 
  (client: AoCClient, submit: bool) => day1(client, submit), 
  (client: AoCClient, submit: bool) => day2(client, submit),
  (client: AoCClient, submit: bool) => day3(client, submit),
  (client: AoCClient, submit: bool) => day4(client, submit),
  (client: AoCClient, submit: bool) => day5(client, submit),
  (client: AoCClient, submit: bool) => day6(client, submit),
  (client: AoCClient, submit: bool) => day7(client, submit),
  (client: AoCClient, submit: bool) => day8(client, submit),
  (client: AoCClient, submit: bool) => day9(client, submit),
  (client: AoCClient, submit: bool) => day10(client, submit)
]

var sessionId: string
var day: int
var client: AoCClient
while true:
  echo "Please provide your saved session alias to load it from the database"
  let sessionAlias = readLine(stdin)
  try:
    sessionId = getSessionIdForAlias(sessionAlias)
    client = getClientWithSessionId(sessionId)
  except HttpRequestError:
    echo getCurrentException().msg
    echo fmt("[ {sessionAlias} ] isn't configured as a session alias yet. Would you like to configure it as a new saved session (Y/n)?")
    if readLine(stdin).toLower() == "y":
      echo fmt("""
Great! Go sign into http://adventofcode.com. Once signed in, open the networking tab in dev tools and reload.
Inspect the request to reload the page. One of the cookies in the request should be called "session". Copy the value of your session
and paste it into the prompt. It will then be saved and associated with the session alias {sessionAlias}""")
      sessionId = readLine(stdin)
      setSessionIdForAlias(sessionAlias, sessionId)
    else:
      continue

  echo "Please enter a day of the Advent of Code to run the associated solution"
  let dayString = readLine(stdin)

  try:
    day = parseInt(dayString)
  except ValueError:
    echo fmt("[ {dayString} ] is not a valid integer.")
    continue

  if day > solutions.len:
    echo fmt("A solution for day [ {day} ] hasn't been written yet. The most recent solution was for day [ {solutions.len} ]")
    continue

  echo fmt(
    """

****************************************
Answers for day {day}
****************************************
    """
  )
  solutions[day - 1](client, submit=false)
  break

echo "Are you ready to submit this solution (Y/n)?"
if readLine(stdin).toLower() == "y":
  solutions[day - 1](client, submit=true)
