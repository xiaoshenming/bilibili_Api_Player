import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';
import { apiService } from '../api/ApiService';
import { preferences } from '@kit.ArkData';
import { tokenManager } from '../utils/TokenManager';
import { common } from '@kit.AbilityKit';

// 定义视频信息接口
interface VideoInfo {
  bvid: string;
  name: string;
  description: string;
  pic: string;
  view: number;
  danmaku: number;
  duration: number;
  tname: string;
}

// 定义B站鉴权信息接口
interface BilibiliAuthInfo {
  nickname: string;
  avatar: string;
  dedeuserid: string;
}

// 定义用户信息接口
interface UserInfo {
  name?: string;
  email?: string;
}

// 定义视频所有者接口
interface VideoOwner {
  name: string;
  face: string;
  mid: number;
}

// 定义视频统计接口
interface VideoStat {
  view: number;
  danmaku: number;
  reply: number;
  favorite: number;
  coin: number;
  share: number;
  like: number;
}

// 定义视频项接口
interface BilibiliVideo {
  bvid: string;
  aid: number;
  cid: number;
  title: string;
  pic: string;
  desc: string;
  duration: number;
  pubdate: number;
  owner: VideoOwner;
  stat: VideoStat;
  tname: string;
}

// 定义API响应接口
interface BilibiliRecommendResponse {
  videos: Array<BilibiliVideo>;
  has_more: boolean;
}



/*
 *
 * 1. top: { anchor: "row3", align: VerticalAlign.Bottom }
anchor: "row3"：这个参数指明了当前组件的上边缘将与名为 row3 的组件对齐。
align: VerticalAlign.Bottom：当前组件的上边缘将对齐到 row3 的底部。也就是说，当前组件的顶部将位于 row3 的底部位置。
2. bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
anchor: "__container__"：这里使用了 __container__ 作为锚点，表示当前组件的底部将与其父容器的底部对齐。
align: VerticalAlign.Bottom：当前组件的底部将对齐到容器的底部边缘。
3. left: { anchor: "__container__", align: HorizontalAlign.Start }
anchor: "__container__"：当前组件的左边缘将与父容器的左边缘对齐。
align: HorizontalAlign.Start：这表示当前组件的左边缘将对齐到容器的左侧开始位置。
4. right: { anchor: "row1", align: HorizontalAlign.End }
anchor: "row1"：当前组件的右边缘将与名为 row1 的组件对齐。
align: HorizontalAlign.End：这表示当前组件的右边缘将对齐到 row1 的右边缘。
* */
@Entry
@Component
export struct Home {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State index: number = 0;
  @State apiResponse: object = []; // 存储原始 API 响应
  @State loadingMore: boolean = false; // 用于指示是否正在加载更多数据
  @State bottomTabIndex: number = 1;
  @State message: string = 'Hello World';
  @State videoList: Array<VideoInfo> = [];
  @State isLoading: boolean = false;
  @State currentPage: number = 1;
  @State hasMore: boolean = true;
  @State bilibiliAuthInfo: BilibiliAuthInfo | null = null;
  @State userToken: string = '';

  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  private getUIAbilityContext(): common.UIAbilityContext {
    return AppStorage.get('uiAbilityContext') as common.UIAbilityContext;
  }

  async aboutToAppear() {
    // 延迟执行，确保UIAbilityContext已经设置完成
    setTimeout(async () => {
      await this.loadUserToken();
    }, 100);
  }

