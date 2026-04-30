import sys

with open(sys.argv[1],"r") as inp:
    with open(sys.argv[2],"w+") as out:

        for line in inp:
            if line[0]!= ">":

                out.write(line)

            else:
                if "Chr" in line:
                    out.write(line)

                else:
                    break
