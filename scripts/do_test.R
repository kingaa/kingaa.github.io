library(foreach,quietly=TRUE)
suppressMessages(library(aakmisc,quietly=TRUE))
library(digest,quietly=TRUE)

doMC <- "doMC"
doMPI <- "doMPI"
doParallel <- "doParallel"
doRNG <- "doRNG"
doMCRNG <- "doMCRNG"

## set defaults
njobs <- 1600
nnode <- 1
ncore <- 1
chunk <- 1
backend <- doMC
options.mpi <- list()

## set njobs, ncore, chunk from the command line
invisible(eval(parse(text=commandArgs(trailingOnly=TRUE))))

switch(backend,
       doMC={
         library(doMC,quietly=TRUE)
         nnode <- 1
         registerDoMC(ncore)
       },
       doMCRNG={
         library(doMC,quietly=TRUE)
         suppressMessages(library(doRNG,quietly=TRUE))
         nnode <- 1
         registerDoMC(ncore)
         registerDoRNG(1218461302L)
       },
       doMPI={
         library(doMPI,quietly=TRUE)
         cl <- startMPIcluster(count=nnode,maxcores=ncore)
         registerDoMPI(cl)
         options.mpi <- list(chunkSize=chunk,seed=1218461302L)
       },
       doParallel={
         library(doParallel,quietly=TRUE)
         cl <- makeCluster(type="MPI",spec=nnode)
         ncore <- 1
         registerDoParallel(cl)
         clusterSetRNGStream(cl,iseed=1218461302L)
       },
       doRNG={
         library(doMPI,quietly=TRUE)
         suppressMessages(library(doRNG,quietly=TRUE))
         cl <- startMPIcluster(count=nnode,maxcores=ncore)
         registerDoMPI(cl)
         registerDoRNG(1218461302L)
         options.mpi <- list(chunkSize=chunk)
       }
)

cat("Starting computation of size",njobs,"using",
    nnode,"nodes, with",
    ncore,"cores/node,",
    "and chunksize",chunk,"\n")

tic <- Sys.time()
res <- foreach (i = seq_len(njobs),
                .options.mpi=options.mpi,
                .combine=rbind,
                .inorder=FALSE) %dopar% {
                  t1 <- Sys.time()
                  h <- system("hostname",intern=TRUE)
                  pid <- Sys.getpid()
                  x <- quantile(rnorm(n=10000000),prob=0.9)
                  t2 <- Sys.time()
                  data.frame(id=i,host=h,pid=pid,t1=t1,t2=t2,x=x)
                }
toc <- Sys.time()

nwork <- getDoParWorkers()

cat(nnode,'nodes x',ncore,'cores','\tchunksize:',chunk,'\tnworkers:',nwork,'\n')

if (backend %in% c("doMPI","doRNG")) {
  closeCluster(cl)
  invisible(mpi.finalize())
} else if (backend == "doParallel") {
  stopCluster(cl)
}

res %>%
  mutate(etime=difftime(t2,t1,units='secs')) %>%
  summarize(stime=as.numeric(sum(etime)),
            etime=as.numeric(difftime(max(t2),min(t1),units="secs"))) %>%
  mutate(
    otime=round(as.numeric(difftime(toc,tic,units='secs')),1),
    ieffic=signif(stime/etime/nwork,3),
    oeffic=signif(stime/otime/nwork,3),
    stime=round(stime,1),
    etime=round(etime,1),
    njobs=njobs,
    nnode=nnode,
    ncore=ncore,
    nwork=nwork,
    chunk=chunk) %>%
  melt(id=NULL) %>%
  mutate(
    y=-seq_along(variable),
    label=paste0(variable,"\t",value)
  ) -> eff

eff %>% use_series("label") %>% cat(sep="\n")
eff %>% ggplot(aes(x=1,y=y,label=label))+
  geom_text(hjust="left")+
  theme_void() -> txt

res %>%
  ggplot(aes(x=t1,xend=t2,y=id,yend=id,color=host))+
  geom_segment()+
  guides(color=FALSE)+
  theme_bw()+
  labs(x='time',y='job id',
       title=paste("with",backend,"backend"))+
  annotate("segment",x=tic,xend=toc,y=0,yend=njobs,color='black') -> pl

res %>%
  ggplot(aes(x=host,fill=host,color=host))+
  stat_count()+
  labs(x="",y="")+
  guides(fill=FALSE,color=FALSE)+
  theme(axis.text.x=element_text(angle=90),
        plot.background=element_rect(fill=NA)) -> pl1

png(filename="do_test.png",width=7,height=8,units='in',res=300)
print(pl)
print(txt,vp=viewport(x=0.2,y=0.8,width=0.4,height=0.2))
print(pl1,vp=viewport(x=0.75,y=0.3,width=0.4,height=0.4))
dev.off()

res %>%
  subset(select=c(id,x)) %>%
  arrange(id) %>%
  set_rownames(NULL) %>%
  digest()
