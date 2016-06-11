try({
    cat("#include <R.h>
     void hello (void) {
     Rprintf(\"\\\n\\n\\nHello from native C!\\n\\n\\n\");
     }",file="helloC.c")
    system2(command=R.home("bin/R"),
            args=c("CMD","SHLIB","helloC.c"))
    dyn.load(paste0("helloC",.Platform$dynlib.ext))
    invisible(.C("hello",PACKAGE="helloC"))
    dyn.unload(paste0("helloC",.Platform$dynlib.ext))
    file.remove(list.files(pattern="^helloC\\..*"))
})

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
