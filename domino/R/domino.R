
# Environment(package global) variable holding infomation about domino client
# If this gets assigned with true, the commands will be tried to run from default installation path
domino <- new.env()

#Calls a program with or without stdin
domino.call <- function(cmd, stdInput=FALSE) {
  if(domino.notFalse(stdInput)){
    return(system(cmd, input=stdInput))
  } else {
    return(system(cmd))
  }
}

domino.handleCommandNotFound = function(failureMessage){
  stop(paste("Couldn't find domino client in the PATH or in default locations.
  Add domino client directory path to PATH environment variable.
  If you don't have domino client installed follow instructions on 'http://help.dominodatalab.com/client'.
  If you use R-Studio Domino on GNU/Linux through a desktop launcher, add domino path to the .desktop file.

  If you need more help, email support@dominodatalab.com or visit http://help.dominodatalab.com/troubleshooting

  - ", failureMessage), call.=FALSE)
}

domino.osSpecificPrefixOfDominoCommand <- function() {
  switch(Sys.info()["sysname"],
    Darwin = "/Applications/domino/",
    Linux = "~/domino/",
    Windows = "c:\\program files (x86)\\domino\\",
    print("Your operating system is not supported by domino R package.")
  )
}

domino.notFalse <- function(arg) {
  arg != FALSE
}

domino.OK <- function(){return(0)}

domino.projectNameWithoutUser <- function(projectName) {
  basename(projectName)
}

domino.jumpToProjectsWorkingDirectory <- function(projectName) {
  setwd(file.path(".",domino.projectNameWithoutUser(projectName)))
  print("Changed working directory to new project's directory.")
}

.is.domino.in.path <- function() {
  file.exists(Sys.which("domino")) 
}

.open.rStudio.login.prompt <- function(message){
  if(Sys.getenv("RSTUDIO") != "1"){
    stop("The system is not running in RStudio")
  }

  if(!("tools:rstudio" %in% search())){
    stop("Cannot locate RStudio tools")
  }

  toolsEnv <- as.environment("tools:rstudio")
  rStudioLoginPrompt <- get(".rs.askForPassword", envir=toolsEnv)

  rStudioLoginPrompt(message)
}

.domino.login.prompt <- function(){
  passwordPromptMessage <- "Enter your Domino password: "

  # if not in rstudio env or the prompt function is not found,
  # the function will fail => fallback to readLine
  password <- try(.open.rStudio.login.prompt(passwordPromptMessage), silent=T)

  if(inherits(password, "try-error")){
    password <- readline("Enter your Domino password: ")
  }

  if(password == ""){
    password <- NULL
  }

  password
}

.onAttach <- function(libname, pkgname) {
  domino$command_is_in_the_path <- .is.domino.in.path()
}
