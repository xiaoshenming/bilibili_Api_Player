hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor ERROR: ArkTS Compiler Error
1 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
2 WARN: ArkTS:WARN File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:15:1
 It's not a recommended way to export struct with @Entry decorator, which may cause ACE Engine error in component preview mode.
1 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:357:75
 Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals)


2 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/pages/VideoPlayer.ets:358:11
 It is possible to spread only arrays or classes derived from arrays into the rest parameter or array literals (arkts-no-spread)


3 ERROR: ArkTS:ERROR File: E:/DevEcoStudioProjects/bilibili_Api_Player/entry/src/main/ets/view/Dynamic.ets:198:53
 Type '{ id: number; bvid: string; title: string; pic: string; duration: string; view: string; danmaku: string; like: string; coin: string; share: string; favorite: string; reply: string; owner_name: string; owner_face: string; pubdate: string; tname: string; download_link: string; current_viewers: string; }' is missing the following properties from type 'UserVideoInfo': quality, aid, desc, name, and 5 more.


COMPILE RESULT:FAIL {ERROR:4 WARN:2}
> hvigor ERROR: BUILD FAILED in 3 s 416 ms 

Process finished with exit code -1
