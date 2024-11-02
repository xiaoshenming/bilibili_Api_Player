
import { it } from '@ohos/hypium';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';

// @Entry
@Component
export struct VideoPlayer {
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State index:number =0;
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
  ];
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
    Column(){
      // Video({
      //   src:'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4',
      //   controller:this.myController
      // })
      //   .objectFit(ImageFit.Contain)
      //   .autoPlay(true)

      Swiper(){



        LazyForEach(this.datas,(item:VideoData,index:number)=>{
          //加载元素
          Video({
            src:item.video,
            controller:item.controller
          })
            .autoPlay(true)
            .objectFit(ImageFit.Contain)

        },(item:VideoData)=>JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .vertical(true)

    }
    .width('100%')
    .height('100%')
  }
}