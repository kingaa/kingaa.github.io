library(foreach,quietly=TRUE)
suppressMessages(library(aakmisc,quietly=TRUE))
suppressMessages(library(tidyverse,quietly=TRUE))
library(grid,quietly=TRUE)
library(digest,quietly=TRUE)

doMC <- "doMC"
doMPI <- "doMPI"
doParallel <- "doParallel"
doParRNG <- "doParRNG"
doMPIRNG <- "doMPIRNG"
doMCRNG <- "doMCRNG"

## set defaults
njobs <- 2500
logrp <- 7
nnode <- 1
ncore <- 1
chunk <- 1
backend <- doMC
options.mpi <- list()
id <- Sys.getpid()

helpmsg <- sprintf("

usage:
Rscript do_test.R backend=<backend> id=<id> njobs=<njobs> nnode=<nnode> ncore=<ncore> chunk=<chunk>
   --or--
R CMD BATCH --no-save --no-restore '--args backend=<backend> id=<id> njobs=<njobs> logrp=<logrp> nnode=<nnode> ncore=<ncore> chunk=<chunk>' do_test.R

where  <backend> is one of doMC, doMPI, doMPIRNG, doParallel, doParRNG, doMCRNG
       and the other parameters are positive integers
       by default, backend = %s, njobs = %d, logrp = %d, nnode = %d, ncore = %d, chunk = %d, id = pid

",backend,njobs,logrp,nnode,ncore,chunk)

cargs <- commandArgs(trailingOnly=TRUE)
if (length(cargs)==0) {
    cat(helpmsg)
    q(save="no")
}

## set njobs, ncore, chunk from the command line
invisible(eval(parse(text=commandArgs(trailingOnly=TRUE))))

img <- paste0("do_test_",id,".png")

switch(backend,
       doMC={
           library(doMC,quietly=TRUE)
           nnode <- 1
           chunk <- 1
           registerDoMC(ncore)
       },
       doMCRNG={
           library(doMC,quietly=TRUE)
           suppressMessages(library(doRNG,quietly=TRUE))
           nnode <- 1
           chunk <- 1
           registerDoMC(ncore)
           registerDoRNG(1218461302L)
       },
       doMPI={
           library(doMPI,quietly=TRUE)
           cl <- startMPIcluster(count=nnode,maxcores=ncore,logdir="/tmp")
           registerDoMPI(cl)
           options.mpi <- list(chunkSize=chunk,seed=1218461302L)
       },
       doMPIRNG={
           library(doMPI,quietly=TRUE)
           suppressMessages(library(doRNG,quietly=TRUE))
           cl <- startMPIcluster(count=nnode,maxcores=ncore,logdir="/tmp")
           registerDoMPI(cl)
           registerDoRNG(1218461302L)
           options.mpi <- list(chunkSize=chunk)
       },
       doParallel={
           library(doParallel,quietly=TRUE)
           cl <- makeCluster(type="MPI",spec=nnode)
           ncore <- 1
           chunk <- 1
           registerDoParallel(cl)
           clusterSetRNGStream(cl,iseed=1218461302L)
       },
       doParRNG={
           library(doParallel,quietly=TRUE)
           suppressMessages(library(doRNG,quietly=TRUE))
           cl <- makeCluster(type="MPI",spec=nnode)
           ncore <- 1
           chunk <- 1
           registerDoParallel(cl)
           registerDoRNG(1218461302L)
       }
       )

cat(sprintf("Starting computation of size %d, each of size 10^%d, using
    backend %s on %d nodes, with %d cores/node, and chunksize %d\n",
  njobs,logrp,backend,nnode,ncore,chunk))

tic <- Sys.time()
res <- foreach (i = seq_len(njobs),
                .options.mpi=options.mpi,
                .combine=rbind,
                .inorder=FALSE) %dopar% {
                  t1 <- Sys.time()
                  h <- system("hostname",intern=TRUE)
                  pid <- Sys.getpid()
                  x <- quantile(rnorm(n=round(10^logrp)),prob=0.9)
                  t2 <- Sys.time()
                  data.frame(id=i,host=h,pid=pid,t1=t1,t2=t2,x=x)
                }
toc <- Sys.time()

nwork <- getDoParWorkers()

cat(sprintf("%d nodes x %d cores\tchunksize: %d\tnworkers:nwork
output to image file %s\n",ncore,chunk,nwork,sQuote(img)))

if (backend %in% c("doMPI","doMPIRNG")) {
#  closeCluster(cl)
#  invisible(mpi.finalize())
} else if (backend == "doParallel") {
  stopCluster(cl)
}

res %>%
  mutate(
    etime=difftime(t2,t1,units='secs')
  ) %>%
  summarize(
    stime=as.numeric(sum(etime)),
    etime=as.numeric(difftime(max(t2),min(t1),units="secs"))
  ) %>%
  mutate(
    otime=as.numeric(difftime(toc,tic,units='secs')),
    ieffic=signif(stime/etime/nnode/ncore,3),
    oeffic=signif(stime/otime/nnode/ncore,3),
    njobs=njobs,
    logrp=logrp,
    nnode=nnode,
    ncore=ncore,
    nwork=nwork,
    chunk=chunk
  ) %>%
  mutate(
    stime=round(stime,1),
    etime=round(etime,1),
    otime=round(otime,1)
  ) %>%
  gather(variable,value) %>%
  mutate(
    y=-seq_along(variable),
    label=paste0(variable,"\t",value)
  ) -> eff

eff %>% pull(label) %>% cat(sep="\n")

eff %>%
  ggplot(aes(x=1,y=y,label=label))+
  geom_text(hjust="left")+
  theme_void() -> txt

res %>%
  ggplot(aes(x=t1,xend=t2,y=id,yend=id,color=host))+
  geom_segment()+
  guides(color=FALSE)+
  theme_bw()+
  labs(x='time',y='job id',title=paste("with",backend,"backend"))+
  annotate("segment",x=tic,xend=toc,y=0,yend=njobs,color='black') -> pl

res %>%
  ggplot(aes(x=host,fill=host,color=host))+
  stat_count()+
  labs(x="",y="")+
  guides(fill=FALSE,color=FALSE)+
  theme(axis.text.x=element_text(angle=90,vjust=0.5),
        plot.background=element_rect(fill=NA)) -> pl1

png(filename=img,width=7,height=8,units='in',res=300)
print(pl)
print(txt,vp=viewport(x=0.2,y=0.8,width=0.4,height=0.2))
print(pl1,vp=viewport(x=0.75,y=0.3,width=0.4,height=0.4))
dev.off()

res %>%
  select(id,x) %>%
  arrange(id) %>%
  pull(x) %>%
  digest()

mpi.quit()
