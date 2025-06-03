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
  @State isHistoryMode: boolean = true; // 默认为历史模式
  @State historyVideos: Array<VideoData> = []; // 历史视频数据

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
      // 首页始终显示推荐内容，不根据模式加载不同数据
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

  // 模式切换方法
  private toggleMode() {
    this.isHistoryMode = !this.isHistoryMode;
    console.log(`🔄 切换到${this.isHistoryMode ? '历史' : '实时'}模式`);
    // 模式切换只影响点击视频后的播放列表，不影响首页显示内容
  }

  // 加载历史视频数据
  private async loadHistoryVideos(): Promise<void> {
    if (!this.userToken) {
      console.warn('⚠️ 没有用户token，无法加载历史视频');
      return;
    }

    this.isLoading = true;
    try {
      console.log('🔄 开始加载历史视频数据...');
      const videos = await apiService.getUserVideos(this.userToken);
      
      if (videos && videos.length > 0) {
        // 转换为VideoData格式
        const historyVideoData = videos.map((item, index) => {
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
            preloaded_url: item.download_link // 历史视频已有下载链接
          };
          return videoData;
        });
        
        // 存储历史视频数据
        this.historyVideos = historyVideoData;
        
        // 清空并重新填充数据源
        this.datas.clearData();
        historyVideoData.forEach(video => {
          this.datas.pushData(video);
        });
        
        console.log(`✅ 成功加载${historyVideoData.length}个历史视频`);
      } else {
        console.log('📭 没有找到历史视频数据');
      }
    } catch (error) {
      console.error('❌ 加载历史视频失败:', error);
    } finally {
      this.isLoading = false;
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

  // 预加载历史视频的播放链接
  private async preloadHistoryVideos(videos: VideoData[]): Promise<void> {
    if (!this.userToken) {
      console.error('❌ 没有用户token，无法预加载历史视频');
      return;
    }

    console.log(`🧠 开始预加载${videos.length}个历史视频的播放链接`);
    
    // 分批预加载，避免同时发起太多请求
    const batchSize = 3;
    for (let i = 0; i < videos.length; i += batchSize) {
      const batch = videos.slice(i, i + batchSize);
      const batchPromises = batch.map(async (video, batchIndex) => {
        const globalIndex = i + batchIndex;
        return this.preloadSingleHistoryVideo(video, globalIndex);
      });
      
      // 等待当前批次完成再进行下一批
      await Promise.allSettled(batchPromises);
      console.log(`📦 批次 ${Math.floor(i/batchSize) + 1} 预加载完成`);
    }
    
    console.log(`🎉 历史视频预加载完成，共处理${videos.length}个视频`);
  }

  // 预加载单个历史视频的播放链接 - 与Dynamic.ets的preloadSingleVideo完全一致
  private async preloadSingleHistoryVideo(video: VideoData, index: number): Promise<void> {
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

  build() {
    Scroll() {
      Column() {
        // 顶部标题栏，包含用户信息和模式切换
        Row() {
          Text("哔哩哔哩")
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .margin({ left: 16 })
          
          // 模式切换按钮
          Button(this.isHistoryMode ? "历史" : "实时")
            .fontSize(12)
            .fontColor(this.isHistoryMode ? '#ff6699' : Color.White)
            .backgroundColor(this.isHistoryMode ? Color.White : 'rgba(255, 255, 255, 0.3)')
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ right: 8 })
            .onClick(() => {
              this.toggleMode();
            })
          
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
                      console.log(`视频名称: ${item.description}`);
                      console.log(`BVID: ${item.bvid}`);
                      console.log(`当前模式: ${this.isHistoryMode ? '历史' : '实时'}`);
                      
                      try {
                        if (this.isHistoryMode) {
                          // 历史模式：像Dynamic.ets一样处理历史记录观看
                          console.log('🎯 历史模式：点击视频进行历史记录观看');
                          
                          // 确保有有效的token
                          if (!this.userToken) {
                            console.error('❌ 没有用户token，无法获取历史视频');
                            promptAction.showToast({ message: '请先登录账号' });
                            return;
                          }
                          
                          // 获取完整的历史视频列表用于播放
                          const allHistoryVideos = await apiService.getUserVideos(this.userToken);
                          
                          if (!allHistoryVideos || allHistoryVideos.length === 0) {
                            console.warn('⚠️ 没有找到历史视频');
                            promptAction.showToast({ message: '没有找到历史视频' });
                            return;
                          }
                          
                          // 转换为VideoData格式
                          const allHistoryVideoData = allHistoryVideos.map((historyItem, index) => {
                            const videoData: VideoData = {
                              description: historyItem.title,
                              head: historyItem.pic,
                              video: historyItem.download_link,
                              audioUrl: '',
                              bvid: historyItem.bvid,
                              aid: historyItem.aid || '',
                              cid: historyItem.cid || '',
                              name: historyItem.name,
                              face: historyItem.face,
                              view: historyItem.view || '0',
                              total: historyItem.current_viewers || '0',
                              like: historyItem.like || '0',
                              barrage: historyItem.danmaku || '0',
                              time: historyItem.duration || '0',
                              pubdate: historyItem.pubdate || '0',
                              coins: historyItem.coin || '0',
                              favorites: historyItem.favorite || '0',
                              shares: historyItem.share || '0',
                              reply: historyItem.reply || '0',
                              tname: historyItem.tname || '',
                              controller: this.myController,
                              auto: true,
                              play: true,
                              index: String(index)
                            };
                            return videoData;
                          });
                          
                          // 找到点击的视频在历史列表中的索引
                          const clickedHistoryIndex = allHistoryVideoData.findIndex(video => video.bvid === item.bvid);
                          
                          let finalVideos: VideoData[] = [];
                          let startIndex = 0;
                          
                          if (clickedHistoryIndex >= 0) {
                            // 点击的是历史视频，重新排序历史列表
                            console.log(`🎯 点击的是历史视频，索引: ${clickedHistoryIndex}`);
                            finalVideos = this.reorderVideosForPlayback(allHistoryVideoData, clickedHistoryIndex);
                            startIndex = 0; // 重排后从第一个开始播放
                            
                            // 优先为点击的历史视频获取播放链接，确保第一个视频可播放
                            console.log(`🎯 优先为点击的历史视频获取播放链接: ${finalVideos[0].bvid}`);
                            await this.preloadSingleHistoryVideo(finalVideos[0], 0);
                            
                            // 验证第一个视频是否有有效的播放链接
                            if (!finalVideos[0].video || !finalVideos[0].video.toString().startsWith('http')) {
                              console.error(`❌ 历史视频 ${finalVideos[0].bvid} 没有获取到有效播放链接，无法播放`);
                              promptAction.showToast({ message: '视频链接获取失败，请重试' });
                              return;
                            }
                            
                            // 预加载其他历史视频的播放链接（异步进行，不阻塞跳转）
                            console.log('🚀 开始预加载其他历史视频的播放链接...');
                            this.preloadHistoryVideos(finalVideos.slice(1, 5)); // 异步预加载第2-5个视频
                          } else {
                            // 点击的是推荐视频，需要解析并插入到历史列表
                            console.log('🆕 点击的是推荐视频，将其插入到历史列表开头');
                            
                            // 先解析视频获取详细信息
                            try {
                              console.log(`🔄 开始解析视频: ${item.bvid}`);
                              
                              if (!this.userToken) {
                                console.error('❌ Token不存在，无法解析视频');
                                promptAction.showToast({ message: '请先登录' });
                                return;
                              }
                              
                              // 构造视频URL用于解析
                              const videoUrl = `https://www.bilibili.com/video/${item.bvid}`;
                              
                              // 调用parseVideo API获取视频详情
                              console.log(`🚀 调用parseVideo API解析视频: ${item.bvid}`);
                              const parseResult = await apiService.parseVideoDetails(this.userToken, videoUrl);
                              
                              if (parseResult) {
                                console.log(`✅ 视频解析成功: ${item.bvid}`);
                                console.log(`🔗 视频链接: ${parseResult.videoUrl}`);
                                console.log(`🔗 音频链接: ${parseResult.audioUrl}`);
                                console.log(`📋 视频标题: ${parseResult.title}`);
                                
                                // 创建点击视频的VideoData，使用解析结果填充
                                const clickedVideoData: VideoData = {
                                  description: parseResult.title || item.description,
                                  head: item.head || '',
                                  video: parseResult.videoUrl, // 使用解析得到的视频链接
                                  audioUrl: parseResult.audioUrl,
                                  bvid: parseResult.bvid || item.bvid,
                                  aid: parseResult.aid || item.aid || '',
                                  cid: parseResult.cid || item.cid || '',
                                  name: parseResult.name || item.name,
                                  face: parseResult.face || item.face,
                                  view: String(parseResult.view || item.view),
                                  total: item.total || '0',
                                  like: String(parseResult.like || item.like || '0'),
                                  barrage: String(parseResult.danmaku || item.barrage || 0),
                                  time: String(parseResult.duration || item.time || 0),
                                  pubdate: String(parseResult.pubdate || item.pubdate || '0'),
                                  coins: String(parseResult.coin || item.coins || '0'),
                                  favorites: String(parseResult.favorite || item.favorites || '0'),
                                  shares: String(parseResult.share || item.shares || '0'),
                                  reply: String(parseResult.reply || item.reply || '0'),
                                  tname: parseResult.tname || item.tname || '推荐',
                                  controller: this.myController,
                                  auto: true,
                                  play: true,
                                  index: '0'
                                };
                                
                                // 将点击的视频放在第一位，后面跟历史视频
                                finalVideos = [clickedVideoData, ...allHistoryVideoData];
                                startIndex = 0;

                                // 历史模式：异步解析推荐视频，不等待解析完成就跳转
                                console.log(`🎯 历史模式：开始异步解析推荐视频: ${item.bvid}`);

                                // 构造视频URL用于解析
                                const videoUrl = `https://www.bilibili.com/video/${item.bvid}`;

                                // 异步调用视频解析接口，不等待完成
                                this.processRecommendedVideoAsync(videoUrl, item.bvid, finalVideos).catch((error: Error) => {
                                  console.error(`❌ 异步解析视频失败: ${item.bvid}`, error);
                                });

                                console.log(`🚀 推荐视频 ${item.bvid} 解析任务已提交，用户可以观看历史视频等待解析完成`);

                                // 预加载其他历史视频的播放链接（异步进行，不阻塞跳转）
                                console.log('🚀 开始预加载其他历史视频的播放链接...');
                                this.preloadHistoryVideos(finalVideos.slice(1, 6)); // 异步预加载第2-6个视频

                                // // 跳转到视频播放页面，传递与Dynamic.ets完全相同的参数
                                // console.log(`🚀 跳转到视频播放页面，第一个视频: ${finalVideos[0].bvid}`);
                                // router.pushUrl({
                                //   url: "pages/VideoPlayer",
                                //   params: {
                                //     videoDatas: finalVideos,
                                //     bvidflag: item.bvid,
                                //     startIndex: 0, // 从重排后的第一个开始播放
                                //     userToken: this.userToken, // 传递用户token
                                //     preloadedCount: 1, // 已预加载的视频数量（第一个视频）
                                //     enableSmartPreload: true, // 启用智能预加载
                                //     preloadRange: 5 // 预加载范围（当前视频前后5个）
                                //   }
                                // });
                              } else {
                                console.error(`❌ 视频解析失败: ${item.bvid}`);
                                promptAction.showToast({ message: '视频解析失败，请重试' });
                              }
                            } catch (error) {
                              console.error(`❌ 解析视频时发生错误: ${item.bvid}`, error);
                              promptAction.showToast({ message: `解析视频失败: ${error.message}` });
                            }
                          }
                          
                          // 最终验证第一个视频的播放链接（历史模式下推荐视频可能正在异步解析）
                          console.log(`🔍 最终验证第一个视频播放链接: ${finalVideos[0].video}`);
                          if (!finalVideos[0].video || !finalVideos[0].video.toString().startsWith('http')) {
                            // 在历史模式下，如果第一个视频是推荐视频且正在解析，这是正常的
                            if (clickedHistoryIndex < 0) {
                              console.log(`⏳ 推荐视频 ${finalVideos[0].bvid} 正在异步解析中，用户可以先观看历史视频`);
                            } else {
                              console.error(`❌ 历史视频没有有效的播放链接，无法播放`);
                              promptAction.showToast({ message: '视频链接无效，请重试' });
                              return;
                            }
                          }
                          
                          // 跳转到视频播放页面，传递与Dynamic.ets完全相同的参数
                          console.log(`🚀 跳转到视频播放页面，第一个视频: ${finalVideos[0].bvid}`);
                          router.pushUrl({
                            url: "pages/VideoPlayer",
                            params: {
                              videoDatas: finalVideos,
                              bvidflag: item.bvid,
                              startIndex: 0, // 从重排后的第一个开始播放
                              userToken: this.userToken, // 传递用户token
                              preloadedCount: 1, // 已预加载的视频数量（第一个视频）
                              enableSmartPreload: true, // 启用智能预加载
                              preloadRange: 5 // 预加载范围（当前视频前后5个）
                            }
                          });
                          
                        } else {
                          // 实时模式：使用推荐视频列表
                          console.log('🔄 实时模式：使用推荐视频列表');
                          
                          const allVideos = this.datas.getAllData();
                          const clickedIndex = allVideos.findIndex(video => video.bvid === item.bvid);
                          const startIndex = clickedIndex >= 0 ? clickedIndex : 0;
                          const reorderedVideos = this.reorderVideosForPlayback(allVideos, startIndex);
                          
                          // 跳转到视频播放页面
                          router.pushUrl({
                            url: "pages/VideoPlayer",
                            params: {
                              videoDatas: reorderedVideos,
                              bvidflag: item.bvid,
                              startIndex: 0,
                              fromHome: true,
                              userToken: this.userToken,
                              playbackMode: 'realtime'
                            }
                          });
                        }
                        
                      } catch (error) {
                        console.error('❌ 处理视频点击失败:', error);
                        promptAction.showToast({ message: '加载视频失败，请重试' });
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
                // 首页始终加载推荐内容，不受模式影响
                if (this.hasMore && !this.isLoading) {
                  if (this.userToken) {
                    this.loadRecommendVideos();
                  } else {
                    this.loadData();
                  }
                }
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

  // 预加载单个推荐视频的播放链接
  private async preloadSingleRecommendedVideo(video: VideoData): Promise<void> {
    try {
      // 检查是否已经有有效的播放链接
      if (video.video && typeof video.video === 'string' && video.video.startsWith('http')) {
        console.log(`⚡ 推荐视频 ${video.bvid} 已有播放链接，跳过预加载`);
        return;
      }
      
      // 使用当前的token进行鉴权
      if (!this.userToken) {
        console.error(`❌ Token不存在，无法预加载推荐视频 ${video.bvid}`);
        return;
      }
      
      console.log(`🔄 开始预加载推荐视频: ${video.description} (${video.bvid})`);
      
      // 使用generate-download-link API获取真正可播放的链接
      const fileName = `${video.bvid}.mp4`;
      const response = await apiService.generateDownloadLink(this.userToken, fileName);
      
      if (response && response.downloadUrl) {
        // 将获取到的播放链接存储到视频数据中
        video.video = response.downloadUrl;
        
        console.log(`✅ 推荐视频 ${video.bvid} 预加载成功，播放链接: ${response.downloadUrl}`);
        console.log(`🔑 下载token: ${response.token}`);
        console.log(`⏰ 链接过期时间: ${response.expiresAt}`);
        
        // 通知播放页面视频解析完成
        AppStorage.setOrCreate('parsedVideoUpdate', {
          bvid: video.bvid,
          timestamp: Date.now(),
          downloadUrl: response.downloadUrl,
          token: response.token,
          expiresAt: response.expiresAt
        });
      } else {
        console.warn(`⚠️ 推荐视频 ${video.bvid} 预加载失败：API返回数据异常`);
        console.warn(`📋 API响应:`, response);
      }
    } catch (error) {
      console.error(`❌ 推荐视频 ${video.bvid} 预加载失败:`, error);
      
      // 预加载失败不影响整体流程，继续处理其他视频
      if (video.video && typeof video.video === 'string' && !video.video.startsWith('http')) {
        console.log(`🔄 尝试使用原有下载链接: ${video.video}`);
        // 保持原有链接不变
      }
    }
  }
  
  // 异步解析推荐视频 - 调用/video/process接口进行真正的视频解析
  private async processRecommendedVideoAsync(videoUrl: string, bvid: string, videoList: VideoData[]): Promise<void> {
    try {
      console.log(`🔄 开始异步解析推荐视频: ${bvid}`);
      console.log(`🔗 视频URL: ${videoUrl}`);
      
      // 检查token
      if (!this.userToken) {
        console.error(`❌ Token不存在，无法解析视频 ${bvid}`);
        return;
      }
      
      // 调用/video/process接口进行视频解析
      console.log(`🚀 调用/video/process接口解析视频: ${bvid}`);
      const processResponse = await apiService.processVideo(this.userToken, videoUrl, 80, 'auto');
      
      if (processResponse && processResponse.playUrl) {
        console.log(`✅ 视频解析成功: ${bvid}`);
        console.log(`🔗 播放链接: ${processResponse.playUrl}`);
        console.log(`📋 视频标题: ${processResponse.title}`);
        console.log(`📁 文件路径: ${processResponse.filePath}`);
        console.log(`🎬 质量描述: ${processResponse.qualityDesc}`);
        
        // 更新第一个视频（点击的推荐视频）的播放链接和信息
        if (videoList.length > 0 && videoList[0].bvid === bvid) {
          // 设置实际的播放链接
          videoList[0].video = processResponse.playUrl;
          // 更新视频标题（如果API返回了更准确的标题）
          if (processResponse.title) {
            videoList[0].description = processResponse.title;
          }
          
          console.log(`🎯 已更新点击视频的播放链接: ${bvid}`);
        }
        
        // 通知播放页面视频解析完成
        AppStorage.setOrCreate('parsedVideoUpdate', {
          bvid: bvid,
          timestamp: Date.now(),
          downloadUrl: processResponse.playUrl,
          title: processResponse.title,
          filePath: processResponse.filePath,
          qualityDesc: processResponse.qualityDesc,
          message: processResponse.message
        });
        
        console.log(`🎉 推荐视频 ${bvid} 解析完成，已通知播放页面`);
        
      } else {
        console.warn(`⚠️ 视频解析失败：API返回数据异常 ${bvid}`);
        console.warn(`📋 API响应:`, processResponse);
      }
      
    } catch (error) {
      console.error(`❌ 异步解析视频失败: ${bvid}`, error);
      
      // 解析失败时的处理
      if (videoList.length > 0 && videoList[0].bvid === bvid) {
        console.log(`🔄 解析失败，视频将保持无播放链接状态，等待用户重试`);
      }
    }
  }
  
  // 异步解析推荐视频 - 使用与Dynamic.ets相同的方法（保留原方法作为备用）
  private async parseRecommendedVideoAsync(bvid: string, videoList: VideoData[]): Promise<void> {
    try {
      console.log(`🔄 开始异步解析推荐视频: ${bvid}`);
      
      // 检查token
      if (!this.userToken) {
        console.error(`❌ Token不存在，无法解析视频 ${bvid}`);
        return;
      }
      
      // 使用与Dynamic.ets相同的方法：generateDownloadLink API获取真正可播放的链接
      const fileName = `${bvid}.mp4`;
      const response = await apiService.generateDownloadLink(this.userToken, fileName);
      
      if (response && response.downloadUrl) {
        console.log(`✅ 视频解析成功: ${bvid}`);
        console.log(`🔗 播放链接: ${response.downloadUrl}`);
        console.log(`🔑 下载token: ${response.token}`);
        console.log(`⏰ 链接过期时间: ${response.expiresAt}`);
        
        // 更新第一个视频（点击的推荐视频）的播放链接
        if (videoList.length > 0 && videoList[0].bvid === bvid) {
          // 设置实际的播放链接
          videoList[0].video = response.downloadUrl;
          
          console.log(`🎯 已更新点击视频的播放链接: ${bvid}`);
        }
        
        // 通知播放页面视频解析完成
        AppStorage.setOrCreate('parsedVideoUpdate', {
          bvid: bvid,
          timestamp: Date.now(),
          downloadUrl: response.downloadUrl,
          token: response.token,
          expiresAt: response.expiresAt
        });
        
      } else {
        console.warn(`⚠️ 视频解析失败：API返回数据异常 ${bvid}`);
        console.warn(`📋 API响应:`, response);
      }
      
    } catch (error) {
      console.error(`❌ 异步解析视频失败: ${bvid}`, error);
      
      // 如果解析失败，尝试使用原有的下载链接（如果有的话）
      if (videoList.length > 0 && videoList[0].bvid === bvid) {
        console.log(`🔄 解析失败，保持原有链接`);
      }
    }
  }
}
