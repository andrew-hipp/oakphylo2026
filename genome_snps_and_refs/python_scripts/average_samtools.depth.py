import sys

with open(sys.argv[1],"r") as inp:
	total=0
	sites=0

	for line in inp:
		total+=float(line.split()[2])
		sites+=1

print(sys.argv[1])
print(total/sites)
