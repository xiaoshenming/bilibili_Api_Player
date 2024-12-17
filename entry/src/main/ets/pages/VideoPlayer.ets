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
      // video:'http://10.3.36.10:7894/BV1m1sue8EQc.mp4',//视频链接
      video:'http://10.3.36.10:7894/BV1scmfYPES3.mp4',//视频链接
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
      this.mp4 = `http://10.3.36.10:7894/${params["videoDatas"][0]["bvid"]}.mp4`;
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
        this.mp4 = `http://10.3.36.10:7894/${params["videoDatas"][0]["bvid"]}.mp4`;
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

