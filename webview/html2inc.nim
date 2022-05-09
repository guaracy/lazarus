import std/[os,strutils]

proc html2inc(fi:string) =
  let fo = splitFile(fi)[1] & ".inc"
  echo fi," -> ",fo
  let content = readFile(fi)
  writeFile(fo, "'" & content.replace("\n","").replace("'","''") & "';")


for f in walkFiles("*.html"):
  html2inc(f)
