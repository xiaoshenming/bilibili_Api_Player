hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:13:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:84:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
3 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:25:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:204:10
 Conversion of type 'Record<string, Object>' to type 'number' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.


COMPILE RESULT:FAIL {ERROR:2 WARN:3}
> hvigor ERROR: BUILD FAILED in 3 s 419 ms 

Process finished with exit code -1
