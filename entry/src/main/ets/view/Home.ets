import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';
import { apiService } from '../api/ApiService';
import { preferences } from '@kit.ArkData';

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

  async aboutToAppear() {
    await this.loadUserToken(); // 加载用户token
  }

  async loadUserToken() {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'user_data');
      const token = await dataPreferences.get('token', '') as string;
      if (token) {
        this.userToken = token;
        await this.loadBilibiliAuthInfo();
        await this.loadRecommendVideos();
      } else {
        // 如果没有token，使用原来的方式加载数据
        await this.loadData();
      }
    } catch (error) {
      console.error('获取用户token失败:', error);
      await this.loadData();
    }
  }

  async loadBilibiliAuthInfo(): Promise<void> {
    try {
      const authInfo = await apiService.getBilibiliAuthInfo(this.userToken);
      this.bilibiliAuthInfo = {
        nickname: authInfo.nickname,
        avatar: authInfo.avatar,
        dedeuserid: authInfo.dedeuserid
      };
      console.log('获取哔哩哔哩鉴权信息成功:', authInfo.nickname);
    } catch (error) {
      console.error('获取哔哩哔哩鉴权信息失败:', error);
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
    // const sessdata = '你的SESSDATA'; // 替换成实际的 SESSDATA
    const sessdata = 'ab9d6d14%2C1746252800%2C9f8a2%2Ab1CjDy9wFwCOPazj3xO5hhngHPdK3Iy0kaicJX2rOm6GhJYUynqJTtckHDkSZAPDFjGZoSVjdkVWUxN1VYZlBuYUp3a291eDdLOVl3VnRKV0l3UUJnZHNSRTY2T3ppWkphbkhLeU1fc05DYVZVb3Ywd1h2eTd6U1hkWnZZTlNCdXR1OUIybzM1clh3IIEC'; // 替换成实际的 SESSDATA
    const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response as Record<string, Object>); // 解析响应并存储视频数据
    } else {
      console.error('请求失败');
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
      currentData.controller.start();
    }
  }

  onPageHide(): void {
    const currentData = this.datas.getData(this.index);
    if (currentData && currentData.controller) {
      currentData.controller.pause();
    }
  }

  build() {
    Scroll() {
      Column() {
        Text("在线首页api获取")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center);
        Tabs({ barPosition: BarPosition.Start ,index: this.bottomTabIndex})
        {
          TabContent() {
          }.tabBar("直播");

          TabContent() {
            List({ space: 5 }) {
              // 用户信息区域
              if (this.bilibiliAuthInfo) {
                ListItem() {
                  Row() {
                    Image(this.bilibiliAuthInfo.avatar)
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .objectFit(ImageFit.Cover)
                      .margin({ right: 10 })
                    
                    Column() {
                      Text(`欢迎回来，${this.bilibiliAuthInfo.nickname}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      Text(`UID: ${this.bilibiliAuthInfo.dedeuserid}`)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 2 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ left: 15, right: 15, top: 10, bottom: 10 })
                  .backgroundColor('#f8f9fa')
                  .borderRadius(8)
                }
                .margin({ bottom: 10 })
              }
              
              LazyForEach(this.datas, (item: VideoData, index: number) => {
                ListItem() {
                  RelativeContainer() {
                    Image(item.head)
                      .width('100%')
                      .height(130)   // 设置固定高度
                      .aspectRatio(0)
                      .objectFit(ImageFit.Cover)
                      .alignRules({
                        top: { anchor: "__container__", align: VerticalAlign.Top },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      })
                      .id("home_image1")

                    Text(item.description)
                      .fontSize(14)
                      .padding({ top: 10, left: 10, bottom: 5 })
                      .fontWeight(FontWeight.Normal)
                      .letterSpacing(1)
                      .lineHeight(20)
                      .maxLines(2)  // 设置最多两行
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignRules({
                        top: { anchor: "image1", align: VerticalAlign.Bottom },
                        left: { anchor: "image1", align: HorizontalAlign.Start }
                      })
                      .id("title");

                    // 视频统计信息
                    Row() {
                      if (Number(item.view) > 0) {
                        Text(`${this.formatNumber(Number(item.view))}播放`)
                          .fontSize(10)
                          .fontColor('#999999')
                          .margin({ right: 8 })
                      }
                      if (Number(item.barrage) > 0) {
                        Text(`${this.formatNumber(Number(item.barrage))}弹幕`)
                          .fontSize(10)
                          .fontColor('#999999')
                          .margin({ right: 8 })
                      }
                      if (Number(item.time) > 0) {
                        Text(this.formatDuration(Number(item.time)))
                          .fontSize(10)
                          .fontColor('#999999')
                      }
                    }
                    .padding({ left: 10, top: 2 })
                    .alignRules({
                      top: { anchor: "title", align: VerticalAlign.Bottom },
                      left: { anchor: "__container__", align: HorizontalAlign.Start }
                    })
                    .id("stats")

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
                          .fontColor('#ff6b9d')
                          .backgroundColor('#fff0f5')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(10)
                          .margin({ left: 5 })
                      }
                    }
                    .padding({ left: 10, right: 10, bottom: 10 })
                    .alignRules({
                      bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                      left: { anchor: "__container__", align: HorizontalAlign.Start },
                      right: { anchor: "__container__", align: HorizontalAlign.End }
                    })
                  }
                  .onClick(() => {
                    //点击之后跳转到Videoplay并触发视频解析
                    console.log(`视频名称: ${item.description}`);
                    console.log(`BVID: ${item.bvid}`);
                    // 传递bvidflag参数来触发视频解析逻辑
                    router.pushUrl({ url: "pages/VideoPlayer", params: { bvidflag: item.bvid } });
                  })
                  .borderRadius(5)
                  .width('100%')
                  .height(240)
                  .backgroundColor('#ffffff')
                  .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 1 });
                }
                .borderRadius(5)
                .height(240)
                .margin({ bottom: 8 });
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
