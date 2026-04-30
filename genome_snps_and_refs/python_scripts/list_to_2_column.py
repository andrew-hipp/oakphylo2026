import sys

stored=""
with open(sys.argv[1],"r") as lst:
	for line in lst:
		if stored == "":
			stored=line.strip()
		else:
			print(stored+"\t"+line.strip())
			stored=""
