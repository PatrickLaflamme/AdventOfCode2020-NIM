import httpclient
import os
import strformat
import strutils

let client = newHttpClient()
const urlBase = getEnv("REPLIT_DB_URL")

proc getSessionIdForAlias*(sessionAlias: string): string =
  let url = fmt("{urlBase}/{sessionAlias}")
  client.getContent(url)

proc setSessionIdForAlias*(sessionAlias: string, sessionId: string) =
  let url = fmt("{urlBase}")
  client.headers["content-type"] = "application/x-www-form-urlencoded"
  discard client.postContent(url, body=fmt("{sessionAlias}={sessionId}"))

proc cacheResult*(input: string, partNumber: int, result: int) =
  let url = fmt("{urlBase}")
  client.headers["content-type"] = "application/x-www-form-urlencoded"
  discard client.postContent(url, body=fmt("{input}{partNumber}={result}"))

proc hasCachedResult*(input: string, partNumber: int): bool =
  let url = fmt("{urlBase}/{input}{partNumber}")
  try:
    discard client.getContent(url)
    return true
  except:
    return false

proc getCachedResult*(input: string, partNumber: int): int =
  let url = fmt("{urlBase}/{input}{partNumber}")
  client.getContent(url).parseInt()