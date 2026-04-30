

#GSF3714-DL331-2_S1.Qalba.fa
#?s:73298269
#ns:37086882
#Ns:32524616
#-s:0
#All others:640600214
#GSF3714-DL331-2_S1.Qvar.fa
#?s:281598643
#ns:66818191
#Ns:83347463
#-s:0
#All others:369571925


info=[]

with open("consensus_stats.list","r") as inp:

    cur_list=""

    for line in inp:
        if line.strip()[-3:] == ".fa":
            if cur_list!="":
                info.append(cur_list)
            cur_header=line.strip()
            cur_list=[cur_header]
        else:
            cur_list.append(line.strip().split(":")[1])

info.append(cur_list)


with open("consensus_stats.csv","w+"):
    print("File,?s,ns,Ns,-s,other")
    for item in info:
        print(",".join(item))



