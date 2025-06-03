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
export interface UserVideoInfo {
  id: number;
  bvid: string;
  title: string;
  pic: string;
  duration: string;
  view: string;
  danmaku: string;
  like: string;
  coin: string;
  share: string;
  favorite: string;
  reply: string;
  owner_name: string;
  owner_face: string;
  pubdate: string;
  tname: string;
  download_link: string;
  file_size?: number;
  current_viewers?: string;
  quality: string;
  aid: string;
  desc: string;
  name: string;
  face: string;
  cid: string;
  relation_type: string;
  relation_created_at: string;
  relation_desc: string;
  preloaded_url?: string;
  preloaded_audio?: string;
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
          duration: item.duration || '0',
          view: item.view || '0',
          danmaku: item.danmaku || '0',
          like: item.like || '0',
          coin: item.coin || '0',
          share: item.share || '0',
          favorite: item.favorite || '0',
          reply: item.reply || '0',
          owner_name: item.name,
          owner_face: item.face,
          pubdate: item.pubdate || '0',
          tname: item.tname,
          download_link: item.download_link,
          current_viewers: item.current_viewers || '0',
          quality: item.quality || '',
          aid: item.aid || '',
          desc: item.desc || '',
          name: item.name,
          face: item.face,
          cid: item.cid || '',
          relation_type: item.relation_type || '',
          relation_created_at: item.relation_created_at || '',
          relation_desc: item.relation_desc || ''
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

