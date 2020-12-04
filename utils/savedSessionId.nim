import httpclient
import os
import strformat

let client = newHttpClient()
let urlBase = getEnv("REPLIT_DB_URL")

proc getSessionIdForAlias*(sessionAlias: string): string =
  let url = fmt("{urlBase}/{sessionAlias}")
  client.getContent(url)

proc setSessionIdForAlias*(sessionAlias: string, sessionId: string) =
  let url = fmt("{urlBase}")
  client.headers["content-type"] = "application/x-www-form-urlencoded"
  discard client.postContent(url, body=fmt("{sessionAlias}={sessionId}"))