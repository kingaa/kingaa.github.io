library(doFuture)

njobs <- 3000
nnode <- 250
nper <- njobs/nnode

## set njobs from the command line
invisible(eval(parse(text=commandArgs(trailingOnly=TRUE))))

cl <- makeClusterMPI(nnode,autostop=TRUE,verbose=TRUE)
plan(cluster,workers=cl)

cat("Starting computation of size",njobs,"using",nnode,"nodes",
  "with",nper,"futures/worker","\n")

tic <- Sys.time()
foreach (
  i = seq_len(njobs),
  .combine=rbind,
  .inorder=FALSE,
  .options.future=list(seed=TRUE,schedule=nper)
) %dofuture% {
  t1 <- Sys.time()
  h <- system("hostname",intern=TRUE)
  pid <- Sys.getpid()
  x <- replicate(20,quantile(rnorm(n=1e7),prob=0.9))
  m <- mean(x)
  t2 <- Sys.time()
  data.frame(id=i,host=h,pid=pid,t1=t1,t2=t2,x=m)
} -> res
toc <- Sys.time()

nwork <- nbrOfWorkers()

cat(nnode,"nodes",nwork,"nworkers",nper,"futures/worker","\n")

library(tidyverse)

res |>
  mutate(etime=difftime(t2,t1,units="secs")) |>
  summarize(
    stime=as.numeric(sum(etime)),
    etime=as.numeric(difftime(max(t2),min(t1),units="secs"))
  ) |>
  mutate(
    otime=as.numeric(difftime(toc,tic,units="secs")),
    ieffic=stime/etime/nwork,
    oeffic=stime/otime/nwork,
    njobs=njobs,
    nnode=nnode,
    nwork=nwork
  ) |>
  pivot_longer(everything()) |>
  mutate(
    y=-seq_along(name),
    label=paste0(name,"\t",signif(value,4))
  ) -> eff

eff$label |> cat(sep="\n")
eff |>
  ggplot(aes(x=1,y=y,label=label))+
  geom_text(hjust="left")+
  theme_void() -> txt

res |>
  ggplot(aes(x=t1,xend=t2,y=id,yend=id,color=host))+
  geom_segment()+
  guides(color="none")+
  theme_bw()+
  labs(x="time",y="job id")+
  annotate("segment",x=tic,xend=toc,y=0,yend=njobs,color="black") -> pl

res |>
  ggplot(aes(x=host,fill=host,color=host))+
  stat_count()+
  labs(x="",y="")+
  guides(fill="none",color="none")+
  theme(axis.text.x=element_text(angle=90,vjust=0.5)) -> pl1

library(grid)
png(filename="dofuture_test.png",width=7,height=8,
  units="in",res=300)
print(pl)
print(txt,vp=viewport(x=0.2,y=0.8,width=0.4,height=0.2))
print(pl1,vp=viewport(x=0.75,y=0.3,width=0.4,height=0.4))
dev.off()
