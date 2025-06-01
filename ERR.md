这是以前的解析流程

import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';



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

  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  async aboutToAppear() {
    await this.loadData(); // 加载初始数据
  }

  // 加载数据的公共方法
  private async loadData() {
    // const sessdata = '你的SESSDATA'; // 替换成实际的 SESSDATA
    const sessdata = 'ab9d6d14%2C1746252800%2C9f8a2%2Ab1CjDy9wFwCOPazj3xO5hhngHPdK3Iy0kaicJX2rOm6GhJYUynqJTtckHDkSZAPDFjGZoSVjdkVWUxN1VYZlBuYUp3a291eDdLOVl3VnRKV0l3UUJnZHNSRTY2T3ppWkphbkhLeU1fc05DYVZVb3Ywd1h2eTd6U1hkWnZZTlNCdXR1OUIybzM1clh3IIEC'; // 替换成实际的 SESSDATA
    const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      console.error('请求失败');
    }
  }

  private parseApiResponse(response: object) {
    console.info(JSON.stringify(response));
    if (response["code"] === 0 && response["data"]["item"]) {
      const items:Array<string> = response["data"]["item"];

      for (let i = 0; i < items.length; i++) {
        const item = items[i];

        this.datas.pushData({
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["uri"], // 视频链接
          bvid:item["bvid"],//地址
          name: item["owner"]["name"], // UP主
          face:item["owner"]["face"],
          view: item["stat"]["view"], // 播放量
          total:'55555',
          like:item["stat"]["like"],//点赞
          barrage: item["stat"]["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          pubdate:item["pubdate"],//发布时间
          coins: '55555',//投币
          favorites: '55555',//收藏
          shares: '55555',//转发
          controller: this.myController,
          auto:true,
          play:true,
          index:0,
        });
      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  // 列表到底部时触发
  private async onReachEnd() {
    if (this.loadingMore) return; // 避免重复加载
    this.loadingMore = true; // 设置为加载中

    await this.loadData(); // 重新加载数据

    this.loadingMore = false; // 重置加载状态
  }

  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }

  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
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
                      .id("image1")


                    Text(item.description)
                      .fontSize(14)
                      .padding({ top: 10, left: 10, bottom: 10 })
                      .fontWeight(FontWeight.Normal)
                      .letterSpacing(2)
                      .lineHeight(20)
                      .maxLines(2)  // 设置最多两行
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignRules({
                        top: { anchor: "image1", align: VerticalAlign.Bottom },
                        left: { anchor: "image1", align: HorizontalAlign.Start }
                      });

                    Text(item.name)
                      .fontSize(12)
                      .letterSpacing(2)
                      .fontColor(Color.Gray)
                      .fontWeight(FontWeight.Normal)
                      .padding({ left: 10, bottom: 10, top: 10 })
                      .alignRules({
                        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      });
                  }
                  .onClick(() => {
                    //点击之后跳转到Videoplay
                    console.log(`视频名称: ${item.description}`);
                    console.log(`地址: ${item.head}`);
                    router.pushUrl({ url: "pages/VideoPlayer", params: { videoDatas: [item] } });
                  })
                  .borderRadius(5)
                  .width('100%')
                  .height(225)
                  .backgroundColor('#ffffff');
                }
                .borderRadius(5)
                .height(225);
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
          // 判断是否切换到“推荐”标签
          if (newIndex === 1) { // 假设“推荐”对应索引为1
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
/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BasicDataSource } from './BasicDataSource';

// Video data structure.
export interface VideoData {
  video: Resource | string;
  name: string;
  description: string;
  time: string;
  controller: VideoController;
  auto: boolean;
  head: Resource;
  likeCount: string;
  commentCount: string;
  favoriteCount: string;
  shareCount: string;
  hotspot: string;
  play: boolean;
  index: number;
}

// A subclass inheriting from BasicDataSource has overridden the methods.
export class TopTabContent extends BasicDataSource {
  private tabContent: string[] = ['关注', '精选', '推荐', '放映厅'];

  // Get the length of the array.
  public totalCount(): number {
    return this.tabContent.length;
  }

  // Retrieve data at the specified index.
  public getData(index: number): string {
    return this.tabContent[index];
  }

  // Change a single piece of data.
  public addData(index: number, data: string): void {
    this.tabContent.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  // Add data.
  public pushData(data: string): void {
    this.tabContent.push(data);
    this.notifyDataAdd(this.tabContent.length - 1);
  }
}


import { BasicDataSource } from './BasicDataSource';
import { VideoData } from './VideoData';

export class MyDataSource extends BasicDataSource{
  private dataArray: Array<VideoData> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): VideoData {
    return this.dataArray[index];
  }

  public addData(index: number, data: VideoData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: VideoData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
  // 你可以增加一个方法来获取全部数据，这样就可以传递整个数组
  public getAllData(): Array<VideoData> {
    return this.dataArray;
  }

  // 更新指定索引的数据
  public updateDataAtIndex(index: number, data: VideoData): void {
    if (index >= 0 && index < this.dataArray.length) {
      this.dataArray[index] = data;  // 更新指定索引的数据
      // this.notifyDataUpdate(index);  // 通知数据源某个索引的数据已经更新
    } else {
      console.error('Index out of bounds');
    }
  }
}

//是封装视频播放显示内容集合

export interface VideoData{
  description:string,//标题
  head:Resource|string,//封面URL
  video:Resource|string,//视频链接
  bvid:string,//BV1xuSnYwEsr
  name:string,//UP主
  face:Resource|string,//UP主头像
  view:string,//播放量
  total:string,//当前观看人数
  like:string,//点赞
  barrage:string,//弹幕
  time:string,//时长
  pubdate:string,//发布时间
  coins: string,//投币
  favorites: string,//收藏
  shares: string,//转发
  controller:VideoController,
  auto:boolean,
  play:boolean,
  index:number,
}

// entry/src/main/ets/services/ApiService.ts

import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 【重要】请务必将此IP和端口替换为您后端服务器的实际地址
const BASE_URL = 'http://10.23.55.31:11111/api';

class ApiService {
  private async request<T>(endpoint: string, options: http.HttpRequestOptions): Promise<T> {
    const url = `${BASE_URL}${endpoint}`;
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        ...options,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000,
        header: {
          'Content-Type': 'application/json',
          ...options.header
        }
      });

      httpRequest.destroy();

      // 支持200 OK和201 Created状态码
      if (response.responseCode === http.ResponseCode.OK || response.responseCode === 201) {
        const result = JSON.parse(response.result as string);
        if (result.code !== 200 && result.code !== 201) {
          throw new Error(result.message || '操作失败');
        }
        return result.data as T;
      } else {
        console.error(`HTTP Error: ${response.responseCode}, Message: ${response.result}`);
        throw new Error(`网络请求失败，错误码: ${response.responseCode}`);
      }
    } catch (err) {
      httpRequest.destroy();
      const businessError = err as BusinessError;
      console.error(`Request failed for ${url}. Error: ${businessError.message}`);
      throw new Error(businessError.message || '未知错误');
    }
  }

  // PC端登录
  login(account: string, password: string): Promise<{ token: string; }> {
    // 【核心修复】将前端的 `account` 变量，映射为后端需要的 `username` 字段
    return this.request('/harmony/login', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ username: account, password: password })
    });
  }

  // 发送验证码
  sendVerificationCode(email: string, type: 'register' | 'bind'): Promise<void> {
    return this.request('/send-verification-code', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ email, type })
    });
  }

  // 用户注册
  register(name: string, email: string, password: string, code: string): Promise<{ message: string; }> {
    // 【修复】后端 registerUser 需要 name, email, password, code 四个字段，这里已经正确
    return this.request('/register', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ name, email, password, code })
    });
  }

  // 用户退出登录方法
  logout(token: string): Promise<void> {
    return this.request('/logout', {
      method: http.RequestMethod.POST,
      header: {
        // 后端 authorize 中间件需要 Authorization 请求头来验证用户身份
        'Authorization': `Bearer ${token}`,
        // 【核心修复】添加 devicetype 请求头，值必须与登录时一致
        'devicetype': 'harmony'
      }
    });
  }

  // 【新增】检查用户登录状态和Token有效性
  async checkStatus(token: string): Promise<{
    success: boolean;
    data?: {
      name: string;
      avatar: string;
      userid: string;
      email: string;
      access: string;
      [key: string]: any;
    };
    message?: string;
  }> {
    const url = `${BASE_URL}/status`;
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'devicetype': 'harmony'
        }
      });

      httpRequest.destroy();

      if (response.responseCode === http.ResponseCode.OK) {
        const result = JSON.parse(response.result as string);
        console.log('Status API 原始响应:', JSON.stringify(result));
        
        if (result.success && result.data) {
          return {
            success: true,
            data: result.data
          };
        } else {
          throw new Error(result.message || '状态检查失败');
        }
      } else {
        console.error(`HTTP Error: ${response.responseCode}, Message: ${response.result}`);
        throw new Error(`网络请求失败，错误码: ${response.responseCode}`);
      }
    } catch (err) {
      httpRequest.destroy();
      const businessError = err as BusinessError;
      console.error(`Request failed for ${url}. Error: ${businessError.message}`);
      return {
        success: false,
        message: businessError.message || '状态检查失败'
      };
    }
  }
}

