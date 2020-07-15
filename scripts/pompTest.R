## TEST SCRIPT
## If this script runs without errors, pomp is usable on your system.

pomp.version <- "3.1"

lib <- Sys.getenv("R_LIBS_USER")
dir.create(lib,recursive=TRUE,showWarnings=FALSE)

cat("Checking whether dependencies are installed....\n")
## install dependencies if necessary
deps <- setdiff(
  c("digest","mvtnorm","deSolve","coda","subplex","nloptr",
    "magrittr","plyr","reshape2","pomp"),
  rownames(installed.packages())
)
if (length(deps) > 0) {
  cat("Installing dependencies....\n")
  install.packages(deps,lib=lib)
}

if (packageVersion("pomp") < pomp.version) {
  update.packages("pomp",lib.loc=lib,ask=FALSE)
}

## test pomp
cat("Testing",sQuote("pomp"),"....\n")
library(pomp,lib.loc=lib)

cat("Trying to compile C snippets,....\n")
tryCatch(
{
  simulate(
    times=1:50,
    t0=0,
    rmeasure=Csnippet("
          Y = rlnorm(log(X),tau);"),
    dmeasure=Csnippet("
          lik = dlnorm(Y,log(X),tau,give_log);"),
    rprocess=discrete_time(
      step.fun=Csnippet("
          double S = exp(-r*dt);
          double eps = rlnorm(0,sigma);
          X = pow(K,(1-S))*pow(X,S)*eps;"),
      delta.t=1
    ),
    obsnames="Y",
    paramnames=c("sigma","tau","r","K"),
    statenames="X",
    params=c(r=0.1,K=1,sigma=0.1,tau=0.1,X.0=1)
  ) %>%
    pfilter(Np=1000) -> p
  
  cat("Success!\n")
},
error=function (e) {
  stop("pomp installation failure! Consult the instructions!\n",
    conditionMessage(e),call.=FALSE)
}
)