  // 视频点击处理 - 智能预加载和无缝播放
  private async onVideoClick(clickedVideo: VideoData, clickedIndex: number) {
    console.log(`🎯 点击视频: ${clickedVideo.description}`);    
    try {
      // 显示加载状态
      this.isLoading = true;
      
      // 确保有有效的token
      if (!this.userToken) {
        await this.loadUserToken();
        if (!this.userToken) {
          this.errorMessage = '请先登录账号';
          return;
        }
      }
      
      // 获取全部视频数据
      const allVideosResponse = await this.getUserVideosFromAPI(1, 100);
      const allVideos = this.convertToVideoData(allVideosResponse.videos);
      
      // 找到点击的视频在全部视频中的索引
      const actualClickedIndex = allVideos.findIndex(video => video.bvid === clickedVideo.bvid);
      const startIndex = actualClickedIndex >= 0 ? actualClickedIndex : 0;
      
      // 重新排序视频列表，将点击的视频放在第一位
      const reorderedVideos = this.reorderAllVideos(allVideos, startIndex);
      
      // 优先为点击的视频获取播放链接
      console.log(`🎯 优先为点击视频获取播放链接: ${clickedVideo.bvid}`);
      await this.preloadSingleVideo(reorderedVideos[0], 0);
      
      // 确保第一个视频有有效的播放链接
      if (!reorderedVideos[0].video || typeof reorderedVideos[0].video !== 'string' || !reorderedVideos[0].video.startsWith('http')) {
        console.log(`⚠️ 第一个视频没有获取到有效播放链接，尝试重新获取`);
        const fileName = `${reorderedVideos[0].bvid}.mp4`;
        const response = await apiService.generateDownloadLink(this.userToken, fileName);
        
        if (response && response.downloadUrl) {
          reorderedVideos[0].video = response.downloadUrl;
          reorderedVideos[0].preloaded_url = response.downloadUrl;
          console.log(`✅ 成功获取播放链接: ${response.downloadUrl}`);
        } else {
          console.error(`❌ 无法获取播放链接`);
        }
      }
      
      // 智能预加载策略：预加载前10个视频的播放链接
      console.log(`🚀 开始智能预加载，目标视频索引: ${startIndex}`);
      await this.smartPreloadVideos(reorderedVideos, 1, 9); // 从第二个开始预加载，因为第一个已经预加载了
      
      // 设置选中的视频索引
      this.selectedVideoIndex = startIndex;
      
      // 验证第一个视频是否有有效的播放链接
      if (!reorderedVideos[0].video || !reorderedVideos[0].video.toString().startsWith('http')) {
        console.warn(`⚠️ 第一个视频没有有效的播放链接，使用原始链接`);
        // 如果没有获取到播放链接，保持原有的下载链接
      }
      
      // 跳转到视频播放页面，传递token和预加载信息
      router.pushUrl({
        url: "pages/VideoPlayer",
        params: {
          videoDatas: reorderedVideos,
          bvidflag: clickedVideo.bvid,
          startIndex: 0, // 从重排后的第一个开始播放
          userToken: this.userToken, // 传递用户token
          preloadedCount: 10, // 已预加载的视频数量
          enableSmartPreload: true, // 启用智能预加载
          preloadRange: 5 // 预加载范围（当前视频前后5个）
        }
      });
      
    } catch (error) {
      console.error('❌ 加载视频失败:', error);
      this.errorMessage = '加载视频失败，请重试';
    } finally {
      this.isLoading = false;
    }
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
  
  // 重新排序视频列表，将指定索引的视频放在第一位
  private reorderAllVideos(videos: VideoData[], targetIndex: number): VideoData[] {
    if (targetIndex < 0 || targetIndex >= videos.length) {
      return videos;
    }
    
    const reordered = [...videos];
    const targetVideo = reordered.splice(targetIndex, 1)[0];
    reordered.unshift(targetVideo);
    
    console.info(`视频列表已重排序，目标视频"${targetVideo.description}"现在位于第一位`);
    return reordered;
  }

  // 智能预加载视频 - 优化版本
  private async smartPreloadVideos(videos: Array<VideoData>, startIndex: number, count: number): Promise<void> {
    const endIndex = Math.min(startIndex + count, videos.length);
    const videosToPreload = videos.slice(startIndex, endIndex);
    
    console.log(`🧠 智能预加载开始: 从索引${startIndex}预加载${videosToPreload.length}个视频`);
    
    // 分批预加载，避免同时发起太多请求
    const batchSize = 3;
    for (let i = 0; i < videosToPreload.length; i += batchSize) {
      const batch = videosToPreload.slice(i, i + batchSize);
      const batchPromises = batch.map(async (video, batchIndex) => {
        const globalIndex = startIndex + i + batchIndex;
        return this.preloadSingleVideo(video, globalIndex);
      });
      
      // 等待当前批次完成再进行下一批
      await Promise.allSettled(batchPromises);
      console.log(`📦 批次 ${Math.floor(i/batchSize) + 1} 预加载完成`);
    }
    
    console.log(`🎉 智能预加载完成，共处理${videosToPreload.length}个视频`);
  }
  
  // 预加载单个视频 - 使用正确的下载链接API
  private async preloadSingleVideo(video: VideoData, index: number): Promise<void> {
    try {
      // 检查是否已经预加载过
      if (video.video && typeof video.video === 'string' && video.video.startsWith('http')) {
        console.log(`⚡ 视频 ${video.bvid} 已有播放链接，跳过预加载`);
        return;
      }
      
      // 使用当前的token进行鉴权
      if (!this.userToken) {
        console.error(`❌ Token不存在，无法预加载视频 ${video.bvid}`);
        return;
      }
      
      console.log(`🔄 开始预加载视频 ${index}: ${video.description} (${video.bvid})`);
      
      // 使用generate-download-link API获取真正可播放的链接
      const fileName = `${video.bvid}.mp4`;
      const response = await apiService.generateDownloadLink(this.userToken, fileName);
      
      if (response && response.downloadUrl) {
        // 将获取到的播放链接存储到视频数据中
        video.video = response.downloadUrl;
        video.preloaded_url = response.downloadUrl;
        
        // 标记为已预加载
        this.preloadedVideos.add(video.bvid);
        
        console.log(`✅ 视频 ${video.bvid} 预加载成功，播放链接: ${response.downloadUrl}`);
        console.log(`🔑 下载token: ${response.token}`);
        console.log(`⏰ 链接过期时间: ${response.expiresAt}`);
      } else {
        console.warn(`⚠️ 视频 ${video.bvid} 预加载失败：API返回数据异常`);
        console.warn(`📋 API响应:`, response);
      }
    } catch (error) {
      console.error(`❌ 视频 ${video.bvid} 预加载失败:`, error);
      // 预加载失败不影响整体流程，继续处理其他视频
      
      // 如果是权限问题，尝试使用原有的下载链接
      if (video.video && typeof video.video === 'string' && !video.video.startsWith('http')) {
        console.log(`🔄 尝试使用原有下载链接: ${video.video}`);
        // 保持原有链接不变
      }
    }
  }
  
  // 预加载视频链接（带鉴权）
  private async preloadVideoLinksWithAuth(videos: VideoData[]): Promise<void> {
    if (!videos || videos.length === 0) {
      console.log('没有视频需要预加载');
      return;
    }
    
    console.log(`开始预加载${videos.length}个视频的播放链接`);
    
    // 确保有有效的token
    if (!this.userToken) {
      await this.loadUserToken();
      if (!this.userToken) {
        console.error('无法获取用户token，预加载失败');
        return;
      }
    }
    
    // 并行预加载所有视频
    const preloadPromises = videos.map(async (video, index) => {
      try {
        // 检查是否已经有有效的播放链接
        if (video.video && typeof video.video === 'string' && video.video.startsWith('http')) {
          console.log(`视频 ${video.bvid} 已有播放链接，跳过预加载`);
          return;
        }
        
        console.log(`预加载视频 ${index}: ${video.description} (${video.bvid})`);
        
        // 使用generate-download-link API获取真正可播放的链接
        const fileName = `${video.bvid}.mp4`;
        const response = await apiService.generateDownloadLink(this.userToken, fileName);
        
        if (response && response.downloadUrl) {
          // 将获取到的播放链接存储到视频数据中
          video.video = response.downloadUrl;
          video.preloaded_url = response.downloadUrl;
          
          // 标记为已预加载
          this.preloadedVideos.add(video.bvid);
          
          console.log(`视频 ${video.bvid} 预加载成功，播放链接: ${response.downloadUrl}`);
        } else {
          console.warn(`视频 ${video.bvid} 预加载失败：API返回数据异常`);
        }
      } catch (error) {
        console.error(`视频 ${video.bvid} 预加载失败:`, error);
        // 预加载失败不影响整体流程，继续处理其他视频
      }
    });
    
    // 等待所有预加载完成
    await Promise.allSettled(preloadPromises);
    console.log(`${videos.length}个视频预加载完成`);
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
    const currentData = this.datas.getData(this.index);
        if (currentData && currentData.controller && typeof currentData.controller.start === 'function') {
          currentData.controller.start();
        }
  }

  onPageHide(): void {
    const currentData = this.datas.getData(this.index);
        if (currentData && currentData.controller && typeof currentData.controller.pause === 'function') {
          currentData.controller.pause();
        }
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
        // 视频列表 - 网格布局（类似首页）
        Refresh({ refreshing: this.isRefreshing }) {
          List({ space: 5 }) {
            LazyForEach(this.datas, (item: VideoData, index: number) => {
              ListItem() {
                Column() {
                  // 图片容器
                  Stack() {
                    Image(item.head || '')
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
                  .width('100%')
                  .height(130)
                  
                  // 视频信息区域
                  Column() {
                    // 视频标题
                    Text(item.description || '无标题')
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
                      Text(item.name || '未知UP主')
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
                  console.log(`点击视频: ${item.description}`);
                  
                  try {
                    this.isLoading = true;
                    
                    // 获取所有视频（100个）
                    const allVideosResponse = await this.getUserVideosFromAPI(1, 100);
                    const allVideos = this.convertToVideoData(allVideosResponse.videos);
                    
                    // 找到当前点击的视频在完整列表中的位置
                    const clickedVideoIndex = allVideos.findIndex(video => video.bvid === item.bvid);
                    
                    // 重新排序，将点击的视频放在第一位
                    const reorderedVideos = this.reorderAllVideos(allVideos, clickedVideoIndex);
                    
                    // 预加载前5个视频的播放链接
                    await this.preloadVideoLinksWithAuth(reorderedVideos.slice(0, 5));
                    
                    // 跳转到视频播放页面
                    router.pushUrl({
                      url: "pages/VideoPlayer",
                      params: {
                        videoDatas: reorderedVideos,
                        preloadedCount: 5,
                        startIndex: 0,
                        fromDynamic: true, // 标识来自动态页面
                        userToken: this.userToken // 传递用户token
                      }
                    });
                    
                    console.info(`已跳转到视频播放页面，共${reorderedVideos.length}个视频，预加载5个`);
                    
                  } catch (error) {
                    console.error('处理视频点击失败:', error);
                    promptAction.showToast({ message: '加载视频失败，请重试' });
                  } finally {
                    this.isLoading = false;
                  }
                })
                .borderRadius(8)
                .width('100%')
                .backgroundColor(Color.White)
                .shadow({ radius: 4, color: '#00000015', offsetX: 0, offsetY: 2 })
              }
              .margin({ bottom: 12 })
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
          .lanes(2, 5)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
        }
        .onRefreshing(() => this.refreshVideoList())
        .refreshOffset(64)
        .pullToRefresh(true)
        .padding({ left: 5, right: 5 })
        .backgroundColor('#DCDCDC')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
