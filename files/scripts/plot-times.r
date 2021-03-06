library(ggplot2)
library(grid)
library(gridExtra)
library(tikzDevice)
library(foreach)
library(doMC)
registerDoMC(1)

#options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

print(paste("args",args))
#registerDoMC(detectCores())

str(paste("Detected",detectCores(), "cores."))

if(length(args)==0){
  dir <- "../dataset/"
}else {
  dir <- args[1]
}
binsize <- 60000

plotArrivalTimes <- function(file){  
  myData<-read.table(file=file,quote="")  
  len <- myData[1,]
  times <- data.frame(V1=myData[-1,])
    
  .e <- environment()
  c <- ggplot(times, aes(V1,width=len),environment = .e) + geom_bar(fill="red",binwidth=binsize)  + labs(x="time", y="event count") + xlim(0,len)+ theme_bw()
    
  e <- ggplot(times,aes(V1,width=len),environment = .e, main="Event arrival times")  + geom_abline(slope=1/len, color="grey", linetype=1,size=1) + xlim(0,len) + theme_bw()+ stat_ecdf()  + labs(x="time", y="perc. of known events")

  # can be tikz or pdf
  pdf(paste(file,".pdf",sep=""),height=6,width=15)    
  grid.arrange(c, e, ncol = 1, main = paste(file,"Event arrival times",sep=" "))
  dev.off()    
}


files <- list.files(path=dir,pattern="*\\.times$",recursive=T,full.names=T)

#str(paste(files,collapse=" "))
#plotArrivalTimes(files[1])

foreach( i=1:length(files)) %dopar%{
  plotArrivalTimes(files[i])
  str("done")
}

#pdfs <- list.files(path=dir,pattern="*\\.times.pdf$",recursive=T)
#str(paste(pdfs,collapse=" "))
#str("merge pdfs")
#cmdStr <- paste("cd ",dir,"; pdftk",paste(pdfs,collapse=" "),"cat output all.pdf", sep=" ")
#system(cmdStr)


