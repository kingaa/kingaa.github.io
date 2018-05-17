try({
    cat("
      subroutine hello
      external dblepr
      call dblepr(\" \",-1,0,0)
      call dblepr(\" \",-1,0,0)
      call dblepr(\" \",-1,0,0)
      call dblepr(\"Hello from native FORTRAN!\",-1,0,0)
      call dblepr(\" \",-1,0,0)
      call dblepr(\" \",-1,0,0)
      call dblepr(\" \",-1,0,0)
      end
",file="helloF.f")
    system2(command=R.home("bin/R"),
            args=c("CMD","SHLIB","helloF.f"))
    dyn.load(paste0("helloF",.Platform$dynlib.ext))
    invisible(.Fortran("hello",PACKAGE="helloF"))
    dyn.unload(paste0("helloF",.Platform$dynlib.ext))
    file.remove(list.files(pattern="^helloF\\..*"))
})
