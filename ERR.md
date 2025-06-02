hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:15:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:378:11
 Type 'string | undefined' is not assignable to type 'Object'.
  Type 'undefined' is not assignable to type 'Object'.


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:379:11
 Type 'string | undefined' is not assignable to type 'Object'.
  Type 'undefined' is not assignable to type 'Object'.


3 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:378:12
 Conversion of type 'VideoData' to type 'Record<string, Object>' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.
  Index signature for type 'string' is missing in type 'VideoData'.


4 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:379:12
 Conversion of type 'VideoData' to type 'Record<string, Object>' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.


5 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:443:25
 Conversion of type 'VideoData' to type 'Record<string, Object>' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.


6 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:482:12
 Conversion of type 'VideoData' to type 'Record<string, Object>' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.


7 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:483:12
 Conversion of type 'VideoData' to type 'Record<string, Object>' may be a mistake because neither type sufficiently overlaps with the other. If this was intentional, convert the expression to 'unknown' first.


COMPILE RESULT:FAIL {ERROR:8 WARN:2}
> hvigor ERROR: BUILD FAILED in 3 s 180 ms 

Process finished with exit code -1
