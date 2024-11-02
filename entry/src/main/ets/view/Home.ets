import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';

@Entry
@Component
export struct Home {
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State index:number =0;
  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  videoDatas:Array<VideoData> =[
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },
    {
      description:'总得来看看雪山吧',//标题
      head:$r('app.media.photo35'),//封面URL
      video:$rawfile('short_video2.mp4'),//视频链接
      name:'@登山爱好者',//UP主
      view:'114514',//播放量
      barrage:'114514',//弹幕数
      time:'511',//时长
      controller:this.myController,
    },

  ]

  aboutToAppear(): void {
    //把数组VideoDatas中的元素加载进datas对象中
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
    Scroll() {
      Column() {
        Text("Scroll Area")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center)
        Tabs({ barPosition: BarPosition.Start }) {
          TabContent() {
            List({ space: 5 },) {
              LazyForEach(this.datas, (item: VideoData, index: number) => {
                ListItem() {
                  RelativeContainer() {
                    Image(item.head)
                      .width('100%')
                      .aspectRatio(0)// 为1使封面图片为正方形
                      .objectFit(ImageFit.Cover)
                      .alignRules({
                        top: { anchor: "__container__", align: VerticalAlign.Top },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      })
                      .id("image1")
                      .onClick(() => {
                        // 点击封面时触发播放或跳转事件
                        console.log(`Clicked on video: ${item.name}`);
                      });

                      Text(item.description)
                        .fontSize(14)
                        .padding({ top: 10,left:10,bottom:10})
                        .fontWeight(FontWeight.Normal)
                        .letterSpacing(2)
                        .lineHeight(20)
                        .alignRules({
                          top: { anchor: "image1", align: VerticalAlign.Bottom },
                          left: { anchor: "image1", align: HorizontalAlign.Start }
                        })


                      Text(item.name)
                        .fontSize(12)
                        .letterSpacing(2)
                        .fontColor(Color.Gray)
                        .fontWeight(FontWeight.Normal)
                        .padding({left:10,bottom:10,top:10})
                        .alignRules({
                          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                          left: { anchor: "__container__", align: HorizontalAlign.Start }
                        })
                  }
                  .borderRadius(5)
                  .width('100%')
                  .height(225)
                  .backgroundColor('#ffffff') // 可选：背景颜色

                }
                .borderRadius(5)
                .height(225)
              });
            }

            .cachedCount(6)
            .lanes(2,5)
            .width("100%")
            .edgeEffect(EdgeEffect.Spring)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }.tabBar("Tab1")

          TabContent() {
          }.tabBar("Tab2")
        }
        .padding({left:5,right:5})
        .vertical(false)
        .height("100%")
      }.width("100%")
    }
    .edgeEffect(EdgeEffect.Spring)
    .friction(0.6)
    .backgroundColor('#DCDCDC')
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }



}