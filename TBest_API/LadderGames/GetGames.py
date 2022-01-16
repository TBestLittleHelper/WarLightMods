import requests
import json
import time

# TODO get token and email from file
postAPIToken = "*Cr0ccLWcGqvT7c0iyWGF##js511A*6X1Gpxq"
postEmail = "tkjoita@gmail.com"
site = "https://www.warzone.com/API/GameFeed?GameID="
gameID = "1212978"

postData = dict()
postData["Email"] = postEmail
postData["APIToken"] = postAPIToken

gameData = list()

# with open('WarLightMods\TBest_API\LadderGames\gameID.txt') as gameIDtxt:
with open('WarLightMods\TBest_API\LadderGames\simpleTest.txt') as gameIDtxt:
    for line in gameIDtxt:
        row = line.split(',')
        for gameID in row:
            r = requests.post(url=site+gameID, params=postData)

            print(r.url)
            print(r.text)
            gameData[gameID] = r.text
            time.sleep(1)


f = open("gameDataRaw.txt", "w+")
for gameID in gameData:
    f.write(gameID + " " + gameData[gameID]) + "%d\r\n"
f.close
