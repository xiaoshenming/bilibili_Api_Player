import { CommonConstants as Const } from '../common/CommonConstants';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData, BilibiliVideoInfo } from '../Model/VideoData';
import { router, curves, promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { bilibiliService } from '../api/BilibiliService';
import { Side, VideoDes } from '../view/Side';
import { TopTabContent } from '../Model/DataModel';
import { common } from '@kit.AbilityKit';
import { tokenManager } from '../utils/TokenManager';
import { apiService } from '../api/ApiService';
import { UserVideoInfo } from '../view/Dynamic';
let videoIndex: number = 0;

@Entry
@Component
export struct VideoPlayer {
  private swiperController: SwiperController = new SwiperController();
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State playBoo: boolean = true;
  @State localonline: boolean = true;
  @State index: number = 0;
  @State totalindex: string = '111';
  @State currentIndex: number = 1;
  @State mp4: string = '';
  @State isLoading: boolean = false;
  @State fromParse: boolean = false; // 标识是否来自解析页面
  scroller: Scroller = new Scroller();
  private topTabListData: TopTabContent = new TopTabContent();
  private context = getContext(this) as common.UIAbilityContext;

  controller: webview.WebviewController = new webview.WebviewController();
  videoDatas: Array<VideoData> = [];

  async aboutToAppear() {
    try {
      console.info('VideoPlayer组件开始初始化');
      
      // 安全获取路由参数
      let params: Record<string, Object> = {};
      try {
        params = router.getParams() as Record<string, Object> || {};
        console.info('VideoPlayer params:', JSON.stringify(params));
      } catch (paramError) {
        console.error('获取路由参数失败:', paramError);
        params = {};
      }
      
      // 初始化视频数据源
      console.info('初始化视频数据源...');
      this.loadDefaultVideos();
      
      // 检查是否来自解析页面
      this.fromParse = Boolean(params["fromParse"]) || false;
      
      if (params["videoDatas"] && Array.isArray(params["videoDatas"]) && params["videoDatas"].length > 0) {
        // 如果来自解析页面，直接使用传入的数据
        if (this.fromParse) {
          try {
            const videoData = (params["videoDatas"] as VideoData[])[0];
            // 清空默认视频，使用传入的数据
            this.datas.clearData();
            this.datas.pushData(videoData);
            console.log('使用解析页面传入的视频数据');
          } catch (dataError) {
            console.error('处理传入视频数据失败:', dataError);
            // 如果处理失败，保持默认视频
          }
        } else {
          // 传统模式：需要重新解析视频
          await this.parseVideoFromParams(params);
        }
      } else if (params["bvidflag"] && typeof params["bvidflag"] === 'string') {
        // 如果有bvidflag参数，调用解析方法
        console.info('检测到bvidflag参数，开始处理视频');
        await this.parseVideoFromParams(params);
      }
      
      console.info('VideoPlayer组件初始化完成');
    } catch (error) {
      console.error('VideoPlayer组件初始化失败:', error);
      console.error('初始化错误详情:', JSON.stringify(error));
      // 确保即使出错也能显示默认视频
      this.loadDefaultVideos();
    }
  }

  // 从参数解析视频 - 使用新的API流程
  private async parseVideoFromParams(params: Record<string, Object>) {
    this.isLoading = true;
    
    try {
      const bvidflag = params["bvidflag"] as string;
      console.info('接收到bvidflag参数:', bvidflag);
      
      if (bvidflag) {
        const blibliurl = `https://www.bilibili.com/video/${bvidflag}`;
        console.info('开始处理视频:', blibliurl);
        
        // 检查context和token状态
        console.info('准备获取token...');
        if (!this.context) {
          console.error('应用上下文不存在，无法获取token');
          promptAction.showToast({ message: '应用初始化失败，仅可观看本地视频' });
          return;
        }
        
        let token: string | null = null;
        try {
          console.info('获取token中...');
          // 添加超时保护
          const tokenPromise = tokenManager.getToken(this.context);
          const timeoutPromise = new Promise<null>((_, reject) => {
            setTimeout(() => reject(new Error('获取token超时')), 5000);
          });
          
          token = await Promise.race([tokenPromise, timeoutPromise]);
          console.info('token获取完成，状态:', token ? '已登录' : '未登录');
        } catch (tokenError) {
          console.error('获取token时出错:', tokenError);
          console.error('token错误详情:', JSON.stringify(tokenError));
          promptAction.showToast({ message: '获取登录状态失败，本地视频仍可观看' });
          return;
        }
        
        if (!token) {
          console.error('用户未登录，无法处理视频');
          try {
            promptAction.showToast({ message: '请先登录后再解析在线视频，本地视频仍可观看' });
          } catch (toastError) {
            console.error('显示toast时出错:', toastError);
          }
          return;
        }
        
        console.info('开始调用新的视频处理流程...');
        console.info('调用参数 - context:', this.context ? '存在' : '不存在');
        console.info('调用参数 - url:', blibliurl);
        
        let result: BilibiliVideoInfo | null = null;
        try {
          console.info('准备调用processVideoComplete...');
          // 使用新的完整视频处理流程，添加超时保护
          const apiPromise = bilibiliService.processVideoComplete(this.context, blibliurl);
          const timeoutPromise = new Promise<null>((_, reject) => {
            setTimeout(() => reject(new Error('视频处理超时，请检查网络连接')), 900000); // 15分钟超时，适应ffmpeg较长的处理时间
          });
          
          console.info('开始等待API响应...');
          result = await Promise.race([apiPromise, timeoutPromise]);
          console.info('视频处理流程结果:', result ? '成功' : '失败');
          console.info('API调用完成，准备处理结果...');
        } catch (apiError) {
          console.error('调用视频处理流程时出错:', apiError);
          console.error('API错误详情:', JSON.stringify(apiError));
          
          // 根据错误类型显示不同的提示
          let errorMessage = '视频解析失败，但本地视频仍可观看';
          if (apiError.message.includes('超时')) {
            errorMessage = '视频解析超时，本地视频仍可观看。解析可能需要较长时间，请稍后重试';
          } else if (apiError.message.includes('401')) {
            errorMessage = '登录已过期，请重新登录。本地视频仍可观看';
          } else if (apiError.message.includes('网络')) {
            errorMessage = '网络连接失败，本地视频仍可观看。请检查网络设置后重试';
          }
          
          promptAction.showToast({ message: errorMessage });
          // 不再调用loadDefaultVideos()，因为已经在开始时加载了
          return;
        }
        
        if (result) {
          console.info('视频处理成功，信息:', {
            title: result.title,
            bvid: result.bvid,
            videoUrl: result.videoUrl ? '有视频链接' : '无视频链接'
          });
          
          try {
            const videoData: VideoData = {
              description: result.title || '未知标题',
              head: result.pic || $r('app.media.photo35'), // 使用默认封面
              video: result.videoUrl,
              audioUrl: result.audioUrl,
              bvid: result.bvid,
              aid: String(result.aid || '0'),
              cid: String(result.cid || '0'),
              name: result.name || '未知UP主',
              face: result.face || 'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
              view: String(result.view || '0'),
              like: String(result.like || '0'),
              barrage: String(result.danmaku || '0'),
              time: String(result.duration || '0'),
              pubdate: String(result.pubdate || '0'),
              coins: String(result.coin || '0'),
              favorites: String(result.favorite || '0'),
              shares: String(result.share || '0'),
              reply: String(result.reply || '0'),
              tname: result.tname || '未知分区',
              controller: this.myController,
              auto: false,
              play: false,
              index: '0',
              total: String(result.view || '0')
            };
            
            // 将解析成功的视频插入到列表开头，让用户优先看到解析的内容
            this.datas.addData(0, videoData);
            console.info('解析的视频已添加到列表开头，用户可以无缝切换');
            
            // 显示解析成功的提示
            promptAction.showToast({ message: '视频解析成功！' });
          } catch (dataError) {
            console.error('创建视频数据时出错:', dataError);
            console.error('数据错误详情:', JSON.stringify(dataError));
            promptAction.showToast({ message: '视频数据处理失败，但本地视频仍可观看' });
          }
        } else {
          console.error('视频处理失败：API返回空结果');
          promptAction.showToast({ message: '视频解析失败，但本地视频仍可观看' });
        }
      } else {
        console.error('未接收到有效的bvidflag参数');
        this.loadDefaultVideos();
      }
    } catch (error) {
      console.error('处理视频时出现未捕获的错误:', error);
      console.error('未捕获错误详情:', JSON.stringify(error));
      console.error('错误堆栈:', error.stack);
      this.loadDefaultVideos();
    } finally {
      this.isLoading = false;
      console.info('parseVideoFromParams方法执行完成');
    }
  }

  // 加载默认视频数据
  private loadDefaultVideos() {
    try {
      console.info('初始化视频数据源...');
      
      // 清空现有数据
      this.datas.clearData();
      
      console.info('视频数据源初始化完成');
    } catch (error) {
      console.error('初始化视频数据源失败:', error);
    }
  }

  // 处理视频滑动事件，实现动态预加载和鉴权
  private async handleVideoSwipe(currentIndex: number) {
    try {
      console.info(`用户滑动到第${currentIndex}个视频，开始处理视频切换`);
      
      // 获取当前视频总数
      const totalVideos = this.datas.totalCount();
      console.info(`当前视频总数: ${totalVideos}`);
      
      // 获取当前视频数据
      const currentVideo = this.datas.getData(currentIndex);
      if (currentVideo) {
        // 检查当前视频是否需要鉴权获取播放链接
        await this.ensureVideoPlayable(currentVideo, currentIndex);
      }
      
      // 预加载策略：当用户滑动到倒数第3个视频时，开始预加载更多视频
      if (currentIndex >= totalVideos - 3) {
        console.info('触发预加载条件，开始加载更多视频');
        await this.loadMoreVideosWithAuth();
      }
      
      // 更新当前观看人数（模拟实时数据）
      this.updateCurrentViewers(currentIndex);
      
    } catch (error) {
      console.error('处理视频滑动事件失败:', error);
    }
  }

  // 加载更多视频并进行鉴权预加载
  private async loadMoreVideosWithAuth() {
    try {
      if (this.isLoading) {
        console.info('正在加载中，跳过重复请求');
        return;
      }
      
      this.isLoading = true;
      console.info('开始加载更多视频...');
      
      // 检查登录状态
      if (!this.context) {
        console.error('应用上下文不存在');
        return;
      }
      
      const token = await tokenManager.getToken(this.context);
      if (!token) {
        console.error('用户未登录，无法加载更多在线视频');
        return;
      }
      
      // 调用API获取更多视频
      const moreVideos = await apiService.getUserVideos(token);
      
      if (moreVideos && moreVideos.length > 0) {
        console.info(`获取到${moreVideos.length}个新视频`);
        
        // 为视频数据添加缺失的属性以匹配UserVideoInfo接口
        const processedVideos: UserVideoInfo[] = moreVideos.map((video): UserVideoInfo => {
          return {
            id: video.id,
            bvid: video.bvid,
            title: video.title,
            pic: video.pic,
            duration: video.duration,
            view: video.view,
            danmaku: video.danmaku,
            like: video.like,
            coin: video.coin,
            share: video.share,
            favorite: video.favorite,
            reply: video.reply,
            owner_name: video.name,
            owner_face: video.face,
            pubdate: video.pubdate,
            tname: video.tname,
            download_link: video.download_link,
            current_viewers: video.current_viewers,
            quality: video.quality,
            aid: video.aid,
            desc: video.desc,
            name: video.name,
            face: video.face,
            cid: video.cid,
            relation_type: video.relation_type,
            relation_created_at: video.relation_created_at,
            relation_desc: video.relation_desc
          };
        });
        
        // 预加载前5个视频的播放链接
        const videosToPreload = processedVideos.slice(0, 5);
        await this.preloadVideoLinks(videosToPreload);
        
        // 将所有新视频添加到列表
        for (const videoInfo of processedVideos) {
          const videoData: VideoData = {
            description: videoInfo.title,
            head: videoInfo.pic || $r('app.media.photo35'),
            video: videoInfo.preloaded_url || videoInfo.download_link || '',
            audioUrl: videoInfo.preloaded_audio || '',
            bvid: videoInfo.bvid,
            aid: String(videoInfo.id),
            cid: '0',
            name: videoInfo.name,
            face: videoInfo.face || 'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
            view: String(videoInfo.view),
            like: String(videoInfo.like),
            barrage: String(videoInfo.danmaku),
            time: String(videoInfo.duration),
            pubdate: String(videoInfo.pubdate),
            coins: String(videoInfo.coin),
            favorites: String(videoInfo.favorite),
            shares: String(videoInfo.share),
            reply: String(videoInfo.reply),
            tname: videoInfo.tname,
            controller: this.myController,
            auto: false,
            play: false,
            index: this.datas.totalCount().toString(),
            total: String(videoInfo.current_viewers)
          };
          
          // 将预加载信息存储到videoData中，供后续使用
          videoData.preloaded_url = videoInfo.preloaded_url;
          videoData.preloaded_audio = videoInfo.preloaded_audio;
          
          this.datas.pushData(videoData);
        }
        
        console.info('新视频已添加到列表，预加载完成');
        
        // 确保第一个视频可以播放
        if (this.datas.totalCount() > 0) {
          const firstVideo = this.datas.getData(0);
          await this.ensureVideoPlayable(firstVideo, 0);
        }
      }
      
    } catch (error) {
      console.error('加载更多视频失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 预加载视频播放链接
  private async preloadVideoLinks(videos: UserVideoInfo[]) {
    try {
      console.info(`开始预加载${videos.length}个视频的播放链接`);
      
      const preloadPromises = videos.map(async (video: UserVideoInfo, index: number) => {
        try {
          if (video.bvid) {
            const videoUrl = `https://www.bilibili.com/video/${video.bvid}`;
            const token = await tokenManager.getToken(this.context!);
            if (!token) {
              console.error('用户未登录，无法预加载视频');
              return;
            }
            const result = await apiService.parseVideo(token, videoUrl);
            if (result && result.play_info) {
               console.info(`视频${index + 1}预加载成功: ${video.bvid}`);
               // 将预加载的链接存储起来，供后续使用
               video.preloaded_url = result.play_info?.video_url || '';
               video.preloaded_audio = result.play_info?.audio_url || '';
             }
          }
        } catch (error) {
          console.error(`预加载视频${index + 1}失败:`, error);
        }
      });
      
      // 并发预加载，但不等待全部完成
      Promise.allSettled(preloadPromises).then(() => {
        console.info('视频预加载批次完成');
      });
      
    } catch (error) {
      console.error('预加载视频链接失败:', error);
    }
  }

  // 确保视频可播放（动态鉴权）
  private async ensureVideoPlayable(video: VideoData, index: number) {
    try {
      console.info(`检查视频${index}(${video.bvid})的播放状态`);
      
      // 检查是否有预加载的链接
      if (video.preloaded_url && video.preloaded_url.startsWith('http')) {
        console.info(`使用预加载的播放链接: ${video.bvid}`);
        video.video = video.preloaded_url;
        if (video.preloaded_audio) {
          video.audioUrl = video.preloaded_audio;
        }
        // 更新数据源
        this.datas.updateDataAtIndex(index, video);
        return;
      }
      
      // 检查视频是否已经有有效的播放链接（不是download_link）
      if (video.video && typeof video.video === 'string' && video.video.startsWith('http') && 
          !video.video.includes('/api/video/download/') && 
          !video.video.includes('download_link')) {
        console.info(`视频${index}已有有效播放链接，无需重新获取`);
        return;
      }
      
      // 如果没有有效播放链接，动态获取
      if (video.bvid && this.context) {
        console.info(`开始为视频${video.bvid}获取播放链接`);
        
        const token = await tokenManager.getToken(this.context);
        if (!token) {
          console.error('用户未登录，无法获取播放链接');
          return;
        }
        
        const videoUrl = `https://www.bilibili.com/video/${video.bvid}`;
        const result = await apiService.parseVideo(token, videoUrl);
        
        if (result && result.play_info) {
          console.info(`成功获取视频${video.bvid}的播放链接`);
          video.video = result.play_info.video_url || '';
          video.audioUrl = result.play_info.audio_url || '';
          
          // 存储到预加载信息中
          video.preloaded_url = video.video as string;
          video.preloaded_audio = video.audioUrl;
          
          // 更新数据源中的视频数据
          this.datas.updateDataAtIndex(index, video);
          console.info(`视频${video.bvid}播放链接更新完成`);
        } else {
          console.error(`获取视频${video.bvid}播放链接失败`);
        }
      }
    } catch (error) {
      console.error(`确保视频${video.bvid}可播放时出错:`, error);
    }
  }
  
  // 更新当前观看人数
  private updateCurrentViewers(index: number) {
    try {
      const currentVideo = this.datas.getData(index);
      if (currentVideo && currentVideo.total) {
        this.totalindex = (parseInt(currentVideo.total) || 0).toString();
      }
    } catch (error) {
      console.error('更新观看人数失败:', error);
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
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(this.datas, (item: VideoData, index: number) => {
            Stack({ alignContent: Alignment.Center }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Stack({ alignContent: Alignment.BottomEnd }) {
                  Video({
                    src: item.video,
                    controller: item.controller, // 同样使用同一个控制器
                    previewUri: item.head,
                  })
                    .width(Const.FULL_SIZE)
                    .height(Const.FULL_SIZE)
                    .objectFit(ImageFit.Contain)
                    .loop(true)
                    .autoPlay(item.auto)// .controls(false)
                    .onPrepared((err) => {
                      if (item && item.controller) {
                        item.controller.start();
                      }
                    })
                    .onStart(() => {
                      item.play = true;
                      const currentData = this.datas.getData(this.index);
                      if (currentData) {
                        this.playBoo = currentData.play;
                      }
                    })
                    .onPause(() => {
                      item.play = false;
                      const currentData = this.datas.getData(this.index);
                      if (currentData) {
                        this.playBoo = currentData.play;
                      }
                    })
                    .onClick(() => {
                      if (item && item.controller) {
                        if (item.play) {
                          item.controller.pause();
                        } else {
                          item.controller.start();
                        }
                      }
                    })
                    .onVisibleAreaChange([0.0, 1.0], (isVisisble: boolean, currentRatio: number) => {
                      if (isVisisble && currentRatio >= 1.0 && item && item.controller) {
                        item.controller.start();
                        this.totalindex = String(item.total || '0');
                      }
                    })
                  Side({
                    likeCount: String(item.like), // 点赞数,独特特性（bug！）
                    commentCount: String(item.barrage), // 评论数 目前是弹幕
                    favoriteCount: String(item.favorites), // 收藏数
                    shareCount: String(item.shares), // 分享数
                    toubiCount: String(item.coins),

                    index: Number(item.index) // 索引
                  })
                }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))

                VideoDes({
                  head: item.face,
                  name: item.name,
                  description: item.description,
                  hotspot: String(item.pubdate),
                  time: String(item.time),
                  viewCount: String(item.view),
                })
                  .margin({ bottom: $r('app.integer.video_des_margin_bottom') })
                // Row() {
                //   Row() {
                //     Image($r('app.media.ic_public_upgrade_filled'))
                //       .height($r('app.integer.upgrade_icon_size'))
                //       .width($r('app.integer.upgrade_icon_size'))
                //     Text($r('app.string.upgrade_hot'))
                //       .fontSize($r('app.integer.upgrade_text_font_size'))
                //       .fontColor($r('app.color.up_color'))
                //     Text(' · ' + '2024年11月5日17点17分')
                //       .fontSize($r('app.integer.mus_font_size'))
                //       .maxLines(1)
                //       .width('2024年11月5日17点17分'.length * 12)
                //       .fontColor(Color.White)
                //       .height($r('app.integer.mus_height'))
                //       .textOverflow({ overflow: TextOverflow.Ellipsis })
                //       .layoutWeight(1)
                //   }
                //   .width(Const.ROW_WIDTH)
                //
                //   Row() {
                //     Divider()
                //       .vertical(true)
                //       .color(Color.White)
                //       .strokeWidth(1)
                //       .height($r('app.integer.upgrade_text_font_size'))
                //       .margin({ left: $r('app.integer.upgrade_margin'), right: $r('app.integer.upgrade_margin') })
                //     Text($r('app.string.online_people'))
                //       .fontSize($r('app.integer.mus_font_size'))
                //       .fontColor(Color.White)
                //     Image($r('app.media.ic_arrow_right'))
                //       .width($r('app.integer.upgrade_text_font_size'))
                //   }
                //   .layoutWeight(1)
                //   .justifyContent(FlexAlign.End)
                // }
                // .width(Const.FULL_SIZE)
                // .height($r('app.integer.upgrade_height'))
                // .backgroundColor(Color.Gray)
                // .opacity($r('app.float.fabulous_opacity'))
                // .padding({ left: $r('app.integer.upgrade_padding'), right: $r('app.integer.upgrade_padding') })
                // .justifyContent(FlexAlign.Start)


              }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding(0)

              if (!this.playBoo) {
                Image($r('app.media.pau'))
                  .height($r('app.integer.play_icon_size'))
                  .width($r('app.integer.play_icon_size'))
                  .onClick(() => {
                    if (item && item.controller) {
                      item.controller.start();
                      item.play = true;
                      this.playBoo = true;
                    }
                  })
              }
            }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))
          }, (item: VideoData) => JSON.stringify(item))
        }
        .width('100%')
        .height('100%')
        .vertical(true)
        .autoPlay(false)
        .indicator(false)
        .loop(true)
        // .duration(Const.DURATION)
        .cachedCount(0)
        .vertical(true)
        .itemSpace(0)
        .curve(curves.interpolatingSpring(-1, 1, 328, 34))
        .onChange(async (index) => {
          this.index = index;
          this.playBoo = true;
          videoIndex = index;
          
          // 动态预加载机制：当用户滑动到某个视频时，预加载后续视频
          // 使用异步处理，避免阻塞UI
          this.handleVideoSwipe(index).catch((error: Error) => {
            console.error('处理视频切换失败:', error);
          });
        })
      }
      .width('100%')
      .height('100%')


      Row() {

        RelativeContainer() {
          Image($r("app.media.chevron_left"))
            .width(25)
            .height(25)
            .onClick(() => {
              router.back();
            })
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              left: { anchor: "__container__", align: HorizontalAlign.Start }
            })
            .id("tuichu")

          Image($r("app.media.person_2"))
            .width(20)
            .height(25)
            .onClick(() => {
              router.back();
            })
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              left: { anchor: "tuichu", align: HorizontalAlign.End }
            })
            .id("person_2")

          Text(this.totalindex+'人正在看')
            .height(25)
            .fontSize($r('app.integer.fabulous_font_size'))
            .fontColor(Color.White)
            .opacity($r('app.float.fabulous_opacity'))
            .margin({left:10})
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              left: { anchor: "person_2", align: HorizontalAlign.End }
            })
            .id("text")
          // List({ scroller: this.scroller }) {
          //   LazyForEach(this.topTabListData, (item: string, index) => {
          //     ListItem() {
          //       Column() {
          //         Text(item)
          //           .fontColor(this.currentIndex === index ? Color.White : $r('app.color.font_color'))
          //           .fontSize($r('app.integer.tab_font_size'))
          //         Divider()
          //           .width(this.currentIndex === index ? $r('app.integer.tab_divider_width') : $r('app.integer.tab_divider_width_0'))
          //           .strokeWidth(2)
          //           .color(this.currentIndex === index ? Color.White : Color.Gray)
          //           .margin({
          //             top: $r('app.integer.divider_margin_top')
          //           })
          //       }
          //       .padding({ top: $r('app.integer.tab_padding_top') })
          //       .width(Const.LIST_ITEM_WIDTH)
          //     }
          //   }, (item: string, index) => JSON.stringify(item))
          // }
          // .listDirection(Axis.Horizontal)
          // .height(Const.FULL_SIZE)
          // .width(Const.LIST_WIDTH)
          Image($r("app.media.search"))
            .width($r('app.integer.search_icon_width'))
            .height($r('app.integer.search_icon_height'))
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              right: { anchor: "dian", align: HorizontalAlign.Start }
            })
            .id("sousuo")
          Image($r("app.media.ellypsis"))
            .width($r('app.integer.add_icon_width'))
            .height($r('app.integer.add_icon_width'))
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              right: { anchor: "__container__", align: HorizontalAlign.End }
            })
            .id("dian")
        }
      }
      .margin({top:10})
      .height($r('app.integer.tab_list_height'))
      .width(Const.FULL_SIZE)
      .alignItems(VerticalAlign.Center)
      // .justifyContent(FlexAlign.SpaceAround)
    }


  }
}