  async loadUserToken() {
    // 🔥 优先检查AppStorage中是否有已验证的token
    const verifiedToken = AppStorage.get('verifiedToken') as string;
    const tokenVerified = AppStorage.get('tokenVerified') as boolean;
    const userInfo = AppStorage.get('userInfo') as UserInfo;
    
    if (verifiedToken && tokenVerified) {
      console.log('🎯 发现已验证的token，直接使用');
      this.userToken = verifiedToken;
      console.log('✅ 使用已验证的token:', verifiedToken.substring(0, 10) + '...');
      
      if (userInfo) {
        console.log('📋 用户信息:', userInfo.name, userInfo.email);
      }
      
      // 直接尝试加载哔哩哔哩鉴权信息和推荐视频
      try {
        await this.loadBilibiliAuthInfo();
        console.log('🎉 鉴权信息加载成功，尝试加载推荐视频');
        await this.loadRecommendVideos();
      } catch (authError) {
        console.warn('⚠️ 鉴权信息加载失败，但token有效，直接尝试加载推荐视频:', authError);
        await this.loadRecommendVideos();
      }
      return;
    }
    
    // 如果AppStorage中没有已验证的token，则使用原有逻辑
    console.log('🔍 AppStorage中没有已验证token，尝试从本地存储获取');
    
    let retryCount = 0;
    const maxRetries = 5;
    
    while (retryCount < maxRetries) {
      try {
        const context = this.getUIAbilityContext();
        if (!context) {
          console.warn(`第${retryCount + 1}次尝试：无法获取UIAbilityContext，等待重试...`);
          retryCount++;
          if (retryCount < maxRetries) {
            await new Promise<void>(resolve => setTimeout(resolve, 200 * retryCount)); // 递增延迟
            continue;
          } else {
            console.error('多次尝试后仍无法获取UIAbilityContext，使用备用方式加载数据');
            await this.loadData();
            return;
          }
        }
        
        console.log('成功获取UIAbilityContext，开始获取token');
        const token = await tokenManager.getToken(context);
        if (token) {
          this.userToken = token;
          console.log('✅ 成功获取用户token:', token.substring(0, 10) + '...');
          
          // 先尝试加载哔哩哔哩鉴权信息
          try {
            await this.loadBilibiliAuthInfo();
            console.log('🎉 鉴权信息加载成功，尝试加载推荐视频');
            await this.loadRecommendVideos();
          } catch (authError) {
            console.warn('⚠️ 鉴权信息加载失败，但token有效，直接尝试加载推荐视频:', authError);
            await this.loadRecommendVideos();
          }
        } else {
          console.log('⚠️ 没有找到用户token，使用备用方式加载数据');
          await this.loadData();
        }
        break; // 成功执行，跳出循环
      } catch (error) {
        console.error(`第${retryCount + 1}次获取用户token失败:`, error);
        retryCount++;
        if (retryCount >= maxRetries) {
          console.error('多次尝试后仍无法获取token，使用备用方式加载数据');
          await this.loadData();
        } else {
          await new Promise<void>(resolve => setTimeout(resolve, 200 * retryCount));
        }
      }
    }
  }

  async loadBilibiliAuthInfo(): Promise<void> {
    try {
      if (!this.userToken) {
        console.warn('⚠️ 用户token为空，无法获取哔哩哔哩鉴权信息');
        return;
      }

      console.log('🔄 开始获取哔哩哔哩鉴权信息...');
      const authInfo = await apiService.getBilibiliAuthInfo(this.userToken);
      
      console.log('📥 API返回的鉴权信息:', {
        nickname: authInfo?.nickname,
        dedeuserid: authInfo?.dedeuserid,
        avatar: authInfo?.avatar ? '有头像' : '无头像',
        hasCookies: !!authInfo?.cookies,
        hasSessdata: !!authInfo?.cookies?.SESSDATA,
        sessdataLength: authInfo?.cookies?.SESSDATA?.length || 0
      });
      
      // 验证返回的数据完整性
      if (authInfo && authInfo.cookies && authInfo.cookies.SESSDATA) {
        this.bilibiliAuthInfo = {
          nickname: authInfo.nickname || '未知用户',
          avatar: authInfo.avatar || '',
          dedeuserid: authInfo.dedeuserid || ''
        };
        console.log('✅ 获取哔哩哔哩鉴权信息成功:', {
          nickname: authInfo.nickname,
          dedeuserid: authInfo.dedeuserid,
          hasValidSessdata: !!authInfo.cookies.SESSDATA,
          sessdataPreview: authInfo.cookies.SESSDATA.substring(0, 20) + '...'
        });
      } else {
        console.error('❌ 获取的鉴权信息不完整:', {
          hasAuthInfo: !!authInfo,
          hasCookies: !!authInfo?.cookies,
          hasSessdata: !!authInfo?.cookies?.SESSDATA,
          rawData: authInfo
        });
        throw new Error('鉴权信息格式错误或缺少SESSDATA');
      }
    } catch (error) {
      console.error('❌ 获取哔哩哔哩鉴权信息失败:', error);
      // 清空鉴权信息
      this.bilibiliAuthInfo = null;
      throw new Error(error instanceof Error ? error.message : String(error)); // 重新抛出错误，让调用方知道失败了
    }
  }

  async loadRecommendVideos(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }

