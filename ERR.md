hvigor ERROR: Failed :entry:default@CompileArkTS... 
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
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/api/BilibiliService.ts:4:63
 Importing ArkTS files in JS and TS files is forbidden.


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:5:10
 '"../utils/TokenManager"' has no exported member named 'TokenManager'. Did you mean 'tokenManager'?


3 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:83:11
 Type 'number' is not assignable to type 'string'.


4 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:105:11
 Type 'number' is not assignable to type 'string'.


5 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:52:7
 Type 'number' is not assignable to type 'string'.


6 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:74:7
 Type 'number' is not assignable to type 'string'.


7 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:136:13
 Type 'number' is not assignable to type 'string'.


8 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:220:21
 Type 'string' is not assignable to type 'number'.


COMPILE RESULT:FAIL {ERROR:9 WARN:5}
> hvigor ERROR: BUILD FAILED in 4 s 21 ms 

Process finished with exit code -1
