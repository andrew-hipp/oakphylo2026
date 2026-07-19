globalDoPDF = FALSE # change this if you want to rewrite the pdfs and csv files
rogues = FALSE # change this is you really want to rerun the tedious rogues analysis

doPPT = FALSE # change this is you also want to run the PPT visualizations, just for presentations

todo <- dir('scripts/')
if(!rogues) todo <- grep('rogues', todo, invert = T, value = T)
if(!doPPT) todo <- grep('PPT', todo, invert = T, value = T)
todo <- grep('99_|doItAll', todo, invert = T, value = T)

for(i in todo) {
    message(paste('*** DOING SCRIPT', i, '***'))
    source(paste('scripts', i, sep = '/'))
}