export const apiService = new ApiService();
// B站服务类 - 处理B站相关的业务逻辑

import { ApiService } from './ApiService';
import { tokenManager } from '../utils/TokenManager';
import { BilibiliVideoInfo, BilibiliAccount } from '../Model/VideoData';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

class BilibiliService {
  private apiService = new ApiService();

  /**
   * 解析B站视频链接，获取基本信息
   * @param context 应用上下文
   * @param input 视频链接或BV号
   * @returns 视频基本信息
   */
  async parseVideo(context: common.UIAbilityContext, input: string): Promise<{
    bvid: string;
    cid: string;
    title: string;
    desc: string;
    type: string;
    play_info: any;
  } | null> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return null;
      }

      const result = await this.apiService.parseVideo(token, input);
      return result;
    } catch (error) {
      console.error('解析视频失败:', error);
      promptAction.showToast({ message: `解析失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 解析B站视频详细信息，包含下载链接
   * @param context 应用上下文
   * @param input 视频链接或BV号
   * @returns 视频详细信息
   */
  async parseVideoDetails(context: common.UIAbilityContext, input: string): Promise<BilibiliVideoInfo | null> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return null;
      }

      const result = await this.apiService.parseVideoDetails(token, input);
      return result;
    } catch (error) {
      console.error('解析视频详情失败:', error);
      promptAction.showToast({ message: `解析失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 获取用户的B站账号列表
   * @param context 应用上下文
   * @returns B站账号列表
   */
  async getBilibiliAccounts(context: common.UIAbilityContext): Promise<BilibiliAccount[]> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return [];
      }

      const accounts = await this.apiService.getBilibiliAccounts(token);
      return accounts;
    } catch (error) {
      console.error('获取B站账号列表失败:', error);
      promptAction.showToast({ message: `获取账号列表失败: ${error.message}` });
      return [];
    }
  }

  /**
   * 提取BVID
   * @param input 用户输入的链接或BV号
   * @returns BVID
   */
  extractBvid(input: string): string | null {
    if (input.includes('bilibili.com/video/')) {
      const match = input.match(/BV[a-zA-Z0-9]+/);
      return match ? match[0] : null;
    } else if (input.startsWith('BV')) {
      return input;
    }
    return null;
  }

  /**
   * 验证输入是否为有效的B站视频链接或BV号
   * @param input 用户输入
   * @returns 是否有效
   */
  isValidBilibiliInput(input: string): boolean {
    if (!input || input.trim() === '') {
      return false;
    }
    
    const trimmedInput = input.trim();
    
    // 检查是否为B站视频链接
    if (trimmedInput.includes('bilibili.com/video/')) {
      return /BV[a-zA-Z0-9]+/.test(trimmedInput);
    }
    
    // 检查是否为BV号
    if (trimmedInput.startsWith('BV')) {
      return /^BV[a-zA-Z0-9]+$/.test(trimmedInput);
    }
    
    return false;
  }

  /**
   * 格式化播放量、点赞数等数字
   * @param num 数字
   * @returns 格式化后的字符串
   */
  formatNumber(num: number): string {
    if (num >= 10000) {
      return (num / 10000).toFixed(1) + '万';
    }
    return num.toString();
  }

  /**
   * 格式化时长
   * @param duration 时长（秒）
   * @returns 格式化后的时长字符串
   */
  formatDuration(duration: number): string {
    const hours = Math.floor(duration / 3600);
    const minutes = Math.floor((duration % 3600) / 60);
    const seconds = duration % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  /**
   * 格式化发布时间
   * @param timestamp 时间戳
   * @returns 格式化后的时间字符串
   */
  formatPublishTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor(diff / (1000 * 60));
    
    if (days > 0) {
      return `${days}天前`;
    } else if (hours > 0) {
      return `${hours}小时前`;
    } else if (minutes > 0) {
      return `${minutes}分钟前`;
    } else {
      return '刚刚';
    }
  }
}

