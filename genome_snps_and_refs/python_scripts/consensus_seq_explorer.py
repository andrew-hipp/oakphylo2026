import sys

num_Q=0
num_n=0
num_N=0
num_dash=0
other=0

with open(sys.argv[1],"r") as fasta:

    for line in fasta:

        if line[0]!=">":

            for letter in line:
                if letter == "?":
                    num_Q+=1
                elif letter == "n":
                    num_n+=1
                elif letter == "N":
                    num_N+=1
                elif letter == "-":
                    num_dash+=1
                else:
                    other+=1

print("?s:"+str(num_Q))
print("ns:"+str(num_n))
print("Ns:"+str(num_N))
print("-s:"+str(num_dash))
print("All others:"+str(other))         
