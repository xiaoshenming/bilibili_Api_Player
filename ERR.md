hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:15:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:91:18
 Property 'parseVideoFromParamsAsync' does not exist on type 'VideoPlayer'. Did you mean 'parseVideoFromParams'?


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:119:12
 Property 'parseVideoFromParamsAsync' does not exist on type 'VideoPlayer'. Did you mean 'parseVideoFromParams'?


3 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:759:16
 Property 'handleVideoSwipe' does not exist on type 'VideoPlayer'.


COMPILE RESULT:FAIL {ERROR:4 WARN:1}
> hvigor ERROR: BUILD FAILED in 3 s 683 ms 

Process finished with exit code -1
