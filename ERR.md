hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:15:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:859:31
 Use explicit types instead of "any", "unknown" (arkts-no-any-unknown)


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:859:30
 Argument of type '(err: any) => void' is not assignable to parameter of type '() => void'.


COMPILE RESULT:FAIL {ERROR:3 WARN:2}
> hvigor ERROR: BUILD FAILED in 3 s 192 ms 

Process finished with exit code -1
