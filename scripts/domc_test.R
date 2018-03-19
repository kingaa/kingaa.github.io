library(foreach,quietly=TRUE)
library(doMC,quietly=TRUE)

njobs <- 1600
ncore <- 20
chunk <- 1

## set njobs, nnode chunk from the command line
invisible(eval(parse(text=commandArgs(trailingOnly=TRUE))))

nnode <- 1

registerDoMC(ncore)

cat("Starting computation of size",njobs,"using",
    nnode,"nodes, with",
    ncore,"cores/node,",
    "and chunksize",chunk,"\n")

tic <- Sys.time()
res <- foreach (i = seq_len(njobs),
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

suppressMessages(library(aakmisc,quietly=TRUE))
library(magrittr)
library(plyr)
library(reshape2)
library(ggplot2)
library(grid)
library(digest,quietly=TRUE)

cat(nnode,'nodes x',ncore,'cores,','chunksize',chunk,'\n')

res %>% mutate(etime=difftime(t2,t1,units='secs')) %>%
    summarize(stime=as.numeric(sum(etime)),
              etime=as.numeric(difftime(max(t2),min(t1),units="secs"))) %>%
    mutate(otime=as.numeric(difftime(toc,tic,units='secs')),
           ieffic=stime/etime/ncore,
           oeffic=stime/otime/ncore,
           njobs=njobs,
           nnode=nnode,
           ncore=ncore,
           chunk=chunk) %>%
    melt(id=NULL) %>%
    mutate(y=-seq_along(variable),label=paste0(variable,"\t",signif(value,4))) -> eff

eff %>% use_series("label") %>% cat(sep="\n")
eff %>% ggplot(aes(x=1,y=y,label=label))+
    geom_text(hjust="left")+
    theme_void() -> txt

res %>%
    ggplot(aes(x=t1,xend=t2,y=id,yend=id,color=host))+
    geom_segment()+
    guides(color=FALSE)+
    theme_bw()+
    labs(x='time',y='job id')+
    annotate("segment",x=tic,xend=toc,y=0,yend=njobs,color='black') -> pl

res %>%
    ggplot(aes(x=host,fill=host,color=host))+
    stat_count()+
    labs(x="",y="")+
    guides(fill=FALSE,color=FALSE)+
    theme(axis.text.x=element_text(angle=90)) -> pl1

png(filename="domc_test.png",width=7,height=8,
    units='in',res=300)
print(pl)
print(txt,vp=viewport(x=0.2,y=0.8,width=0.4,height=0.2))
print(pl1,vp=viewport(x=0.75,y=0.3,width=0.4,height=0.4))
dev.off()

res %>%
    subset(select=c(id,x)) %>%
    arrange(id) %>%
    set_rownames(NULL) %>%
    digest()

## 1ad5a2898de4e21b2baf3a7b7c88afe5
