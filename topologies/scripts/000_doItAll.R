globalDoPDF = FALSE # change this if you want to rewrite the pdfs
rogues = FALSE # change this is you really want to rerun the tedious rogues analysis

todo <- dir('scripts/')
if(!rogues) todo <- grep('rogues', todo, invert = T, value = T)
todo <- grep('99_|doItAll', todo, invert = T, value = T)

for(i in todo) {
    message(paste('*** DOING SCRIPT', i, '***'))
    source(paste('scripts', i, sep = '/'))
}