    this.isLoading = true;
    try {
      const response: BilibiliRecommendResponse = await apiService.getBilibiliRecommendVideos(this.userToken, this.currentPage);
      
      if (response && response.videos) {
        const newVideos: VideoInfo[] = response.videos.map((item) => {
          const video: VideoInfo = {
            bvid: item.bvid,
            name: item.owner?.name || '未知UP主',
            description: item.title || '无标题',
            pic: item.pic || '',
            view: item.stat?.view || 0,
            danmaku: item.stat?.danmaku || 0,
            duration: item.duration || 0,
            tname: item.tname || '未知分类'
          };
          return video;
        });
        
        if (this.currentPage === 1) {
          this.videoList = newVideos;
        } else {
          this.videoList = this.videoList.concat(newVideos);
        }
        
        this.hasMore = response.has_more;
        this.currentPage++;
      }
    } catch (error) {
      console.error('加载推荐视频失败:', error);
      // 如果API调用失败，回退到原来的方式
      await this.loadData();
    } finally {
      this.isLoading = false;
    }
  }

  // 加载数据的公共方法
  private async loadData(): Promise<void> {
    try {
      let sessdata: string = '';
      let useBackupSessdata = false;
      // 如果正在加载token，等待一段时间
      if (!this.userToken) {
        const verifiedToken = AppStorage.get('verifiedToken') as string;
        if (verifiedToken) {
          this.userToken = verifiedToken;
        }
      }
      // 如果有用户token，尝试从API获取最新的SESSDATA
      if (this.userToken) {
        console.log('🔄 检测到用户token，尝试获取动态SESSDATA...');
        try {
          const authInfo = await apiService.getBilibiliAuthInfo(this.userToken);
          console.log('📋 获取鉴权信息成功:', {
            nickname: authInfo.nickname,
            dedeuserid: authInfo.dedeuserid,
            hasSessdata: !!authInfo.cookies?.SESSDATA
          });
          
          if (authInfo.cookies && authInfo.cookies.SESSDATA) {
            sessdata = authInfo.cookies.SESSDATA;
            console.log('✅ 成功获取动态SESSDATA');
          } else {
            console.warn('⚠️ API返回的鉴权信息中没有SESSDATA，使用备用方案');
            useBackupSessdata = true;
          }
        } catch (error) {
          console.error('❌ 获取动态SESSDATA失败，使用备用方案:', error);
          useBackupSessdata = true;
        }
      } else {
        console.log('⚠️ 没有token，使用备用SESSDATA');
        useBackupSessdata = true;
      }
      
      // 使用备用SESSDATA
      if (useBackupSessdata) {
        sessdata = '59a10793,1762276359,7f149*51CjBbahzoY1V9kQMXI0YfxO_OQE5JrLc-MQowZ4rizmyd6DSacH1NSjwQPSxNII6BYEISVlpWZ1N3TlRmU05BVUxlRXB4ZG5vSVpiNjZrNVFzNk43cDNjQWQ5Y0pqU3ltVXhmaHA1cEVMTlhNZXVsTVNNM21mWUVXLW5JckV1eEtPd0c3Rm1vMVJBIIEC';
        console.log('🔧 已设置备用SESSDATA');
      }
      
      console.log('🎯 当前使用的SESSDATA:', sessdata.substring(0, 20) + '...');
      const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

      if (response) {
        this.apiResponse = response; // 存储原始响应结果
        this.parseApiResponse(response as Record<string, Object>); // 解析响应并存储视频数据
      } else {
        console.error('请求失败');
      }
    } catch (error) {
      console.error('loadData方法执行失败:', error);
    }
  }

  private parseApiResponse(response: Record<string, Object>): void {
    console.info(JSON.stringify(response));
    const responseData = response as Record<string, Object>;
    const code = responseData.code as number;
    const data = responseData.data as Record<string, Object>;
    
    if (code === 0 && data && data.item) {
      const items: Object[] = data.item as Object[];

      for (let i = 0; i < items.length; i++) {
        const item = items[i] as Record<string, Object>;
        const owner = item.owner as Record<string, Object>;
        const stat = item.stat as Record<string, Object>;

        this.datas.pushData({
          description: item.title as string, // 标题
          head: item.pic as string, // 封面URL
          video: item.uri as string, // 视频链接
          audioUrl: '', // 音频链接
          bvid: item.bvid as string,//地址
          aid: String(item.aid || 0), // AV号
          cid: String(item.cid || 0), // CID
          name: owner.name as string, // UP主
          face: owner.face as string,
          view: stat.view as number, // 播放量
          total:'55555',
          like: stat.like as number,//点赞
          barrage: stat.danmaku as number, // 弹幕数
          time: item.duration as number, // 时长
          pubdate: item.pubdate as number,//发布时间
          coins: '55555',//投币
          favorites: '55555',//收藏
          shares: '55555',//转发
          reply: String(stat.reply || 0), // 评论数
          tname: (item.tname as string) || '', // 分区名称
          controller: this.myController,
          auto:true,
          play:true,
          index: String(i),
        });
      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  // 列表到底部时触发
  private async onReachEnd() {
    if (this.isLoading || !this.hasMore) {
      return; // 如果正在加载或没有更多数据，则不执行
    }
    
    if (this.userToken) {
      await this.loadRecommendVideos(); // 使用新API加载更多数据
    } else {
      this.loadingMore = true;
      await this.loadData(); // 使用原来的方式加载更多数据
      this.loadingMore = false;
    }
  }

  // 格式化数字显示（如播放量、弹幕数）
  private formatNumber(num: number): string {
    if (num >= 100000000) {
      return (num / 100000000).toFixed(1) + '亿';
    } else if (num >= 10000) {
      return (num / 10000).toFixed(1) + '万';
    } else {
      return num.toString();
    }
  }

  // 格式化时长显示
  private formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${secs.toString().padStart(2, '0')}`;
    }
  }

  onPageShow(): void {
    const currentData = this.datas.getData(this.index);
    if (currentData && currentData.controller) {
      if (currentData.controller && typeof currentData.controller.start === 'function') {
        currentData.controller.start();
      }
    }
  }

  onPageHide(): void {
    const currentData = this.datas.getData(this.index);
    if (currentData && currentData.controller) {
      if (currentData.controller && typeof currentData.controller.pause === 'function') {
        currentData.controller.pause();
      }
    }
  }

  // 重新排序视频列表，将指定索引的视频放在第一位
  private reorderVideosForPlayback(videos: VideoData[], targetIndex: number): VideoData[] {
    if (targetIndex < 0 || targetIndex >= videos.length) {
      return videos;
    }
    
    const reordered = [...videos];
    const targetVideo = reordered.splice(targetIndex, 1)[0];
    reordered.unshift(targetVideo);
    
    console.info(`视频列表已重排序，目标视频"${targetVideo.name}"现在位于第一位`);
    return reordered;
  }

  build() {
    Scroll() {
      Column() {
        // 顶部标题栏，包含用户信息
        Row() {
          Text("哔哩哔哩")
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .margin({ left: 16 })
          
          // 用户鉴权信息显示 - 移到右上角
          if (this.bilibiliAuthInfo) {
            Row() {
              Text(this.bilibiliAuthInfo.nickname)
                .fontSize(14)
                .fontColor(Color.White)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ right: 8 })
              
              if (this.bilibiliAuthInfo.avatar) {
                Image(this.bilibiliAuthInfo.avatar)
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .border({ width: 2, color: Color.White })
              }
            }
            .padding({ right: 16 })
            .alignItems(VerticalAlign.Center)
          } else if (this.userToken) {
            Row() {
              Text("登录中...")
                .fontSize(14)
                .fontColor('#FFFFFF')
                .margin({ right: 8 })
              
              Circle({ width: 32, height: 32 })
                .fill('#FFFFFF33')
                .margin({ right: 16 })
            }
          } else {
            Row() {
              Text("未登录")
                .fontSize(14)
                .fontColor('#FFFFFF')
                .margin({ right: 8 })
              
              Circle({ width: 32, height: 32 })
                .fill('#FFFFFF33')
                .margin({ right: 16 })
            }
          }
        }
        .width("100%")
        .height("10%")
        // .backgroundColor('#FB7299')
        .backgroundColor('#ff6699')
        .padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        Tabs({ barPosition: BarPosition.Start ,index: this.bottomTabIndex})
        {
          TabContent() {
          }.tabBar("直播");

          TabContent() {
            List({ space: 5 }) {
              
              LazyForEach(this.datas, (item: VideoData, index: number) => {
                ListItem() {
                  Column() {
                    // 图片容器
                    Stack() {
                      Image(item.head)
                        .width('100%')
                        .height(130)
                        .objectFit(ImageFit.Cover)
                        .borderRadius({ topLeft: 8, topRight: 8 })

                      // 底部信息栏：播放量弹幕在左，时长在右
                      Row() {
                        // 播放量和弹幕数在左侧
                        Row() {
                          if (Number(item.view) > 0) {
                            Text(`${this.formatNumber(Number(item.view))}播放`)
                              .fontSize(11)
                              .fontColor(Color.White)
                              .margin({ right: 8 })
                          }
                          if (Number(item.barrage) > 0) {
                            Text(`${this.formatNumber(Number(item.barrage))}弹幕`)
                              .fontSize(11)
                              .fontColor(Color.White)
                          }
                        }
                        .backgroundColor('rgba(0, 0, 0, 0.7)')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)
                        
                        Blank()
                        
                        // 时长在右侧
                        if (Number(item.time) > 0) {
                          Text(this.formatDuration(Number(item.time)))
                            .fontSize(11)
                            .fontColor(Color.White)
                            .backgroundColor('rgba(0, 0, 0, 0.7)')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .borderRadius(4)
                        }
                      }
                      .width('100%')
                      .padding({ left: 2, right: 2, bottom: 2 })
                      .position({ x: 0, y: '100%' })
                      .translate({ x: 0, y: -2 })
                      .markAnchor({ x: 0, y: '100%' })
                    }
                    .width('100%')
                    .height(130)
                    
                    // 视频信息区域
                    Column() {
                      // 视频标题
                      Text(item.description)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .lineHeight(20)
                        .width('100%')
                        .height(48)  // 固定高度：20px行高 × 2行 + 8px间距
                        .margin({ bottom: 8 })
                      
                      // 作者信息和分类标签
                      Row() {
                        Text(item.name)
                          .fontSize(12)
                          .fontColor('#666666')
                          .fontWeight(FontWeight.Normal)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                        
                        if (item.tname && item.tname !== '') {
                          Text(item.tname)
                            .fontSize(10)
                            .fontColor('#FB7299')
                            .backgroundColor('#FFF0F5')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .borderRadius(10)
                        }
                      }
                      .width('100%')
                    }
                    .padding({ left: 12, right: 12, top: 10, bottom: 12 })
                    .alignItems(HorizontalAlign.Start)
                    .backgroundColor(Color.White)
                    .borderRadius({ bottomLeft: 8, bottomRight: 8 })
                  }
                  .onClick(async () => {
                    //点击之后跳转到Videoplay并传递完整的视频列表
                    console.log(`视频名称: ${item.description}`);
                    console.log(`BVID: ${item.bvid}`);
                    
                    try {
                      // 获取当前所有视频数据
                      const allVideos = this.datas.getAllData();
                      
                      // 找到点击的视频在列表中的索引
                      const clickedIndex = allVideos.findIndex(video => video.bvid === item.bvid);
                      const startIndex = clickedIndex >= 0 ? clickedIndex : 0;
                      
                      // 重新排序视频列表，将点击的视频放在第一位
                      const reorderedVideos = this.reorderVideosForPlayback(allVideos, startIndex);
                      
                      // 跳转到视频播放页面，传递完整的视频列表
                      router.pushUrl({
                        url: "pages/VideoPlayer",
                        params: {
                          videoDatas: reorderedVideos,
                          bvidflag: item.bvid, // 保留bvidflag用于后台解析更高质量版本
                          startIndex: 0, // 从重排后的第一个开始播放
                          fromHome: true // 标识来自首页
                        }
                      });
                      
                    } catch (error) {
                      console.error('处理视频点击失败:', error);
                      // 如果处理失败，回退到原来的方式
                      router.pushUrl({ url: "pages/VideoPlayer", params: { bvidflag: item.bvid } });
                    }
                  })
                  .borderRadius(8)
                  .width('100%')
                  .backgroundColor(Color.White)
                  .shadow({ radius: 4, color: '#00000015', offsetX: 0, offsetY: 2 });
                }
                .margin({ bottom: 12 });
              });
            }
            .onReachEnd(() => {
              this.onReachEnd()
              console.log('触底')
            })
            .cachedCount(6)
            .lanes(2, 5)
            .width("100%")
            .edgeEffect(EdgeEffect.Spring)
            // .edgeEffect(EdgeEffect.None)//听说可以防止反弹二次触发
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            });

          }.tabBar("推荐")


          TabContent() {
          }.tabBar("热门");
          TabContent() {
          }.tabBar("动画");
          TabContent() {
          }.tabBar("影视");
          TabContent() {
          }.tabBar("新征程");
          TabContent() {
          }.tabBar("#");

        }
        .onChange((newIndex) => {
          console.log(`当前选择的Tab索引: ${newIndex}`);
          // 判断是否切换到"推荐"标签
          if (newIndex === 1) { // 假设"推荐"对应索引为1
            this.onReachEnd()
            console.log("切换到推荐标签，开始刷新数据");

          }
        })
        .padding({ left: 5, right: 5 })
        .vertical(false)
        .height("100%");
      }.width("100%");
    }
    .edgeEffect(EdgeEffect.Spring)
    .friction(0.6)
    .backgroundColor('#DCDCDC')
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%');
  }
}
