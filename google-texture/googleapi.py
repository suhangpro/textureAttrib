#!/usr/bin/python2
# -*- coding: utf-8 -*-

import pprint

from apiclient.discovery import build

# fabric(cloth fiber thread embroidery rug) metal(gold silver aluminum steel copper) wood glass grass stone(marble) fur(skin animal feather) art (painting) camo digital (technology, 

def imageSearch(query,start=1,total=10):
    service = build("customsearch", "v1",
        developerKey="AIzaSyBEk6P0F3OB9s7-4uTHjl46pbxZawaGFsE")
    cnt=0
    resList = []
    while cnt < total:
        num = min(10,total-cnt)
        res = service.cse().list(
            q=query,
            cx='017873474401332503406:hzyj2kj424w',
            searchType='image',
            imgColorType='color',
            start= start,
            num=num
            ).execute()
        start = start + num
        cnt = cnt + num
        resList.append(res)
        for i in range(len(res[u'items'])):
            print(res[u'items'][i][u'link'])
    #return resList
    
def main():
    imageSearch(query='fabric texture',total=100)
    # pprint.pprint(res)

if __name__ == '__main__':
  main()
