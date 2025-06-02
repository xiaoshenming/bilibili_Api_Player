import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { apiService } from '../api/ApiService';
import { tokenManager } from '../utils/TokenManager';
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';



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
// 定义用户视频信息接口
interface UserVideoInfo {
  id: number;
  bvid: string;
  title: string;
  pic: string;
  duration: number;
  view: number;
  danmaku: number;
  like: number;
  coin: number;
  share: number;
  favorite: number;
  reply: number;
  owner_name: string;
  owner_face: string;
  pubdate: number;
  tname: string;
  download_link: string;
  file_size?: number;
  current_viewers?: number;
}

// 定义API响应接口
interface UserVideoListResponse {
  videos: Array<UserVideoInfo>;
  total: number;
  page: number;
  has_more: boolean;
}

@Component
export struct Dynamic {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  private cachedVideos: Array<VideoData> = []; // 缓存的视频数据
  private preloadedVideos: Set<string> = new Set(); // 已预加载的视频BVID
  @State index: number = 0;
  @State currentPage: number = 1;
  @State isLoading: boolean = false;
  @State hasMore: boolean = true;
  @State userToken: string = '';
  @State totalVideos: number = 0;
  @State selectedVideoIndex: number = -1; // 当前选中的视频索引
  @State bottomTabIndex: number = 1;
  @State errorMessage: string = '';
  @State isRefreshing: boolean = false;
  @State loadingMore: boolean = false; // 是否正在加载更多
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
      await this.loadUserVideos();
    }, 100);
  }

  // 加载用户Token
  async loadUserToken() {
    try {
      // 优先检查AppStorage中是否有已验证的token
      const verifiedToken = AppStorage.get('verifiedToken') as string;
      const tokenVerified = AppStorage.get('tokenVerified') as boolean;
      
      if (verifiedToken && tokenVerified) {
        console.log('🎯 发现已验证的token，直接使用');
        this.userToken = verifiedToken;
        return;
      }
      
      // 从本地存储获取token
      const context = this.getUIAbilityContext();
      if (context) {
        const token = await tokenManager.getToken(context);
        if (token) {
          this.userToken = token;
          console.log('✅ 成功获取用户token');
        } else {
          console.warn('⚠️ 没有找到用户token');
          this.errorMessage = '请先登录账号';
        }
      }
    } catch (error) {
      console.error('❌ 获取用户token失败:', error);
      this.errorMessage = '获取用户信息失败';
    }
  }

  // 加载用户视频列表
  async loadUserVideos(isLoadMore: boolean = false) {
    if (this.isLoading || (!this.hasMore && isLoadMore)) {
      return;
    }

    if (!this.userToken) {
      this.errorMessage = '请先登录账号';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 调用后端API获取用户视频列表
      const response = await this.getUserVideosFromAPI(this.currentPage, 20);
      
      if (response && response.videos) {
        const newVideos = this.convertToVideoData(response.videos);
        
        if (isLoadMore) {
          // 加载更多时追加到现有数据
          newVideos.forEach(video => {
            this.datas.pushData(video);
            this.cachedVideos.push(video);
          });
        } else {
          // 首次加载或刷新时替换数据
          this.datas.clearData();
          this.cachedVideos = [];
          newVideos.forEach(video => {
            this.datas.pushData(video);
            this.cachedVideos.push(video);
          });
        }
        
        this.totalVideos = response.total;
        this.hasMore = response.has_more;
        this.currentPage = response.page + 1;
        
        // 预加载前后5个视频
        this.preloadNearbyVideos();
      }
    } catch (error) {
      console.error('❌ 加载用户视频失败:', error);
      this.errorMessage = '加载视频列表失败，请重试';
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  // 获取用户视频数据的API调用
  private async getUserVideosFromAPI(page: number, pageSize: number = 20): Promise<UserVideoListResponse> {
    try {
      // 调用真实的API获取用户视频列表
      const videos = await apiService.getUserVideos(this.userToken);
      
      // 转换API响应为UserVideoListResponse格式
      const response: UserVideoListResponse = {
        videos: videos.map((item): UserVideoInfo => ({
          id: item.id,
          bvid: item.bvid,
          title: item.title,
          pic: item.pic,
          duration: parseInt(item.duration) || 0,
          view: parseInt(item.view) || 0,
          danmaku: parseInt(item.danmaku) || 0,
          like: parseInt(item.like) || 0,
          coin: parseInt(item.coin) || 0,
          share: parseInt(item.share) || 0,
          favorite: parseInt(item.favorite) || 0,
          reply: parseInt(item.reply) || 0,
          owner_name: item.name,
          owner_face: item.face,
          pubdate: parseInt(item.pubdate) || 0,
          tname: item.tname,
          download_link: item.download_link,
          current_viewers: parseInt(item.current_viewers) || 0
        })),
        total: videos.length,
        page: page,
        has_more: false // 目前API返回所有数据，没有分页
      };
      
      return response;
    } catch (error) {
      console.error('获取用户视频列表失败:', error);
      // 如果API调用失败，返回空数据
      return {
        videos: [],
        total: 0,
        page: page,
        has_more: false
      };
    }
  }

  // 转换API数据为VideoData格式
  private convertToVideoData(videos: Array<UserVideoInfo>): Array<VideoData> {
    return videos.map((item, index) => {
      const videoData: VideoData = {
        description: item.title,
        head: item.pic,
        video: item.download_link,
        bvid: item.bvid,
        name: item.owner_name,
        face: item.owner_face,
        view: item.view,
        like: item.like,
        barrage: item.danmaku,
        time: item.duration,
        pubdate: item.pubdate,
        coins: String(item.coin),
        favorites: String(item.favorite),
        shares: String(item.share),
        controller: this.myController,
        auto: true,
        play: false,
        index: String(this.cachedVideos.length + index)
      };
      return videoData;
    });
  }

  // 预加载前后5个视频
  private preloadNearbyVideos() {
    const currentIndex = this.selectedVideoIndex >= 0 ? this.selectedVideoIndex : 0;
    const startIndex = Math.max(0, currentIndex - 5);
    const endIndex = Math.min(this.cachedVideos.length - 1, currentIndex + 5);
    
    for (let i = startIndex; i <= endIndex; i++) {
      const video = this.cachedVideos[i];
      if (video && !this.preloadedVideos.has(video.bvid)) {
        this.preloadVideo(video);
        this.preloadedVideos.add(video.bvid);
      }
    }
  }

  // 预加载单个视频
  private preloadVideo(video: VideoData) {
    // 这里可以实现视频预加载逻辑
    // 例如预加载视频的第一帧或者缓存视频元数据
    console.log(`🎬 预加载视频: ${video.description}`);
  }

  // 视频点击处理 - 将选中视频移到第一位
  private onVideoClick(clickedVideo: VideoData, clickedIndex: number) {
    console.log(`🎯 点击视频: ${clickedVideo.description}`);
    
    // 更新选中的视频索引
    this.selectedVideoIndex = 0;
    
    // 重新排序：将点击的视频移到第一位
    const reorderedVideos = this.reorderVideos(clickedIndex);
    
    // 预加载周围的视频
    this.preloadNearbyVideos();
    
    // 跳转到视频播放页面
    router.pushUrl({ 
      url: "pages/VideoPlayer", 
      params: { 
        videoDatas: reorderedVideos,
        bvidflag: clickedVideo.bvid,
        startIndex: 0 // 从第一个开始播放
      } 
    });
  }

  // 重新排序视频列表
  private reorderVideos(clickedIndex: number): Array<VideoData> {
    const allVideos = this.datas.getAllData();
    const clickedVideo = allVideos[clickedIndex];
    const otherVideos = allVideos.filter((_, index) => index !== clickedIndex);
    
    // 将点击的视频放在第一位，其他视频保持原有顺序
    const reorderedVideos = [clickedVideo, ...otherVideos];
    
    // 更新数据源
    this.datas.clearData();
    this.cachedVideos = [];
    reorderedVideos.forEach(video => {
      this.datas.pushData(video);
      this.cachedVideos.push(video);
    });
    
    return reorderedVideos;
  }

  // 刷新视频列表
  private async refreshVideoList() {
    this.isRefreshing = true;
    this.currentPage = 1;
    this.hasMore = true;
    this.preloadedVideos.clear();
    await this.loadUserVideos(false);
  }

  // 格式化数字显示
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

  // 列表到底部时触发
  private async onReachEnd() {
    console.log('📍 触底加载更多');
    await this.loadUserVideos(true);
  }

  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }

  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Column() {
      // 顶部状态栏
      Row() {
        Text('我的视频')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        if (this.isLoading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#1296db')
        }
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')
      .border({ width: { bottom: 1 }, color: '#f0f0f0' })

      // 错误提示
      if (this.errorMessage) {
        Row() {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#ff4444')
          
          Blank()
          
          Button('重试')
            .fontSize(12)
            .backgroundColor('#1296db')
            .fontColor('#ffffff')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .onClick(() => {
              this.errorMessage = '';
              this.refreshVideoList();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#fff5f5')
      }

      // 视频统计信息
      if (this.totalVideos > 0) {
        Row() {
          Text(`共 ${this.totalVideos} 个视频`)
            .fontSize(12)
            .fontColor('#666666')
          
          Blank()
          
          if (this.selectedVideoIndex >= 0) {
            Text(`当前选中: 第 ${this.selectedVideoIndex + 1} 个`)
              .fontSize(12)
              .fontColor('#1296db')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#f8f9fa')
      }

      // 主要内容区域
      if (this.datas.totalCount() === 0 && !this.isLoading) {
        Column() {
          Text('📹')
             .fontSize(60)
             .opacity(0.5)
             .margin({ bottom: 16 })
          
          Text('暂无视频')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          
          Text('下拉刷新试试看')
            .fontSize(14)
            .fontColor('#cccccc')
          
          Button('刷新')
            .fontSize(14)
            .backgroundColor('#1296db')
            .fontColor('#ffffff')
            .margin({ top: 20 })
            .onClick(() => this.refreshVideoList())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 视频列表
        Refresh({ refreshing: this.isRefreshing }) {
          List({ space: 12 }) {
            LazyForEach(this.datas, (item: VideoData, index: number) => {
              ListItem() {
                Row() {
                  // 视频封面
                  Stack() {
                    Image(item.head || '')
                      .width(140)
                      .height(90)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                    
                    // 时长标签
                    if (item.time && Number(item.time) > 0) {
                       Text(this.formatDuration(Number(item.time)))
                        .fontSize(10)
                        .fontColor('#ffffff')
                        .backgroundColor('rgba(0, 0, 0, 0.7)')
                        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .position({ x: '100%', y: '100%' })
                        .translate({ x: -6, y: -6 })
                    }
                    
                    // 选中标识
                     if (this.selectedVideoIndex === index) {
                       Row() {
                         Text('✓')
                           .fontSize(12)
                           .fontColor('#1296db')
                           .fontWeight(FontWeight.Bold)
                       }
                       .width(24)
                       .height(24)
                       .backgroundColor('#ffffff')
                       .borderRadius(12)
                       .justifyContent(FlexAlign.Center)
                       .position({ x: 6, y: 6 })
                     }
                  }
                  .margin({ right: 12 })

                  // 视频信息
                  Column() {
                    // 标题
                    Text(item.description || '无标题')
                      .fontSize(15)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .lineHeight(20)
                      .margin({ bottom: 6 })

                    // UP主信息
                    Row() {
                      Image(item.face || '')
                        .width(16)
                        .height(16)
                        .borderRadius(8)
                        .margin({ right: 6 })
                      
                      Text(item.name || '未知UP主')
                        .fontSize(12)
                        .fontColor('#666666')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .margin({ bottom: 6 })

                    // 统计信息
                    Row() {
                      // 播放量
                       Row() {
                         Text('▶')
                           .fontSize(10)
                           .fontColor('#999999')
                           .margin({ right: 4 })
                         Text(this.formatNumber(Number(item.view) || 0))
                           .fontSize(11)
                           .fontColor('#999999')
                       }
                      .margin({ right: 12 })
                      
                      // 弹幕数
                       Row() {
                         Text('💬')
                           .fontSize(10)
                           .fontColor('#999999')
                           .margin({ right: 4 })
                         Text(this.formatNumber(Number(item.barrage) || 0))
                           .fontSize(11)
                           .fontColor('#999999')
                       }
                      .margin({ right: 12 })
                      
                      // 点赞数
                       Row() {
                         Text('👍')
                           .fontSize(10)
                           .fontColor('#999999')
                           .margin({ right: 4 })
                         Text(this.formatNumber(Number(item.like) || 0))
                           .fontSize(11)
                           .fontColor('#999999')
                       }
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .height(90)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#ffffff')
                .borderRadius(12)
                .shadow({ radius: 2, color: 'rgba(0, 0, 0, 0.1)', offsetY: 1 })
                .onClick(() => this.onVideoClick(item, index))
                .gesture(
                  LongPressGesture({ repeat: false })
                    .onAction(() => {
                      // 长按可以添加更多操作，如收藏、分享等
                      console.log(`长按视频: ${item.description}`);
                    })
                )
              }
              .transition({ type: TransitionType.All, opacity: 0, translate: { y: 20 } })
            }, (item: VideoData) => item.bvid)
            
            // 加载更多指示器
            if (this.hasMore && this.datas.totalCount() > 0) {
              ListItem() {
                Row() {
                  if (this.loadingMore) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color('#1296db')
                      .margin({ right: 8 })
                    Text('加载中...')
                      .fontSize(14)
                      .fontColor('#666666')
                  } else {
                    Text('上拉加载更多')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.Center)
              }
            } else if (!this.hasMore && this.datas.totalCount() > 0) {
              ListItem() {
                Text('已加载全部视频')
                  .fontSize(14)
                  .fontColor('#cccccc')
                  .width('100%')
                  .height(50)
                  .textAlign(TextAlign.Center)
              }
            }
          }
          .width('100%')
          .height('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onReachEnd(() => this.onReachEnd())
          .cachedCount(10)
          .lanes(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
        }
        .onRefreshing(() => this.refreshVideoList())
        .backgroundColor('#f5f5f5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
