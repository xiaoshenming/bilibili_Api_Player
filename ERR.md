hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:92:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:1029:15
 Use explicit types instead of "any", "unknown" (arkts-no-any-unknown)


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:1025:42
 Property 'success' does not exist on type '{ bvid: string; cid: string; title: string; desc: string; type: string; play_info: any; }'.


3 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Home.ets:1029:47
 Property 'videoInfo' does not exist on type '{ bvid: string; cid: string; title: string; desc: string; type: string; play_info: any; }'.


COMPILE RESULT:FAIL {ERROR:4 WARN:2}
> hvigor ERROR: BUILD FAILED in 2 s 989 ms 

Process finished with exit code -1
