import { CommonConstants as Const } from '../common/CommonConstants';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
// import { Param } from '@ohos/hypium';
import { router,curves } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { xmapi } from '../api/xmapi'; // 确保路径正确
import { Side,VideoDes } from '../view/Side';
let videoIndex: number = 0;
@Entry
@Component
export struct VideoPlayer {
  private swiperController: SwiperController = new SwiperController();
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State playBoo:boolean=true;
  @State index:number =0;
  controller: webview.WebviewController = new webview.WebviewController();
  videoDatas: Array<VideoData> = [
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
      auto:false,
      play:false,
      index:0,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: 'http://i2.hdslb.com/bfs/archive/c4603188a8d0caa468649820dbd5750612095236.jpg', //封面URL
      // video:'http://10.3.36.9:4567/download/bbb.mp4',//视频链接
      video:'https://v95-sz-web-prime.douyinvod.com/video/tos/cn/tos-cn-ve-15/oUdV7SNDnBJrFa2FEw3NdAIeAAJlfJEg99EbMD/?a=6383&ch=5&cr=3&dr=0&lr=all&cd=0%7C0%7C0%7C3&cv=1&br=1211&bt=1211&cs=0&ds=4&ft=p96FM4q1ffPdXP~ka1jNvAq-antLjrK1Ig6NRkaCBLj0vjVhWL6&mime_type=video_mp4&qs=0&rc=ZDs4NjhnO2g1PDo8NmhlO0Bpajg6aW85cmpndjMzNGkzM0BiNF8uNF5eNWIxYmBiNDBhYSNiYDZzMmRzXmZgLS1kLWFzcw%3D%3D&btag=c0000e00038000&cquery=100K_100o_101s_100B_100H&dy_q=1730790907&expire=1730802902&feature_id=46a7bb47b4fd1280f3d3825bf2b29388&l=20241105151505948EE022E7460F1612F1&ply_type=4&policy=4&signature=12bf55e11e94f30a0ecdf51b652d82f3&tk=webid&webid=c3109cf8eab4507640f022360c5ce002c7035d0857c7085fdeb180d1661fca19de6b29f95bc6166944f81fcf58146e1349cbf7c80c704d27eecf1fc8faf3b59afd7400d7c6a45f284e1bcbc11eaf9a927cd6fa4d5966a807e47cc95b00db3ca3010cdd9f87fd4770feb652067b9179f7511e54347023802a2f303aadd509a01e9701a3ad060be775cbb300a986e9ece9aef3bbfd7a29be167b79d1b854c6b4ed-7a819e33ffa5fc9a620b2874b780dd16&fid=37f6907581dc557ca4e111a2336680ee',//视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
      auto:false,
      play:false,
      index:1,
    },
  ];

  async aboutToAppear() {
    let blibliurl=''; // 替换成实际的 SESSDATA
    let mp4='';
    //把数组VideoDatas中的元素加载进datas对象中
    for (let index = 0; index < this.videoDatas.length; index++) {
      this.datas.pushData(this.videoDatas[index]);
    }
    const params: object = router.getParams();
    console.info(JSON.stringify(params));
    console.info(JSON.stringify(params["videoDatas"]));
    console.info(JSON.stringify(params["videoDatas"][0]["description"]));

    // blibliurl=params["videoDatas"][0]["video"]
    blibliurl='https://www.bilibili.com/video/BV1kpSmYTEoy';
    console.info('地址获取'+blibliurl)
    const response = await xmapi(blibliurl);
    if (response) {
      console.info(JSON.stringify(response));
      mp4=response["downloadLink"]
      console.info(JSON.stringify(response["downloadLink"]));
    } else {
      console.error('请求失败');
    }
    const items: Array<string> = params["videoDatas"];
    const item = items[0];
    console.info(item["description"]);
    console.info(item["head"]);
    console.info(item["video"]);
    console.info(item["name"]);
    console.info(item["view"]);
    console.info(item["barrage"]);
    console.info(item["time"]);
    this.datas.pushData({
      description: item["description"], // 标题
      head: item["head"], // 封面URL
      video:mp4, // 视频链接
      name: item["name"], // UP主
      view: item["view"], // 播放量
      barrage: item["barrage"], // 弹幕数
      time: item["time"], // 时长
      controller: this.myController,
      auto:false,
      play:false,
      index:2,
    });
  }
  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }
  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Column(){
      Swiper(this.swiperController){
        LazyForEach(this.datas,(item:VideoData,index:number)=>{
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
                    }
                  })
                Side({
                  likeCount: '111', // 点赞数
                  commentCount: '111', // 评论数
                  favoriteCount: '111', // 收藏数
                  shareCount: '111', // 分享数
                  index: item.index // 索引

                })
              }.width(Const.FULL_SIZE).height(Const.FULL_SIZE).padding($r('app.integer.stack_padding'))

              VideoDes({ name: item.name, description: item.description, hotspot: '2024年11月5日17点17分', time: item.time })
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
        },(item:VideoData)=>JSON.stringify(item))
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

  }
}

