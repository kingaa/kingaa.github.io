site_environ <- Sys.getenv("R_ENVIRON")
if (nchar(site_environ)==0 && file.exists(file.path(R.home(),"etc/Renviron.site"))) {
    site_environ <- file.path(R.home(),"etc/Renviron.site")
}
if (nchar(site_environ)>0) {
    cat("\n-----------------------------------\n",
        "contents of site Renviron file",
        "\n-----------------------------------\n")
    cat(readLines(site_environ),sep="\n")
}

user_environ <- Sys.getenv("R_ENVIRON_USER")
if (nchar(user_environ)==0) {
    if (file.exists(file.path(getwd(),".Renviron")))
        user_environ <- file.path(getwd(),".Renviron")
    else if (file.exists(file.path(Sys.getenv("HOME"),".Renviron")))
        user_environ <- file.path(Sys.getenv("HOME"),".Renviron")
}
if (nchar(user_environ)>0) {
    cat("\n-----------------------------------\n",
        "contents of user Renviron file",
        "\n-----------------------------------\n")
    cat(readLines(user_environ),sep="\n")
}

site_profile <- Sys.getenv("R_PROFILE")
if (nchar(site_profile)==0 && file.exists(file.path(R.home(),"etc/Rprofile.site"))) {
    site_profile <- file.path(R.home(),"etc/Rprofile.site")
}
if (nchar(site_profile)>0) {
    cat("\n-----------------------------------\n",
        "contents of site Rprofile file",
        "\n-----------------------------------\n")
    cat(readLines(site_profile),sep="\n")
}

user_profile <- Sys.getenv("R_PROFILE_USER")
if (nchar(user_profile)==0) {
    if (file.exists(file.path(getwd(),".Rprofile")))
        user_profile <- file.path(getwd(),".Rprofile")
    else if (file.exists(file.path(Sys.getenv("HOME"),".Rprofile")))
        user_profile <- file.path(Sys.getenv("HOME"),".Rprofile")
}
if (nchar(user_profile)>0) {
    cat("\n-----------------------------------\n",
        "contents of user Rprofile file",
        "\n-----------------------------------\n")
    cat(readLines(user_profile),sep="\n")
}


site_makevars <- tools::makevars_site()
if (isTRUE(nchar(site_makevars)>0)) {
    cat("\n-----------------------------------\n",
        "contents of site Makevars file",
        "\n-----------------------------------\n")
    cat(readLines(site_makevars),sep="\n")
}

user_makevars <- tools::makevars_user()
if (isTRUE(nchar(user_makevars)>0)) {
    cat("\n-----------------------------------\n",
        "contents of user Makevars file",
        "\n-----------------------------------\n")
    cat(readLines(user_makevars),sep="\n")
}

cat("\n-----------------------------------\n",
    "sessionInfo",
    "\n-----------------------------------\n")
print(sessionInfo())

