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
