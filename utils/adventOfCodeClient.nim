import httpclient
import strformat
import strutils

type AoCClient* = object
  httpclient: HttpClient

proc getClientWithSessionId*(sessionId: string): AoCClient =
  let httpclient = newHttpClient()
  let client = AoCClient(httpclient: httpclient)
  let headers = newHttpHeaders({"cookie": fmt("session={sessionId}")})
  client.httpclient.headers = headers
  client

proc getInput*(client: AoCClient, day: int): string =
  let url = fmt("https://adventofcode.com/2020/day/{day}/input")
  try: 
    let response = client.httpclient.getContent(url)
    client.httpclient.close()
    response
  except:
    echo "Looks like something went wrong here. Maybe the session Id is invalid? Exception below:\n"
    raise
    

proc submitSolution*(client: AoCClient, day: int, level: int, answer: string): string =
  let url = fmt("https://adventofcode.com/2020/day/{day}/answer")
  let data = fmt("level={intToStr(level)}&answer={answer}")
  let defaultHeaders = client.httpclient.headers
  client.httpclient.headers["content-type"] = "application/x-www-form-urlencoded"

  try:
    let response = client.httpclient.postContent(url, body=data)
    client.httpclient.headers = defaultHeaders
    client.httpclient.close()

    if response.contains("That's not the right answer"):
      echo fmt("Looks like the answer for part {level} on day {day} is incorrect. Adjust the solution and try again")
    elif response.contains("Did you already complete it") or response.contains("Both parts of this puzzle are complete"):
      echo fmt("Looks like you already completed the challenge for part {level} on day {day}...")
    elif response.contains("That's the right answer"):
      echo fmt("Looks like the answer for part {level} on day {day} was correct!")
    elif response.contains("You gave an answer too recently"):
      echo "Hold your horses! You're submitting answers too quickly. Wait a bit and try again"
    else:
      echo fmt("something went wrong... {response}")
  except:
    echo "Looks like something went wrong here. Maybe the session Id is invalid? Exception below:\n"
    client.httpclient.headers = defaultHeaders
    raise