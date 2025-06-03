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

// 定义视频解析更新信息接口
interface ParsedVideoUpdateInfo {
  bvid: string;
  timestamp: number;
  downloadUrl?: string;
  playUrl?: string;
  title?: string;
  filePath?: string;
  qualityDesc?: string;
  token?: string;
  expiresAt?: string;
  message?: string;
}

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
  @State playbackMode: string = 'realtime'; // 播放模式：'realtime' 或 'history'
  scroller: Scroller = new Scroller();
  private topTabListData: TopTabContent = new TopTabContent();
  private context = getContext(this) as common.UIAbilityContext;

  controller: webview.WebviewController = new webview.WebviewController();
  videoDatas: Array<VideoData> = [];

  // 存储传递的用户token
  private userToken: string | null = null;
  private preloadedVideos: Set<string> = new Set(); // 记录已预加载的视频
  private parsedVideoListener: (value: Object) => void = () => {}; // AppStorage监听器
  @State private parsedVideoUpdateFlag: number = 0; // 强制刷新标志
  
  async aboutToAppear() {
    try {
      // 设置AppStorage监听器，监听视频解析完成事件
      this.setupParsedVideoListener();
      
      // 安全获取路由参数
      let params: Record<string, Object> = {};
      try {
        params = router.getParams() as Record<string, Object> || {};
      } catch (paramError) {
        console.error('获取路由参数失败:', paramError);
        params = {};
      }
      
      // 接收传递的用户token
      if (params["userToken"] && typeof params["userToken"] === 'string') {
        this.userToken = params["userToken"] as string;
      }
      
      // 检查是否来自解析页面
      this.fromParse = Boolean(params["fromParse"]) || false;
      
      // 接收播放模式参数
      if (params["playbackMode"] && typeof params["playbackMode"] === 'string') {
        this.playbackMode = params["playbackMode"] as string;
        console.log(`🎬 播放模式: ${this.playbackMode}`);
      }
      
      // 优先处理传入的视频数据列表（来自Dynamic页面或Home页面）
      if (params["videoDatas"] && Array.isArray(params["videoDatas"]) && params["videoDatas"].length > 0) {
        try {
          const videoDatas = params["videoDatas"] as VideoData[];
          const startIndex = Number(params["startIndex"]) || 0;
          const fromHome = Boolean(params["fromHome"]) || false;
          const fromDynamic = Boolean(params["fromDynamic"]) || false;
          
          // 清空默认数据，使用传入的视频列表
          this.datas.clearData();
          videoDatas.forEach((video, index) => {
            // 更新视频索引
            video.index = index.toString();
            this.datas.pushData(video);
          });
          
          // 设置起始播放位置
          this.index = startIndex;
          
          // 确保当前视频可播放
          if (this.datas.totalCount() > startIndex) {
            const currentVideo = this.datas.getData(startIndex);
            await this.ensureVideoPlayable(currentVideo, startIndex);
            
            // 设置自动播放标志
            currentVideo.auto = true;
            currentVideo.play = true;
            this.datas.updateDataAtIndex(startIndex, currentVideo);
            
            // 强制刷新UI
            this.parsedVideoUpdateFlag++;
          }
          
          // 智能预加载相邻视频以实现连续播放
          if (fromDynamic) {
            await this.smartPreloadAdjacentVideos(startIndex);
          }
          
          // 如果来自首页且有bvidflag，异步解析更高质量版本
          if (fromHome && params["bvidflag"]) {
            this.parseVideoFromParams(params, true);
          }
          
        } catch (dataError) {
          console.error('处理传入视频数据失败:', dataError);
          // 如果处理失败，回退到解析模式
          await this.handleFallbackMode(params);
        }
      } else {
        // 没有传入视频列表，使用传统模式
        await this.handleFallbackMode(params);
      }
      
    } catch (error) {
      console.error('VideoPlayer组件初始化失败:', error);
      // 确保即使出错也能显示默认视频
      await this.loadHistoryVideosAsBackup();
    }
  }
  
  // 处理回退模式（没有传入视频列表的情况）
  private async handleFallbackMode(params: Record<string, Object> = {}) {
    // 先加载用户的历史视频作为备选内容
    await this.loadHistoryVideosAsBackup();
    
    // 如果有bvidflag参数，异步解析目标视频
    if (params["bvidflag"] && typeof params["bvidflag"] === 'string') {
      // 异步解析，不阻塞用户观看历史视频
      this.parseVideoFromParams(params, true);
    }
  }

  // 历史模式下加载历史视频列表用于播放
  private async loadHistoryVideosForPlayback(currentIndex: number) {
    if (!this.userToken) {
      console.warn('⚠️ 没有用户token，无法加载历史视频');
      return;
    }

    try {
      console.log(`🔄 历史模式：加载历史视频列表，当前索引: ${currentIndex}`);
      
      // 检查是否已经是历史视频列表（通过检查第一个视频的来源）
      const firstVideo = this.datas.getData(0);
      const isAlreadyHistoryList = firstVideo && firstVideo.tname; // 历史视频有tname字段
      
      if (!isAlreadyHistoryList) {
        // 如果当前不是历史视频列表，则替换为历史视频列表
        const historyVideos = await apiService.getUserVideos(this.userToken);
        
        if (historyVideos && historyVideos.length > 0) {
          console.log(`🔄 替换为历史视频列表，共${historyVideos.length}个视频`);
          
          // 清空当前播放列表
          this.datas.clearData();
          
          // 转换为VideoData格式并添加到播放列表
          const historyVideoData = historyVideos.map((item, index) => {
            const videoData: VideoData = {
              description: item.title,
              head: item.pic,
              video: item.download_link,
              audioUrl: '',
              bvid: item.bvid,
              aid: item.aid || '',
              cid: item.cid || '',
              name: item.name,
              face: item.face,
              view: item.view || '0',
              total: item.current_viewers || '0',
              like: item.like || '0',
              barrage: item.danmaku || '0',
              time: item.duration || '0',
              pubdate: item.pubdate || '0',
              coins: item.coin || '0',
              favorites: item.favorite || '0',
              shares: item.share || '0',
              reply: item.reply || '0',
              tname: item.tname || '',
              controller: this.myController,
              auto: true,
              play: true,
              index: String(index),
              preloaded_url: item.download_link
            };
            return videoData;
          });
          
          // 添加历史视频到播放列表
          historyVideoData.forEach(video => {
            this.datas.pushData(video);
          });
          
          // 重置播放索引到第一个历史视频
          this.index = 0;
          
          console.log(`✅ 历史模式：成功替换为${historyVideoData.length}个历史视频`);
        }
      } else {
        // 如果已经是历史视频列表，检查是否需要加载更多
        const totalCount = this.datas.totalCount();
        const remainingVideos = totalCount - currentIndex;
        
        if (remainingVideos <= 3) {
          console.log(`🔄 历史模式：当前已是历史列表，剩余视频${remainingVideos}个，无需加载更多`);
        }
      }
    } catch (error) {
      console.error('❌ 历史模式加载视频失败:', error);
    }
  }

  // 智能预加载相邻视频以实现连续播放
  private async smartPreloadAdjacentVideos(currentIndex: number) {
    try {
      const totalCount = this.datas.totalCount();
      const preloadTasks: Promise<void>[] = [];
      
      // 预加载策略：当前视频的前1个和后2个视频
      const preloadIndices: number[] = [];
      
      // 前一个视频
      if (currentIndex > 0) {
        preloadIndices.push(currentIndex - 1);
      }
      
      // 后面的视频（优先级更高）
      for (let i = 1; i <= 2 && currentIndex + i < totalCount; i++) {
        preloadIndices.push(currentIndex + i);
      }
      
      // 并发预加载
      for (const index of preloadIndices) {
        const video = this.datas.getData(index);
        if (video && video.bvid && !this.preloadedVideos.has(video.bvid)) {
          preloadTasks.push(this.preloadSingleVideoAsync(video, index));
        }
      }
      
      // 等待所有预加载任务完成（但不阻塞主流程）
      if (preloadTasks.length > 0) {
        Promise.allSettled(preloadTasks);
      }
      
    } catch (error) {
      console.error('智能预加载失败:', error);
    }
  }
  
  // 从参数解析视频 - 使用新的API流程
  private async parseVideoFromParams(params: Record<string, Object>, isAsync: boolean = false) {
    if (!isAsync) {
      this.isLoading = true;
    }
    
    try {
      const bvidflag = params["bvidflag"] as string;
      
      if (bvidflag) {
        const blibliurl = `https://www.bilibili.com/video/${bvidflag}`;
        
        // 检查context和token状态
        if (!this.context) {
          console.error('应用上下文不存在，无法获取token');
          promptAction.showToast({ message: '应用初始化失败，仅可观看本地视频' });
          return;
        }
        
        let token: string | null = null;
        try {
          // 添加超时保护
          const tokenPromise = tokenManager.getToken(this.context);
          const timeoutPromise = new Promise<null>((_, reject) => {
            setTimeout(() => reject(new Error('获取token超时')), 5000);
          });
          
          token = await Promise.race([tokenPromise, timeoutPromise]);
        } catch (tokenError) {
          console.error('获取token时出错:', tokenError);
          promptAction.showToast({ message: '获取登录状态失败，本地视频仍可观看' });
          return;
        }
        
        if (!token) {
          console.error('用户未登录，无法处理视频');
          promptAction.showToast({ message: '请先登录后再解析在线视频，本地视频仍可观看' });
          return;
        }
        
        let result: BilibiliVideoInfo | null = null;
        try {
          // 使用新的完整视频处理流程，添加超时保护
          const apiPromise = bilibiliService.processVideoComplete(this.context, blibliurl);
          const timeoutPromise = new Promise<null>((_, reject) => {
            setTimeout(() => reject(new Error('视频处理超时，请检查网络连接')), 900000); // 15分钟超时
          });
          
          result = await Promise.race([apiPromise, timeoutPromise]);
        } catch (apiError) {
          console.error('调用视频处理流程时出错:', apiError);
          
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
          return;
        }
        
        if (result) {
          try {
            const videoData: VideoData = {
              description: result.title || '未知标题',
              head: result.pic || $r('app.media.photo35'),
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
            
            if (isAsync) {
              // 异步模式：将解析成功的视频插入到当前播放视频的下一个位置
              const currentIndex = this.index;
              const insertIndex = currentIndex + 1;
              this.datas.addData(insertIndex, videoData);
              
              // 显示解析成功的提示
              promptAction.showToast({ message: '目标视频解析完成！已添加到播放列表' });
            } else {
              // 同步模式：将解析成功的视频插入到列表开头
              this.datas.addData(0, videoData);
              
              // 显示解析成功的提示
              promptAction.showToast({ message: '视频解析成功！' });
            }
          } catch (dataError) {
            console.error('创建视频数据时出错:', dataError);
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
      this.loadDefaultVideos();
    } finally {
      if (!isAsync) {
        this.isLoading = false;
      }
    }
  }

  // 此处已删除重复的handleFallbackMode方法，使用上面的实现
  
  // 加载默认视频（兼容旧代码）
  private loadDefaultVideos() {
    console.info('加载默认视频（已重定向到历史视频）');
    this.loadHistoryVideosAsBackup();
  }

  // 加载历史视频作为备选内容
  private async loadHistoryVideosAsBackup() {
    try {
      console.info('开始加载用户历史视频作为备选内容...');
      
      // 清空现有数据
      this.datas.clearData();
      
      // 检查登录状态
      if (!this.context) {
        console.warn('应用上下文不存在，无法加载历史视频');
        return;
      }
      
      const token = await tokenManager.getToken(this.context);
      if (!token) {
        console.warn('用户未登录，无法加载历史视频');
        return;
      }
      
      // 获取用户历史视频
      const historyVideos = await apiService.getUserVideos(token);
      
      if (historyVideos && historyVideos.length > 0) {
        console.info(`成功获取${historyVideos.length}个历史视频`);
        
        // 转换为VideoData格式
        historyVideos.forEach((video, index) => {
          const videoData: VideoData = {
            description: video.title || '未知标题',
            head: video.pic || $r('app.media.photo35'),
            video: video.download_link || '',
            audioUrl: '',
            bvid: video.bvid,
            aid: String(video.id),
            cid: video.cid || '0',
            name: video.name,
            face: video.face || 'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
            view: String(video.view || '0'),
            like: String(video.like || '0'),
            barrage: String(video.danmaku || '0'),
            time: String(video.duration || '0'),
            pubdate: String(video.pubdate || '0'),
            coins: String(video.coin || '0'),
            favorites: String(video.favorite || '0'),
            shares: String(video.share || '0'),
            reply: String(video.reply || '0'),
            tname: video.tname || '未知分区',
            controller: this.myController,
            auto: false,
            play: false,
            index: index.toString(),
            total: String(video.current_viewers || '0'),
            preloaded_url: '',
            preloaded_audio: ''
          };
          
          this.datas.pushData(videoData);
        });
        
        console.info('历史视频加载完成，用户可以先观看历史内容');
        
        // 预加载前3个视频的播放链接
        const videosToPreload = historyVideos.slice(0, 3).map((video): UserVideoInfo => ({
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
        }));
        
        // 异步预加载，不阻塞界面
        this.preloadVideoLinks(videosToPreload).then(() => {
          console.info('历史视频预加载完成');
        });
        
      } else {
        console.info('没有找到历史视频');
      }
      
    } catch (error) {
      console.error('加载历史视频失败:', error);
    }
  }
  
  // 预加载视频播放链接
  private async preloadVideoLinks(videos: UserVideoInfo[]) {
    try {
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
      Promise.allSettled(preloadPromises);
      
    } catch (error) {
      console.error('预加载视频链接失败:', error);
    }
  }

  // 获取正确的视频源
  private getVideoSource(item: VideoData): Resource | string {
    console.log(`🎬 获取视频源 ${item.bvid}:`);
    console.log(`  - preloaded_url: ${item.preloaded_url}`);
    console.log(`  - video: ${item.video}`);
    
    // 优先使用预加载的URL（通常是最新的有效链接）
    if (item.preloaded_url && typeof item.preloaded_url === 'string' && item.preloaded_url.startsWith('http')) {
      console.log(`✅ 使用预加载链接: ${item.preloaded_url}`);
      return item.preloaded_url;
    }
    
    // 如果video是HTTP URL字符串，使用它
    if (typeof item.video === 'string' && item.video.startsWith('http')) {
      console.log(`✅ 使用video字段: ${item.video}`);
      return item.video;
    }
    
    // 如果没有有效链接，尝试立即获取（异步）
    if (item.bvid && this.userToken) {
      console.log(`⚠️ 没有有效链接，尝试立即获取: ${item.bvid}`);
      
      // 异步获取，不阻塞UI渲染
      setTimeout(async () => {
        try {
          const fileName = `${item.bvid}.mp4`;
          const response = await apiService.generateDownloadLink(this.userToken!, fileName);
          
          if (response && response.downloadUrl) {
            // 更新视频数据
            item.video = response.downloadUrl;
            item.preloaded_url = response.downloadUrl;
            
            // 强制刷新UI
            this.parsedVideoUpdateFlag++;
            console.log(`✅ 成功获取播放链接: ${response.downloadUrl}`);
            
            // 如果是当前视频，尝试立即播放
            const currentIndex = this.index;
            const videoData = this.datas.getData(currentIndex);
            if (videoData && videoData.bvid === item.bvid && 
                videoData.controller && typeof videoData.controller.start === 'function') {
              setTimeout(() => {
                try {
                  console.log(`▶️ 获取链接后立即播放视频 ${item.bvid}`);
                  videoData.controller.start();
                } catch (playError) {
                  console.error(`❌ 获取链接后播放视频失败:`, playError);
                }
              }, 300);
            }
          }
        } catch (error) {
          console.error(`❌ 立即获取播放链接失败:`, error);
        }
      }, 0);
    }
    
    // 返回原始值
    console.log(`✅ 使用原始值: ${item.video}`);
    return item.video;
  }

  // 重试视频播放的方法
  private async retryVideoPlayback(item: VideoData, index: number): Promise<void> {
    try {
      // 确保有用户token
      if (!this.userToken) {
        return;
      }
      
      // 重新获取播放链接
      const fileName = `${item.bvid}.mp4`;
      const response = await apiService.generateDownloadLink(this.userToken, fileName);
      
      if (response && response.downloadUrl) {
        // 更新视频数据
        item.video = response.downloadUrl;
        item.preloaded_url = response.downloadUrl;
        
        // 强制刷新Video组件
        this.datas.notifyDataChange(index);
      }
    } catch (error) {
      console.error(`重试视频播放失败:`, error);
    }
  }

  // 异步预加载单个视频 - 使用正确的下载链接API
  private async preloadSingleVideoAsync(video: VideoData, index: number): Promise<void> {
    try {
      if (!video.bvid || this.preloadedVideos.has(video.bvid)) {
        return;
      }
      
      this.preloadedVideos.add(video.bvid);
      
      // 获取token（优先使用传递的token）
      let token = this.userToken;
      if (!token && this.context) {
        token = await tokenManager.getToken(this.context);
      }
      
      if (!token) {
        return;
      }
      
      // 使用generate-download-link API获取真正可播放的链接
      const fileName = `${video.bvid}.mp4`;
      const result = await apiService.generateDownloadLink(token, fileName);
      
      if (result && result.downloadUrl) {
        // 存储预加载的播放链接
        video.preloaded_url = result.downloadUrl;
        video.video = result.downloadUrl; // 直接更新video字段
        
        // 更新数据源
        this.datas.updateDataAtIndex(index, video);
      }
      
    } catch (error) {
      console.error(`预加载视频${video.bvid}时出错:`, error);
    }
  }
  
  // 确保视频可播放（动态鉴权）
  private async ensureVideoPlayable(video: VideoData, index: number, forceRefresh: boolean = false) {
    try {
      // 如果强制刷新或没有预加载链接，则重新获取
      if (!forceRefresh && video.preloaded_url && video.preloaded_url.startsWith('http')) {
        console.log(`✅ 视频 ${video.bvid} 已有预加载链接，跳过鉴权`);
        video.video = video.preloaded_url;
        if (video.preloaded_audio) {
          video.audioUrl = video.preloaded_audio;
        }
        // 设置自动播放标志
        video.auto = true;
        video.play = true;
        // 更新数据源
        this.datas.updateDataAtIndex(index, video);
        
        // 如果是当前视频，延迟触发播放
        if (index === this.index && video.controller && typeof video.controller.start === 'function') {
          setTimeout(() => {
            try {
              console.log(`▶️ 预加载视频立即播放: ${video.bvid}`);
              video.controller.start();
            } catch (playError) {
              console.error(`❌ 预加载视频播放失败:`, playError);
            }
          }, 500);
        }
        return;
      }
      
      console.log(`🔐 开始为视频 ${video.bvid} 进行动态鉴权${forceRefresh ? '(强制刷新)' : ''}...`);
      
      // 检查视频是否已经有有效的播放链接
      if (!forceRefresh && video.video && typeof video.video === 'string' && video.video.startsWith('http') && 
          !video.video.includes('/api/video/download/') && 
          !video.video.includes('download_link')) {
        // 设置自动播放标志
        video.auto = true;
        video.play = true;
        this.datas.updateDataAtIndex(index, video);
        return;
      }
      
      // 如果没有有效播放链接，动态获取
      if (video.bvid && this.context) {
        // 优先使用传递的token
        let token = this.userToken;
        if (!token) {
          token = await tokenManager.getToken(this.context);
        }
        
        if (!token) {
          console.error('❌ 无法获取用户token');
          return;
        }
        
        // 使用generate-download-link API获取真正可播放的链接
        const fileName = `${video.bvid}.mp4`;
        const result = await apiService.generateDownloadLink(token, fileName);
        
        if (result && result.downloadUrl) {
          const oldUrl = video.preloaded_url;
          // 将获取到的播放链接存储到视频数据中
          video.video = result.downloadUrl;
          video.preloaded_url = result.downloadUrl;
          
          console.log(`✅ 视频 ${video.bvid} 动态鉴权成功`);
          console.log(`🔗 旧链接: ${oldUrl}`);
          console.log(`🔗 新链接: ${result.downloadUrl}`);
          
          // 设置自动播放标志（无论是否为当前视频）
          video.auto = true;
          video.play = true;
          console.log(`🎬 设置视频 ${video.bvid} 为自动播放`);
          
          // 更新数据源
          this.datas.updateDataAtIndex(index, video);
          
          // 如果链接发生变化，强制刷新UI
          if (oldUrl !== result.downloadUrl) {
            this.parsedVideoUpdateFlag++;
            console.log(`🔄 视频链接已更新，强制刷新UI`);
          }
          
          // 延迟尝试播放（给UI更新时间）
          setTimeout(() => {
            try {
              console.log(`▶️ 尝试立即播放视频 ${video.bvid}`);
              if (video.controller && typeof video.controller.start === 'function') {
                video.controller.start();
              }
            } catch (playError) {
              console.error(`❌ 立即播放视频失败:`, playError);
            }
          }, 500); // 延迟500毫秒确保UI已更新
        } else {
          console.error(`❌ 视频 ${video.bvid} 动态鉴权失败`);
        }
      }
    } catch (error) {
      console.error(`❌ 视频 ${video.bvid} 动态鉴权异常:`, error);
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
  // 设置AppStorage监听器，监听视频解析完成事件
  private setupParsedVideoListener() {
    console.log('🎧 设置视频解析完成监听器');
    
    // 使用定时器轮询检查AppStorage中的更新
    setInterval(() => {
      try {
        const updateInfo = AppStorage.get<ParsedVideoUpdateInfo>('parsedVideoUpdate');
        
        if (updateInfo && updateInfo.bvid && updateInfo.timestamp) {
          // 检查是否是新的更新（基于时间戳）
          const lastProcessedTime = AppStorage.get<number>('lastProcessedUpdateTime') || 0;
          if (updateInfo.timestamp > lastProcessedTime) {
            console.log(`🎉 收到视频解析完成通知: ${updateInfo.bvid}`);
            console.log(`🔗 新播放链接: ${updateInfo.downloadUrl || updateInfo.playUrl}`);
            
            // 查找对应的视频并更新播放链接
            const totalCount = this.datas.totalCount();
            for (let i = 0; i < totalCount; i++) {
              const video = this.datas.getData(i);
              if (video && video.bvid === updateInfo.bvid) {
                console.log(`🎯 找到目标视频，更新播放链接: ${updateInfo.bvid}`);
                
                // 更新播放链接（优先使用playUrl，其次downloadUrl）
                const newPlayUrl = updateInfo.playUrl || updateInfo.downloadUrl;
                if (newPlayUrl) {
                  video.video = newPlayUrl;
                  video.preloaded_url = newPlayUrl;
                  
                  // 更新标题（如果有）
                  if (updateInfo.title) {
                    video.description = updateInfo.title;
                  }
                  
                  // 强制更新数据源
                  this.datas.updateDataAtIndex(i, video);
                  
                  // 如果是当前播放的视频，强制刷新UI
                  if (i === this.index) {
                    this.parsedVideoUpdateFlag++;
                    console.log(`🔄 当前播放视频已更新，强制刷新UI`);
                  }
                  
                  console.log(`✅ 视频 ${updateInfo.bvid} 播放链接已更新完成`);
                }
                break;
              }
            }
            
            // 更新最后处理时间
            AppStorage.setOrCreate('lastProcessedUpdateTime', updateInfo.timestamp);
          }
        }
      } catch (error) {
        console.error('❌ 处理视频解析完成事件失败:', error);
      }
    }, 1000); // 每秒检查一次
  }
  
  // 移除AppStorage监听器
  private removeParsedVideoListener() {
    try {
      console.log('🔇 移除视频解析完成监听器');
      // 这里可以添加移除监听器的逻辑，如果HarmonyOS提供相应API
    } catch (error) {
      console.error('移除监听器失败:', error);
    }
  }
  
  onPageShow(): void {
    console.log('📺 VideoPlayer页面显示');
    const currentData = this.datas.getData(this.index);
    if (currentData && currentData.controller && typeof currentData.controller.start === 'function') {
      currentData.controller.start();
      currentData.play = true;
      this.playBoo = true;
    }
  }
  
  onPageHide(): void {
    console.log('📺 VideoPlayer页面隐藏');
    const currentData = this.datas.getData(this.index);
    if (currentData && currentData.controller && typeof currentData.controller.pause === 'function') {
      currentData.controller.pause();
    }
  }
  
  aboutToDisappear(): void {
    console.log('📺 VideoPlayer页面即将销毁');
    this.removeParsedVideoListener();
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
                    src: this.getVideoSource(item),
                    controller: item.controller,
                    previewUri: item.head,
                  })
                    .width(Const.FULL_SIZE)
                    .height(Const.FULL_SIZE)
                    .objectFit(ImageFit.Contain)
                    .loop(true)
                    .autoPlay(index === this.index) // 确保当前视频自动播放
                    .controls(true) // 启用控制条以便调试
                    .muted(false) // 确保音频未静音
                    .opacity(1.0) // 确保视频可见
                    .backgroundColor(Color.Black) // 设置背景色
                    .onStart(() => {
                      item.play = true;
                      const currentData = this.datas.getData(this.index);
                      if (currentData) {
                        this.playBoo = currentData.play;
                      }
                      console.log(`▶️ 视频 ${item.bvid} 开始播放`);
                    })
                    .onPause(() => {
                      item.play = false;
                      const currentData = this.datas.getData(this.index);
                      if (currentData) {
                        this.playBoo = currentData.play;
                      }
                      console.log(`⏸️ 视频 ${item.bvid} 暂停播放`);
                    })
                    .onClick(() => {
                      if (item && item.controller) {
                        if (item.play && typeof item.controller.pause === 'function') {
                          item.controller.pause();
                        } else if (!item.play && typeof item.controller.start === 'function') {
                          item.controller.start();
                        }
                      }
                    })
                    .onError(() => {
                      console.error(`❌ 视频播放错误 ${item.bvid}`);
                      item.play = false;
                      
                      // 尝试重新获取播放链接（异步执行）
                      console.log(`🔄 尝试重新获取视频 ${item.bvid} 的播放链接...`);
                      this.ensureVideoPlayable(item, index, true).then(() => {
                        // 强制刷新UI以重新加载视频
                        this.parsedVideoUpdateFlag++;
                        console.log(`🔄 视频 ${item.bvid} 播放链接已刷新，重新尝试播放`);
                      }).catch((retryError: Error) => {
                        console.error(`❌ 重试获取视频 ${item.bvid} 播放链接失败:`, retryError);
                      });
                    })
                    .onVisibleAreaChange([0.0, 1.0], (isVisisble: boolean, currentRatio: number) => {
                      if (isVisisble && currentRatio >= 1.0 && item && item.controller && typeof item.controller.start === 'function') {
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
                    if (item && item.controller && typeof item.controller.start === 'function') {
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
          
          // 获取当前视频数据
          const currentVideo = this.datas.getData(index);
          if (currentVideo) {
            console.log(`🎯 当前视频: ${currentVideo.bvid}`);
            
            // 设置自动播放标志
            currentVideo.auto = true;
            currentVideo.play = true;
            
            // 确保当前视频可播放
            await this.ensureVideoPlayable(currentVideo, index);
            
            // 如果视频仍然无法播放，尝试强制刷新
            const videoSource = this.getVideoSource(currentVideo);
            if (!videoSource || videoSource === '') {
              console.log(`⚠️ 视频源为空，尝试强制刷新: ${currentVideo.bvid}`);
              await this.ensureVideoPlayable(currentVideo, index, true);
            }
            
            // 立即尝试播放视频
            if (currentVideo.controller && typeof currentVideo.controller.start === 'function') {
              setTimeout(() => {
                try {
                  console.log(`▶️ 滑动切换后立即播放视频 ${currentVideo.bvid}`);
                  currentVideo.controller.start();
                } catch (playError) {
                  console.error(`❌ 滑动切换后播放视频失败:`, playError);
                }
              }, 300);
            }
          }
          
          // 根据播放模式决定滑动行为
          if (this.playbackMode === 'history') {
            // 历史模式：滑动时加载历史视频列表
            await this.loadHistoryVideosForPlayback(index);
          } else {
            // 实时模式：动态预加载机制，预加载后续推荐视频
            this.smartPreloadAdjacentVideos(index).catch((error: Error) => {
              console.error('❌ 处理视频切换失败:', error);
            });
          }
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

