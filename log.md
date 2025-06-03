0/JSAPP                    apppool               I     Callee constructor is OK string
06-03 08:18:11.643   8774-8774     A03d00/JSAPP                    apppool               I     Ability::constructor callee is object [object Object]
06-03 08:18:11.690   8774-8774     A00000/testTag                  com.examp...i_player  I     Ability onCreate
06-03 08:18:11.795   8774-8774     A00000/testTag                  com.examp...i_player  I     Ability onWindowStageCreate
06-03 08:18:11.813   8774-8774     A00000/testTag                  com.examp...i_player  I     Ability onForeground
06-03 08:18:11.956   8774-8774     A00000/testTag                  com.examp...i_player  I     Succeeded in loading the content.
06-03 08:18:18.683   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     1
06-03 08:18:20.650   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     Token found, verifying with backend...
06-03 08:18:20.673   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     HTTP Error: 401, Message: {"code":401,"message":"无效的 Token","data":null}
06-03 08:18:20.673   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     Request failed for http://10.23.55.31:11111/api/status. Error: 网络请求失败，错误码: 401
06-03 08:18:20.673   8774-8774     A03d00/JSAPP                    com.examp...i_player  W     Token验证失败: 网络请求失败，错误码: 401
06-03 08:18:20.683   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     Token deleted successfully.
06-03 08:18:20.683   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     已清除无效token
06-03 08:18:20.683   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     跳转到登录页
06-03 08:18:35.668   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     Token saved successfully.
06-03 08:18:35.736   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:18:35.737   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚠️ 没有token，使用备用SESSDATA
06-03 08:18:35.737   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔧 已设置备用SESSDATA
06-03 08:18:35.737   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 当前使用的SESSDATA: 59a10793,1762276359,...
06-03 08:18:35.814   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 AppStorage中没有已验证token，尝试从本地存储获取
06-03 08:18:35.814   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     成功获取UIAbilityContext，开始获取token
06-03 08:18:35.815   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ✅ 成功获取用户token: eyJhbGciOi...
06-03 08:18:35.816   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 开始获取哔哩哔哩鉴权信息...
06-03 08:18:35.840   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📥 API返回的鉴权信息: [object Object]
06-03 08:18:35.840   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ✅ 获取哔哩哔哩鉴权信息成功: [object Object]
06-03 08:18:35.840   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 鉴权信息加载成功，尝试加载推荐视频
06-03 08:18:35.840   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     getBilibiliRecommendVideos: 后端暂无此API，将回退到原有数据加载方式
06-03 08:18:35.840   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     加载推荐视频失败: Error: recommend-videos API暂未实现，回退到原有方式
06-03 08:18:35.841   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 检测到用户token，尝试获取动态SESSDATA...
06-03 08:18:35.858   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📋 获取鉴权信息成功: [object Object]
06-03 08:18:35.858   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ✅ 成功获取动态SESSDATA
06-03 08:18:35.858   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 当前使用的SESSDATA: a2adc98f,1764252534,...
06-03 08:18:36.039   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     {"code":0,"message":"0","ttl":1,"data":{"item":[{"id":114601337295489,"bvid":"BV1dW7wzxEvd","cid":30251288049,"goto":"av","uri":"https://www.bilibili.com/video/BV1dW7wzxEvd","pic":"http://i0.hdslb.com/bfs/archive/171a416a25a9463e98bdadc47006ac1a2d9cc5ed.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/a1bd0a5caf318bc245ed82a19e6216f8054edb37.jpg","title":"【整合包品史官】-8分《齿轮颂歌：暮光》评测：充满恶意的傲慢之作","duration":499,"pubdate":1748692800,"owner":{"mid":3546749241133095,"name":"浊墨染水","face":"https://i0.hdslb.com/bfs/face/819dc16ee416bd99c2748f664a0be6cd5f255445.jpg"},"stat":{"view":31963,"like":684,"danmaku":36,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-5xz2x.1748909915816.562","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114584476192765,"bvid":"BV1gKjBzDEmC","cid":30193812097,"goto":"av","uri":"https://www.bilibili.com/video/BV1gKjBzDEmC","pic":"http://i1.hdslb.com/bfs/archive/71d422721d10353ed28fd692d53b635604fbbf88.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/e084d79f9490915be269661c4afddd0072875c12.jpg","title":"我叫MT为什么不更新了？动画版《三国演义》为什么不火？不思凡如何走上动画的道路的？","duration":2775,"pubdate":1748428200,"owner":{"mid":17055002,"name":"5毒士","face":"https://i2.hdslb.com/bfs/face/c48eef856724d053fd4cd30c14c44a0ee62d2a62.jpg"},"stat":{"view":565675,"like":5007,"danmaku":2001,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-5xz2x.1748909915816.562","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114596488745523,"bvid":"BV17Z7pz9EZ9","cid":30230840890,"goto":"av","uri":"https://www.bilibili.com/video/BV17Z7pz9EZ9","pic":"http://i0.hdslb.com/bfs/archive/0fc5be8278d88acdcc99d3e715acb8abc8bda13c.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/f464e1ecbf28b79704c09a454959040f76b62d18.jpg","title":"2025逆袭爽文，在车圈上演了","duration":515,"pubdate":1748604838,"owner":{"mid":11799651,"name":"利利川","face":"https://i0.hdslb.com/bfs/face/20d1b0a6be784c110c15d6b43fd19ad261661770.jpg"},"stat":{"view":368049,"like":5234,"danmaku":734,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-5xz2x.1748909915816.562","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114456549924355,"bvid":"BV1KfV6zGE7p","cid":29811344940,"goto":"av","uri":"https://www.bilibili.com/video/BV1KfV6zGE7p","pic":"http://i0.hdslb.com/bfs/archive/94c475419fd56d2f89fd488dad1615d74dd55c55.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/a5f6eea9d5490d741afe0c734bbd2c0c94727e5e.jpg","title":"巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？","duration":383,"pubdate":1746522000,"owner":{"mid":425466465,"name":"解说老勤","face":"https://i0.hdslb.com/bfs/face/e647f0f3563423aebc21cab9607f92f267016ea5.jpg"},"stat":{"view":330907,"like":4370,"danmaku":153,"vt":0},"av_feature":null,"is_followed":1,"rcmd_reason":{"reason_type":1},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-5xz2x.1748909915816.562","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114535268622293,"bvid":"BV1nZEdzdESm","cid":30045372829,"goto":"av","uri":"https://www.bilibili.com/video/BV1nZEdzdESm","pic":"http://i1.hdslb.com/bfs/archive/98166601099205791bdf8c7f6082a734dfe70a5c.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/ab7cfe7a26a25164f0ff34a53f4a5599c71e95f6.jpg","title":"Thaumcraft VII 
06-03 08:18:36.195   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     {"code":0,"message":"0","ttl":1,"data":{"item":[{"id":114482856598676,"bvid":"BV1ehVozvExD","cid":29888217135,"goto":"av","uri":"https://www.bilibili.com/video/BV1ehVozvExD","pic":"http://i2.hdslb.com/bfs/archive/627ae8a343ea0ebcbc4d5bf2e8541f95e4bc4da1.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/a08447cc290e2f952782cb1797be7353ef4ce649.jpg","title":"【食雪报告】快跑！抢先体验做成抢先赤石😅新时代射击大粪作——《La Quimera》","duration":501,"pubdate":1746870257,"owner":{"mid":35223862,"name":"紫骷","face":"https://i1.hdslb.com/bfs/face/3aeabf0b7d3c3416229adbff3b0996ba5851a15b.jpg"},"stat":{"view":204014,"like":5407,"danmaku":510,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-hz9vc.1748909915904.444","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114612913577800,"bvid":"BV17c7UzZEUx","cid":30283727891,"goto":"av","uri":"https://www.bilibili.com/video/BV17c7UzZEUx","pic":"http://i1.hdslb.com/bfs/archive/e91f1c4106fdc20401e6dc69503a95e56ccac958.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/20615e7497a584da4386b9244b06b057990b1d9c.jpg","title":"🚀Kilo Code横空出世：完美融合Cline和Roo Code所有优势，彻底解决卡死bug，支持5种智能模式，20美金免费额度，自动触发上下文压缩","duration":493,"pubdate":1748854646,"owner":{"mid":3493277319825652,"name":"AI超元域","face":"https://i1.hdslb.com/bfs/face/c6eaa43c435acaa8a7eec57e6447c2858e088c13.jpg"},"stat":{"view":2659,"like":101,"danmaku":1,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-hz9vc.1748909915904.444","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114596488745523,"bvid":"BV17Z7pz9EZ9","cid":30230840890,"goto":"av","uri":"https://www.bilibili.com/video/BV17Z7pz9EZ9","pic":"http://i0.hdslb.com/bfs/archive/0fc5be8278d88acdcc99d3e715acb8abc8bda13c.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/f464e1ecbf28b79704c09a454959040f76b62d18.jpg","title":"2025逆袭爽文，在车圈上演了","duration":515,"pubdate":1748604838,"owner":{"mid":11799651,"name":"利利川","face":"https://i0.hdslb.com/bfs/face/20d1b0a6be784c110c15d6b43fd19ad261661770.jpg"},"stat":{"view":368049,"like":5234,"danmaku":734,"vt":0},"av_feature":null,"is_followed":0,"rcmd_reason":{"reason_type":0},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-hz9vc.1748909915904.444","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114590331439772,"bvid":"BV1oq7Gz4Ebi","cid":30211244202,"goto":"av","uri":"https://www.bilibili.com/video/BV1oq7Gz4Ebi","pic":"http://i1.hdslb.com/bfs/archive/d1526ad5488a507653999a821c4a868547e3fc29.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/3873313a6be8f3170ea3f81c0a632c5322b4d141.jpg","title":"小学生唱《天外来物》火了，一开口比薛之谦还痛，惊呆一旁老父亲","duration":285,"pubdate":1748852100,"owner":{"mid":11173348,"name":"下饭音乐","face":"https://i1.hdslb.com/bfs/face/b124978fb6ef042762adbe078f132b79430052e1.jpg"},"stat":{"view":4826,"like":263,"danmaku":4,"vt":0},"av_feature":null,"is_followed":1,"rcmd_reason":{"reason_type":1},"show_info":1,"track_id":"web_pegasus_2.router-web-pegasus-2066609-f444db476-hz9vc.1748909915904.444","pos":0,"room_info":null,"ogv_info":null,"business_info":null,"is_stock":0,"enable_vt":0,"vt_display":"","dislike_switch":1,"dislike_switch_pc":1},{"id":114603937827996,"bvid":"BV1M17MziEof","cid":30255680216,"goto":"av","uri":"https://www.bilibili.com/video/BV1M17MziEof","pic":"http://i0.hdslb.com/bfs/archive/5cce5f3f68ac0664bd021b4894d1d2afecd6543f.jpg","pic_4_3":"http://i0.hdslb.com/bfs/archive/3a546
06-03 08:19:28.625   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:19:28.625   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:19:28.625   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 历史
06-03 08:19:28.625   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：点击视频进行历史记录观看
06-03 08:19:28.662   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🆕 点击的是推荐视频，将其插入到历史列表开头
06-03 08:19:28.662   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：开始异步解析推荐视频: BV1KfV6zGE7p
06-03 08:19:28.663   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 开始异步解析推荐视频: BV1KfV6zGE7p
06-03 08:19:28.663   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔗 视频URL: https://www.bilibili.com/video/BV1KfV6zGE7p
06-03 08:19:28.663   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 调用/video/process接口解析视频: BV1KfV6zGE7p
06-03 08:19:28.665   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 推荐视频 BV1KfV6zGE7p 解析任务已提交，用户可以观看历史视频等待解析完成
06-03 08:19:28.665   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 开始预加载其他历史视频的播放链接...
06-03 08:19:28.665   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🧠 开始预加载5个历史视频的播放链接
06-03 08:19:28.665   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1xwjXzSEXh 已有播放链接，跳过预加载
06-03 08:19:28.666   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV14XVbz2ECh 已有播放链接，跳过预加载
06-03 08:19:28.666   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1UrjrzWEUF 已有播放链接，跳过预加载
06-03 08:19:28.666   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 最终验证第一个视频播放链接: 
06-03 08:19:28.666   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⏳ 推荐视频 BV1KfV6zGE7p 正在异步解析中，用户可以先观看历史视频
06-03 08:19:28.666   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 跳转到视频播放页面，第一个视频: BV1KfV6zGE7p
06-03 08:19:28.669   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 1 预加载完成
06-03 08:19:28.670   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1kJjoz9En1 已有播放链接，跳过预加载
06-03 08:19:28.670   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1bA5kzHEei 已有播放链接，跳过预加载
06-03 08:19:28.670   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 2 预加载完成
06-03 08:19:28.671   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 历史视频预加载完成，共处理5个视频
06-03 08:19:29.088   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:19:29.103   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     HTTP Error: 403, Message: {"code":403,"message":"无权限下载该文件","data":null}
06-03 08:19:29.103   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     Request failed for http://10.23.55.31:11111/api/video/generate-download-link. Error: 网络请求失败，错误码: 403
06-03 08:19:29.103   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     确保视频可播放时出错: Error: 网络请求失败，错误码: 403
06-03 08:19:31.123   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     HTTP Error: 403, Message: {"code":403,"message":"无权限下载该文件","data":null}
06-03 08:19:31.123   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     Request failed for http://10.23.55.31:11111/api/video/generate-download-link. Error: 网络请求失败，错误码: 403
06-03 08:19:31.123   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     预加载视频BV1KfV6zGE7p时出错: Error: 网络请求失败，错误码: 403
06-03 08:19:53.556   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ✅ 视频解析成功: BV1KfV6zGE7p
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔗 播放链接: http://10.23.55.31:11111/api/video/download/BV1KfV6zGE7p.mp4
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📋 视频标题: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📁 文件路径: E:\计算机类\Node.js\chap2\bilibili_server\videos\BV1KfV6zGE7p.mp4
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 质量描述: 1080P 高清
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 已更新点击视频的播放链接: BV1KfV6zGE7p
06-03 08:19:53.557   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 推荐视频 BV1KfV6zGE7p 解析完成，已通知播放页面
06-03 08:20:10.928   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:20:12.254   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:12.254   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:20:12.254   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 历史
06-03 08:20:12.254   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：点击视频进行历史记录观看
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 点击的是历史视频，索引: 0
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频列表已重排序，目标视频"解说老勤"现在位于第一位
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 优先为点击的历史视频获取播放链接: BV1KfV6zGE7p
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1KfV6zGE7p 已有播放链接，跳过预加载
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 开始预加载其他历史视频的播放链接...
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🧠 开始预加载4个历史视频的播放链接
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1xwjXzSEXh 已有播放链接，跳过预加载
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV14XVbz2ECh 已有播放链接，跳过预加载
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1UrjrzWEUF 已有播放链接，跳过预加载
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 最终验证第一个视频播放链接: http://10.23.55.31:11111/api/video/download/BV1KfV6zGE7p.mp4
06-03 08:20:12.269   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 跳转到视频播放页面，第一个视频: BV1KfV6zGE7p
06-03 08:20:12.271   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 1 预加载完成
06-03 08:20:12.271   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1kJjoz9En1 已有播放链接，跳过预加载
06-03 08:20:12.271   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 2 预加载完成
06-03 08:20:12.271   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 历史视频预加载完成，共处理4个视频
06-03 08:20:12.282   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:20:21.382   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:20:23.105   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:23.105   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:20:23.105   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 历史
06-03 08:20:23.105   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：点击视频进行历史记录观看
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 点击的是历史视频，索引: 0
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频列表已重排序，目标视频"解说老勤"现在位于第一位
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 优先为点击的历史视频获取播放链接: BV1KfV6zGE7p
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1KfV6zGE7p 已有播放链接，跳过预加载
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 开始预加载其他历史视频的播放链接...
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🧠 开始预加载4个历史视频的播放链接
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1xwjXzSEXh 已有播放链接，跳过预加载
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV14XVbz2ECh 已有播放链接，跳过预加载
06-03 08:20:23.128   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1UrjrzWEUF 已有播放链接，跳过预加载
06-03 08:20:23.129   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 最终验证第一个视频播放链接: http://10.23.55.31:11111/api/video/download/BV1KfV6zGE7p.mp4
06-03 08:20:23.129   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 跳转到视频播放页面，第一个视频: BV1KfV6zGE7p
06-03 08:20:23.135   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 1 预加载完成
06-03 08:20:23.135   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1kJjoz9En1 已有播放链接，跳过预加载
06-03 08:20:23.135   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 2 预加载完成
06-03 08:20:23.135   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 历史视频预加载完成，共处理4个视频
06-03 08:20:23.140   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:20:26.258   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:20:35.070   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 切换到实时模式
06-03 08:20:35.988   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:35.988   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:20:35.988   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 实时
06-03 08:20:35.988   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 实时模式：使用推荐视频列表
06-03 08:20:35.988   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频列表已重排序，目标视频"解说老勤"现在位于第一位
06-03 08:20:36.001   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 播放模式: realtime
06-03 08:20:36.003   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:20:36.063   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     processVideoComplete开始执行
06-03 08:20:36.063   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     输入参数 - url: https://www.bilibili.com/video/BV1KfV6zGE7p
06-03 08:20:36.063   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     第一步：开始解析视频信息...
06-03 08:20:36.264   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频解析结果: 成功
06-03 08:20:36.264   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     第二步：开始处理视频...
06-03 08:20:36.264   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     processVideo开始执行
06-03 08:20:36.264   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     获取token...
06-03 08:20:36.266   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     token获取成功
06-03 08:20:36.267   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     开始处理视频: https://www.bilibili.com/video/BV1KfV6zGE7p
06-03 08:20:36.267   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     调用apiService.processVideo...
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频处理成功: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     processVideo执行完成
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频处理结果: 成功
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     第三步：开始生成下载链接...
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     文件名: BV1KfV6zGE7p.mp4
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     generateDownloadLink开始执行
06-03 08:20:36.399   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     获取token...
06-03 08:20:36.400   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     token获取成功
06-03 08:20:36.400   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     生成下载链接: BV1KfV6zGE7p.mp4
06-03 08:20:36.400   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     调用apiService.generateDownloadLink...
06-03 08:20:36.414   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     下载链接生成成功
06-03 08:20:36.414   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     generateDownloadLink执行完成
06-03 08:20:36.414   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     下载链接生成结果: 成功
06-03 08:20:39.117   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     HTTP Error: 403, Message: {"code":403,"message":"无权限下载该文件","data":null}
06-03 08:20:39.117   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     Request failed for http://10.23.55.31:11111/api/video/generate-download-link. Error: 网络请求失败，错误码: 403
06-03 08:20:39.117   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     预加载视频BV1dW7wzxEvd时出错: Error: 网络请求失败，错误码: 403
06-03 08:20:39.119   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     HTTP Error: 403, Message: {"code":403,"message":"无权限下载该文件","data":null}
06-03 08:20:39.119   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     Request failed for http://10.23.55.31:11111/api/video/generate-download-link. Error: 网络请求失败，错误码: 403
06-03 08:20:39.119   8774-8774     A03d00/JSAPP                    com.examp...i_player  E     预加载视频BV1gKjBzDEmC时出错: Error: 网络请求失败，错误码: 403
06-03 08:20:41.679   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:20:42.849   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔄 切换到历史模式
06-03 08:20:43.873   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:43.873   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:20:43.873   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 历史
06-03 08:20:43.873   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：点击视频进行历史记录观看
06-03 08:20:43.894   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 点击的是历史视频，索引: 0
06-03 08:20:43.895   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频列表已重排序，目标视频"解说老勤"现在位于第一位
06-03 08:20:43.895   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 优先为点击的历史视频获取播放链接: BV1KfV6zGE7p
06-03 08:20:43.895   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1KfV6zGE7p 已有播放链接，跳过预加载
06-03 08:20:43.895   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 开始预加载其他历史视频的播放链接...
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🧠 开始预加载4个历史视频的播放链接
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1xwjXzSEXh 已有播放链接，跳过预加载
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV14XVbz2ECh 已有播放链接，跳过预加载
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1UrjrzWEUF 已有播放链接，跳过预加载
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 最终验证第一个视频播放链接: http://10.23.55.31:11111/api/video/download/BV1KfV6zGE7p.mp4
06-03 08:20:43.896   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 跳转到视频播放页面，第一个视频: BV1KfV6zGE7p
06-03 08:20:43.900   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 1 预加载完成
06-03 08:20:43.900   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1kJjoz9En1 已有播放链接，跳过预加载
06-03 08:20:43.900   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 2 预加载完成
06-03 08:20:43.900   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 历史视频预加载完成，共处理4个视频
06-03 08:20:43.907   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:20:56.099   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:20:57.057   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频名称: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:20:57.057   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     BVID: BV1KfV6zGE7p
06-03 08:20:57.057   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     当前模式: 历史
06-03 08:20:57.058   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 历史模式：点击视频进行历史记录观看
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 点击的是历史视频，索引: 0
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     视频列表已重排序，目标视频"解说老勤"现在位于第一位
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎯 优先为点击的历史视频获取播放链接: BV1KfV6zGE7p
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1KfV6zGE7p 已有播放链接，跳过预加载
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 开始预加载其他历史视频的播放链接...
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🧠 开始预加载4个历史视频的播放链接
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1xwjXzSEXh 已有播放链接，跳过预加载
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV14XVbz2ECh 已有播放链接，跳过预加载
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1UrjrzWEUF 已有播放链接，跳过预加载
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🔍 最终验证第一个视频播放链接: http://10.23.55.31:11111/api/video/download/BV1KfV6zGE7p.mp4
06-03 08:20:57.079   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🚀 跳转到视频播放页面，第一个视频: BV1KfV6zGE7p
06-03 08:20:57.083   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 1 预加载完成
06-03 08:20:57.083   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ⚡ 视频 BV1kJjoz9En1 已有播放链接，跳过预加载
06-03 08:20:57.083   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📦 批次 2 预加载完成
06-03 08:20:57.083   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎉 历史视频预加载完成，共处理4个视频
06-03 08:20:57.093   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:21:02.259   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     remove listener
06-03 08:21:03.869   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     ✅ 成功获取用户token
06-03 08:21:03.883   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     add listener
06-03 08:21:03.885   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     📍 触底加载更多
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 以闪地形编辑古风仙侠家园«流霞醉月»
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 小八闯红灯
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 白嫖露娜新皮肤！宿命连消第3关最强攻略来了！
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 新王驾到！性价比的神！4499！9060XT+5600X+32G+1TB+B550M！
06-03 08:21:03.891   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 国产游戏居然删除中文来恶心国内玩家!!!
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 巅峰赛七年变迁：英雄战力屡创新高，2800选手却为何绝迹？
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 以闪地形编辑古风仙侠家园«流霞醉月»
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 小八闯红灯
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 白嫖露娜新皮肤！宿命连消第3关最强攻略来了！
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 新王驾到！性价比的神！4499！9060XT+5600X+32G+1TB+B550M！
06-03 08:21:05.481   8774-8774     A03d00/JSAPP                    com.examp...i_player  I     🎬 预加载视频: 国产游戏居然删除中文来恶心国内玩家!!!