> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:79:57
 Usage of 'ESObject' type is restricted (arkts-limited-esobj)

2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:102:61
 Usage of 'ESObject' type is restricted (arkts-limited-esobj)

3 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
4 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:12:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
5 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:25:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
6 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:25:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
7 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:159:24
 The current component id "image1" is duplicate with E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:191:26.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/api/BilibiliService.ts:4:68
 Importing ArkTS files in JS and TS files is forbidden.


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:220:21
 Type 'string' is not assignable to type 'number'.


COMPILE RESULT:FAIL {ERROR:3 WARN:7}
> hvigor ERROR: BUILD FAILED in 2 s 917 ms 

Process finished with exit code -1
