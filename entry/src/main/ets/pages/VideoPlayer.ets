import { CommonConstants as Const } from '../common/CommonConstants';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData, BilibiliVideoInfo } from '../Model/VideoData';
import { router, curves } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { bilibiliService } from '../api/BilibiliService';
import { Side, VideoDes } from '../view/Side';
import { TopTabContent } from '../Model/DataModel';
import { common } from '@kit.AbilityKit';
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
      index: '0',
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
      index: '1',
    },
  ];

  async aboutToAppear() {
    const params = router.getParams() as Record<string, ESObject>;
    console.info('VideoPlayer params:', JSON.stringify(params));
    
    // 检查是否来自解析页面
    this.fromParse = params["fromParse"] || false;
    
    if (params["videoDatas"] && params["videoDatas"].length > 0) {
      // 如果来自解析页面，直接使用传入的数据
      if (this.fromParse) {
        const videoData = (params["videoDatas"] as VideoData[])[0];
        this.datas.pushData(videoData);
        console.log('使用解析页面传入的视频数据');
      } else {
        // 传统模式：需要重新解析视频
        await this.parseVideoFromParams(params);
      }
    } else {
      // 加载默认视频数据
      this.loadDefaultVideos();
    }
  }

  // 从参数解析视频
  private async parseVideoFromParams(params: Record<string, ESObject>) {
    this.isLoading = true;
    
    try {
      const bvidflag = params["bvidflag"] as string;
      if (bvidflag) {
        const blibliurl = `https://www.bilibili.com/video/${bvidflag}`;
        console.info('开始解析视频:', blibliurl);
        
        const result = await bilibiliService.parseVideoDetails(this.context, blibliurl);
        if (result) {
          const videoData: VideoData = {
            description: result.title,
            head: result.pic,
            video: result.videoUrl,
            audioUrl: result.audioUrl,
            bvid: result.bvid,
            aid: String(result.aid),
            cid: String(result.cid),
            name: result.name,
            face: result.face,
            view: String(result.view),
            like: String(result.like),
            barrage: String(result.danmaku),
            time: String(result.duration),
            pubdate: String(result.pubdate),
            coins: String(result.coin),
            favorites: String(result.favorite),
            shares: String(result.share),
            reply: String(result.reply),
            tname: result.tname,
            controller: this.myController,
            auto: false,
            play: false,
            index: '0'
          };
          
          this.datas.pushData(videoData);
          console.log('视频解析成功');
        } else {
          console.error('视频解析失败');
          this.loadDefaultVideos();
        }
      } else {
        this.loadDefaultVideos();
      }
    } catch (error) {
      console.error('解析视频时出错:', error);
      this.loadDefaultVideos();
    } finally {
      this.isLoading = false;
    }
  }

  // 加载默认视频
  private loadDefaultVideos() {
    // 把默认视频数据加载进datas对象中
    for (let index = 0; index < this.videoDatas.length; index++) {
      this.datas.pushData(this.videoDatas[index]);
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
                        this.totalindex = String(item.total || '0');
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