export const bilibiliService = new BilibiliService();
import { CommonConstants as Const } from '../common/CommonConstants';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
// import { Param } from '@ohos/hypium';
import { router,curves } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { xmapi } from '../api/xmapi'; // 确保路径正确
import { Side,VideoDes } from '../view/Side';
import { TopTabContent } from '../Model/DataModel';
let videoIndex: number = 0;

@Entry
@Component
export struct VideoPlayer {
  private swiperController: SwiperController = new SwiperController();
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State playBoo:boolean=true;
  @State localonline:boolean=true;
  @State index:number =0;
  @State totalindex:string = '111';
  @State currentIndex: number = 1;
  @State mp4:string='';
  scroller: Scroller = new Scroller();
  private topTabListData: TopTabContent = new TopTabContent();

  controller: webview.WebviewController = new webview.WebviewController();
  videoDatas: Array<VideoData> = [
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      // video:$rawfile('aaaaaaaaaaa.mp4'),//视频链接
      bvid:'BV1kpSmYTEoy',
      name: '@登山爱好者', //UP主
      face:'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
      view: '114514', //播放量
      total:'114514',
      like:'1111',//点赞
      barrage: '114514', //弹幕数
      time: '511', //时长
      pubdate:'5555',
      coins: '5555',//投币
      favorites: '5555',//收藏
      shares: '5555',//转发
      controller: this.myController,
      auto:false,
      play:false,
      index:0,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: 'http://i2.hdslb.com/bfs/archive/c4603188a8d0caa468649820dbd5750612095236.jpg', //封面URL
      // video:'http://10.23.55.31:7894/BV1m1sue8EQc.mp4',//视频链接
      video:'http://10.23.55.31:7894/BV1scmfYPES3.mp4',//视频链接
      bvid:'BV1xuSnYwEsr',
      name: '画渣花小烙', //UP主
      face:'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
      view: '114514', //播放量
      total:'114514',
      like:'1111',//点赞
      barrage: '114514', //弹幕数
      time: '511', //时长
      pubdate:'5555',
      coins: '5555',//投币
      favorites: '5555',//收藏
      shares: '5555',//转发
      controller: this.myController,
      auto:false,
      play:false,
      index:1,
    },
  ];

  async aboutToAppear() {
    let blibliurl=''; // 替换成实际的 SESSDATA
    // let mp4='';
    let itemss=[];
    let bvidflag='';
    // //把数组VideoDatas中的元素加载进datas对象中
    // for (let index = 0; index < this.videoDatas.length; index++) {
    //   this.datas.pushData(this.videoDatas[index]);
    // }



    const params: object = router.getParams();
    console.info(JSON.stringify(params));
    console.info(JSON.stringify(params["videoDatas"]));
    console.info(JSON.stringify(params["bvidflag"]));
    // console.info(JSON.stringify(params["videoDatas"][0]["description"]));

    // blibliurl=params["videoDatas"][0]["video"]
    // blibliurl='https://www.bilibili.com/video/BV1yRS3YqETN';
    blibliurl = `https://www.bilibili.com/video/${params["bvidflag"]}`;

    console.info('地址获取'+blibliurl)



    if(params["videoDatas"].length==1){

      //把数组VideoDatas中的元素加载进datas对象中
      for (let index = 0; index < this.videoDatas.length; index++) {
        this.datas.pushData(this.videoDatas[index]);
      }







      this.localonline=true
      console.log('在线解析模式')
      blibliurl=params["videoDatas"][0]["video"]
      // blibliurl='https://www.bilibili.com/video/BV1u54y1W7ga';
      this.mp4 = `http://10.23.55.31:7894/${params["videoDatas"][0]["bvid"]}.mp4`;
      let items: Array<string> = params["videoDatas"];
      const item = items[0];


      this.datas.pushData({
        description: item["description"], // 标题
        head: item["head"], // 封面URL
        video: this.mp4, // 视频链接
        bvid: item["bvid"],
        name: item["name"], // UP主
        face: item["face"],
        view:  item["view"], // 播放量
        total:'55555', //当前观看人数
        like: item["like"],
        barrage:item["barrage"], // 弹幕数
        time: item["time"], // 时长
        pubdate: item["pubdate"],
        coins:'55555', //投币
        favorites: '55555', //收藏
        shares:'55555', //转发
        controller: this.myController,
        auto: false,
        play: false,
        index: 2,
      });

      const response = await xmapi(blibliurl);
      if (response) {
        console.info(JSON.stringify(response));
        this.mp4=response["downloadLink"]
        itemss = response["data"];
        console.info(JSON.stringify(response["downloadLink"]));
        console.info('播放量',JSON.stringify(response["data"]["current_viewers"]));
      } else {
        this.mp4 = `http://10.23.55.31:7894/${params["videoDatas"][0]["bvid"]}.mp4`;
        console.error('请求失败',this.mp4);
      }
      const updatedData: VideoData={
          description: item["description"], // 标题
          head: item["pic"], // 封面URL
          video: this.mp4, // 视频链接
          bvid: item["bvid"],
          name: item["name"], // UP主
          face: item["face"],
          view: itemss["view"], // 播放量
          total: itemss["current_viewers"]??5, //当前观看人数
          like: item["like"],
          barrage: itemss["danmaku"], // 弹幕数
          time: item["time"], // 时长
          pubdate: itemss["pubdate"],
          coins: itemss["coin"], //投币
          favorites: itemss["favorite"], //收藏
          shares:itemss["share"], //转发
          controller: this.myController,
          auto: false,
          play: false,
          index: 2,
        }
      this.datas.updateDataAtIndex(2, updatedData);
    }else{
      this.localonline=false
      console.log('缓存加载模式')

      xmapi(blibliurl);
      let items: Array<string> = params["videoDatas"];

      // 判断是否需要将视频数据根据 bvidflag 排序
      if (params["bvidflag"]) {
         bvidflag = params["bvidflag"];
        // 查找 bvidflag 对应的视频项并移到数组的最前面
        const index = items.findIndex(item => item["bvid"] === bvidflag);

        if (index !== -1) {
          // 将目标视频项移到最前面
          const targetItem = items.splice(index, 1)[0];
          items.unshift(targetItem);
        }
      }

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        this.datas.pushData({
          description: item["description"], // 标题
          head: item["head"], // 封面URL
          video: item["video"], // 视频链接
          bvid: item["bvid"],
          name: item["name"], // UP主
          face: item["face"],
          view: item["view"], // 播放量
          total: item["total"]??5, //当前观看人数
          like: item["like"],
          barrage: item["barrage"], // 弹幕数
          time: item["time"], // 时长
          pubdate: item["pubdate"],
          coins: item["coins"], //投币
          favorites: item["favorites"], //收藏
          shares: item["shares"], //转发
          controller: this.myController,
          auto: false,
          play: false,
          index: i,
        });



        const updatedData: VideoData={
          description: item["description"], // 标题
          head: item["head"], // 封面URL
          video: item["video"], // 视频链接
          bvid: item["bvid"],
          name: item["name"], // UP主
          face: item["face"],
          view: item["view"], // 播放量
          total: item["total"]??5, //当前观看人数
          like: item["like"],
          barrage: item["barrage"], // 弹幕数
          time: item["time"], // 时长
          pubdate: item["pubdate"],
          coins: item["coins"], //投币
          favorites: item["favorites"], //收藏
          shares: item["shares"], //转发
          controller: this.myController,
          auto: false,
          play: false,
          index: i,
        }
        this.datas.updateDataAtIndex(i, updatedData);


      }
    }





  }
  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }
  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
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

                      item.controller.start();
                    })
                    .onStart(() => {
                      item.play = true;
                      this.playBoo = this.datas.getData(this.index).play;
                    })
                    .onPause(() => {
                      item.play = false;
                      this.playBoo = this.datas.getData(this.index).play;
                    })
                    .onClick(() => {
                      if (item.play) {
                        item.controller.pause();
                      } else {
                        item.controller.start();
                      }
                    })
                    .onVisibleAreaChange([0.0, 1.0], (isVisisble: boolean, currentRatio: number) => {
                      if (isVisisble && currentRatio >= 1.0) {
                        item.controller.start();
                        this.totalindex=item.total;
                      }
                    })
                  Side({
                    likeCount: String(item.like), // 点赞数,独特特性（bug！）
                    commentCount: String(item.barrage), // 评论数 目前是弹幕
                    favoriteCount: String(item.favorites), // 收藏数
                    shareCount: String(item.shares), // 分享数
                    toubiCount: String(item.coins),

                    index: item.index // 索引
                  })
                }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))

                VideoDes({
                  head: item.face,
                  name: item.name,
                  description: item.description,
                  hotspot: item.pubdate,
                  time: item.time,
                  viewCount:item.view,
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
                    item.controller.start();
                    item.play = true;
                    this.playBoo = true;
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
        .onChange((index) => {
          this.index = index;
          this.playBoo = true;
          videoIndex = index;
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

import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import { xmapis } from '../api/xmapis'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';



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
export struct Dynamic {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State index: number = 0;
  @State apiResponse: object = []; // 存储原始 API 响应
  @State loadingMore: boolean = false; // 用于指示是否正在加载更多数据
  @State bottomTabIndex: number = 1;
  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  async aboutToAppear() {
    await this.loadData(); // 加载初始数据
  }

  // 加载数据的公共方法
  private async loadData() {
    const response = await xmapis();
    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      console.error('请求失败');
    }
  }

  private parseApiResponse(response: object) {
    console.info(JSON.stringify(response));
    if ((response["message"] === "成功获取视频列表" || response["message"] ==='成功获取视频列表') && response["data"]) {
      const items:Array<string> = response["data"];

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        this.datas.pushData({
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["download_link"], // 视频链接
          bvid:item["bvid"],//地址
          name: item['name'], // UP主
          face:item['face'],//头像
          view: item["view"], // 播放量
          total:item["current_viewers"]?? 5,//当前观看人数
          like:item["like"],//点赞
          barrage: item["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          pubdate:item["pubdate"],//发布时间
          coins: item["coin"],//投币
          favorites: item["favorite"],//收藏
          shares: item["share"],//转发
          controller: this.myController,
          auto:true,
          play:true,
          index:i,
        });

        const updatedData: VideoData={
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["download_link"], // 视频链接
          bvid:item["bvid"],//地址
          name: item['name'], // UP主
          face:item['face'],//头像
          view: item["view"], // 播放量
          total:item["current_viewers"]?? 5,//当前观看人数
          like:item["like"],//点赞
          barrage: item["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          pubdate:item["pubdate"],//发布时间
          coins: item["coin"],//投币
          favorites: item["favorite"],//收藏
          shares: item["share"],//转发
          controller: this.myController,
          auto:true,
          play:true,
          index:i,
        }
        this.datas.updateDataAtIndex(i, updatedData);

      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  // 列表到底部时触发
  private async onReachEnd() {
    if (this.loadingMore) return; // 避免重复加载
    this.loadingMore = true; // 设置为加载中

    await this.loadData(); // 重新加载数据

    this.loadingMore = false; // 重置加载状态
  }

  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }

  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Scroll() {
      Column() {
        Text("数据库缓存视频")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center);
        Tabs({ barPosition: BarPosition.Start ,index: this.bottomTabIndex}) {

          TabContent() {
          }.tabBar("直播");
          TabContent() {
            List({ space: 5 }) {
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
                      .id("image1")


                    Text(item.description)
                      .fontSize(14)
                      .padding({ top: 10, left: 10, bottom: 10 })
                      .fontWeight(FontWeight.Normal)
                      .letterSpacing(2)
                      .lineHeight(20)
                      .maxLines(2)  // 设置最多两行
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignRules({
                        top: { anchor: "image1", align: VerticalAlign.Bottom },
                        left: { anchor: "image1", align: HorizontalAlign.Start }
                      });

                    Text(item.name)
                      .fontSize(12)
                      .letterSpacing(2)
                      .fontColor(Color.Gray)
                      .fontWeight(FontWeight.Normal)
                      .padding({ left: 10, bottom: 10, top: 10 })
                      .alignRules({
                        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      });
                  }
                  .onClick(() => {
                    this.loadData();
                    //点击之后跳转到Videoplay
                    console.log(`视频名称: ${item.description}`);
                    console.log(`地址: ${item.head}`);
                    router.pushUrl({ url: "pages/VideoPlayer", params: { videoDatas:this.datas.getAllData(),bvidflag:item.bvid  } });
                  })
                  .borderRadius(5)
                  .width('100%')
                  .height(225)
                  .backgroundColor('#ffffff');
                }
                .borderRadius(5)
                .height(225);
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
          }.tabBar("推荐");

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
