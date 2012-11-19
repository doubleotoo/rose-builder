
See [Ant's "Javac" Task](http://ant.apache.org/manual/Tasks/javac.html).

```
It is possible to use different compilers. This can be specified by either setting the global build.compiler property, which will affect all <javac> tasks throughout the build, by setting the compiler attribute, specific to the current <javac> task or by using a nested element of any typedeffed or componentdeffed type that implements org.apache.tools.ant.taskdefs.compilers.CompilerAdapter. Valid values for either the build.compiler property or the compiler attribute are:

    classic (the standard compiler of JDK 1.1/1.2) – javac1.1 and javac1.2 can be used as aliases.
    modern (the standard compiler of JDK 1.3/1.4/1.5/1.6/1.7) – javac1.3 and javac1.4 and javac1.5 and javac1.6 and javac1.7 (since Ant 1.8.2) can be used as aliases.
    jikes (the Jikes compiler).
    jvc (the Command-Line Compiler from Microsoft's SDK for Java / Visual J++) – microsoft can be used as an alias.
    kjc (the kopi compiler).
    gcj (the gcj compiler from gcc).
    sj (Symantec java compiler) – symantec can be used as an alias.
    extJavac (run either modern or classic in a JVM of its own).
```

Relevant options:

  ```
  $ ant -Dbuild.compiler=mycompiler  
  ```

* executable:

  Complete path to the javac executable to use in case of fork="yes". Defaults
  to the compiler of the Java version that is currently running Ant. Ignored if
  fork="no".

  Since Ant 1.6 this attribute can also be used to specify the path to the
  executable when using jikes, jvc, gcj or sj.

  Also see [Override the compiler attribute in an Ant javac task](http://stackoverflow.com/questions/235363/override-the-compiler-attribute-in-an-ant-javac-task)

* fork:

  Whether to execute javac using the JDK compiler externally; defaults to no.

  Fork instructs Ant to launch a new JVM subprocess in which to run javac
  See [Passing Compiler Args](http://stackoverflow.com/questions/4134803/ant-passing-compilerarg-into-javac)

