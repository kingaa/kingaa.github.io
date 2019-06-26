## TEST SCRIPT
## If this script runs without errors, pomp is usable on your system.

lib <- Sys.getenv("R_LIBS_USER")
dir.create(lib,recursive=TRUE,showWarnings=FALSE)

cat("Installing pomp from CRAN....\n")

install.packages("pomp",dependencies=TRUE,lib=lib)

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
  stop("pomp installation failure! Consult the instructions!",
    conditionMessage(e),call.=FALSE)
}
)
