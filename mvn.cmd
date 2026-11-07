@echo off
setlocal
set "JAVA_EXE=C:\Program Files\Java\jdk-21.0.12\bin\java.exe"
set "M2E_JARS=C:\Users\USER\.p2\pool\plugins\org.eclipse.m2e.maven.runtime_3.9.900.20250220-2013\jars\*;C:\Users\USER\.p2\pool\plugins\org.apache.commons.cli_1.9.0.jar;C:\Users\USER\.p2\pool\plugins\slf4j.api_2.0.18.jar;C:\Users\USER\.p2\pool\plugins\slf4j.simple_2.0.17.jar;C:\Users\USER\.m2\repository\javax\inject\javax.inject\1\javax.inject-1.jar;C:\Users\USER\.p2\pool\plugins\com.google.guava_33.4.8.jre.jar;C:\Users\USER\.p2\pool\plugins\com.google.guava.failureaccess_1.0.3.jar"
"%JAVA_EXE%" "-Dmaven.multiModuleProjectDirectory=%~dp0." -cp "%M2E_JARS%" org.apache.maven.cli.MavenCli %*
endlocal
