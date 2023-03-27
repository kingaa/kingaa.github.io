## This script will edit files so as to replace calls
## to deprecated *pomp* functions with their proper replacements.
## Usage:
## 1. Make a directory and copy all files that you wish to edit into it.
## 2. In an R session, source this script.
## 3. Call the `to_snake_case` function with the path to your new
##    directory as its sole argument
## 4. Examine the differences between the files for correctness.
##
## The script requires version R version >= 4.2

to_snake_case <- function (dir, extensions = c("R", "Rmd", "Rnw")) {

  stopifnot(`insufficient R version`=getRversion()>="4.2")
  
  require(readr,quietly=TRUE)
  require(stringi,quietly=TRUE)

  oldnames <- c(
    r"{filter.mean}",
    r"{pred.mean}",
    r"{pred.var}",
    r"{filter.traj}",
    r"{cond.logLik}",
    r"{save.states}",
    r"{saved.states}",
    r"{eff.sample.size}",
    r"{as.pomp}",
    r"{mvn.rw}",
    r"{mvn.diag.rw}",
    r"{mvn.rw.adaptive}",
    r"{probe.acf}",
    r"{probe.ccf}",
    r"{probe.marginal}",
    r"{probe.mean}",
    r"{probe.median}",
    r"{probe.nlar}",
    r"{probe.period}",
    r"{probe.quantile}",
    r"{probe.sd}",
    r"{probe.var}",
    r"{periodic.bspline.basis}",
    r"{bspline.basis}",
    r"{rw.sd}"
  )

  oldnames |>
    stri_replace_all_fixed(
      pattern=r"{.}",
      replacement=r"{\.}"
    ) |>
    paste0(
      r"{(\s?)\(}"
    ) -> patt

  oldnames |>
    stri_replace_all_fixed(
      pattern=r"{.}",
      replacement=r"{_}"
    ) |>
    paste0(
      r"{$1\(}"
    ) -> repl

  lapply(
    paste0(r"{^.*\.}",extensions,r"{$}"),
    \(.) list.files(path=dir,pattern=.,full.names=TRUE)
  ) |>
    do.call(c,args=_) -> filelist
      
  cat(
    "scanning files:\n",
    paste("\t",filelist,sep="",collapse="\n"),
    "\n\n"
  )

  filelist |>
    sapply(
      \(file) {
        read_file(file) -> s
        s |>
          stri_replace_all_regex(
            pattern=patt,
            replacement=repl,
            vectorize_all=FALSE
          ) -> t
        t |> write_file(file)
        s != t
      }
    ) -> res

  if (any(res)) {
    paste(
      "modified files:\n",
      paste("\t",filelist[res],sep="",collapse="\n")
    ) |> cat("\n")
  } else {
    cat("no files modified\n")
  }

}
