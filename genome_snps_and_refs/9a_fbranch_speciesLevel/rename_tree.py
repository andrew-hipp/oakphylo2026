import sys, re

nameDict={}
with open(sys.argv[1],"r") as table:
    
    for line in table:

        splits=line.strip().split()

        nameDict[splits[0]]=splits[1]
        

with open(sys.argv[2],"r") as inTree:

    with open(sys.argv[3],"w+") as outTree:

        for line in inTree:

            for name in nameDict:

                line=line.replace(name,nameDict[name])

        outTree.write(line+"\n")
