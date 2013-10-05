android-instrumentation
=======================

android-instrumentation allows to inspect and modify every method parameter in an Android app at runtime.

This is done using by instrumenting the app's bytecode with hooks before each interesting method call. The hook function will be able to read and modigy all paramters of the subsequent call.

The tool is still under development. It works for non-primitive method paramenters, but is still a bit cumbersome to use. Feel free to contribute!


