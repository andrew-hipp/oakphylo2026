globalDoPDF = FALSE # change this if you want to rewrite the pdfs
rogues = FALSE # change this is you really want to rerun the tedious rogues analysis

message('** SCRIPT 00 **')
source('scripts/00_readData.R')
message('** SCRIPT 10 **')
source('scripts/10_compareTrees.R')
message('** SCRIPT 20 **')
source('scripts/20_ordination.R')
message('** SCRIPT 30 **')
source('scripts/30_cladeLoadings.R')

if(rogues){
    message('** SCRIPT 40 **')
    source('scripts/40_rogues.R')
    } else message('** SKIPPING ROGUES ANALYSES **')