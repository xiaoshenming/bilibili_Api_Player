import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
// import { Param } from '@ohos/hypium';
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
@Entry
@Component
export struct VideoPlayer {
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State index:number =0;
  controller: webview.WebviewController = new webview.WebviewController();
  videoDatas: Array<VideoData> = [
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video: $rawfile('short_video2.mp4'), //视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video: 'http://10.3.36.9:4567/download/5b56fb85b44d46f99034cda0da35c025.mp4', //视频链接
      // video: 'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4', //视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video: 'https://upos-hz-mirrorakam.akamaized.net/upgcxcode/59/58/1387295859/1387295859-1-30080.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfq9rVEuxTEnE8L5F6VnEsSTx0vkX8fqJeYTj_lta53NCM=&uipk=5&nbs=1&deadline=1730672492&gen=playurlv2&os=akam&oi=794498420&trid=e12da668470043518da4d6bc8a801ed9T&mid=2102334115&platform=html5&og=08&upsig=6698037905cc5d96cf99a2daaa8593f2&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&hdnts=exp=1730665292~hmac=56393159702e1a1b3c85692985a76f43fe5274844e049226742f5d8fb981a505&bvc=vod&nettype=0&bw=331036&orderid=0,2&buvid=&build=0&mobi_app=&f=T_0_0&logo=80000000', //视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      video: 'https://upos-hz-mirrorakam.akamaized.net/upgcxcode/59/58/1387295859/1387295859-1-30232.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfq9rVEuxTEnE8L5F6VnEsSTx0vkX8fqJeYTj_lta53NCM=&uipk=5&nbs=1&deadline=1730672492&gen=playurlv2&os=akam&oi=794498420&trid=e12da668470043518da4d6bc8a801ed9T&mid=2102334115&platform=html5&og=cos&upsig=436d0da7dc5b44ff83dab5429e7cdc28&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&hdnts=exp=1730665292~hmac=9a4c1f26969bbf6b0bcb7514f5ce7f7b659cc5abf10391eb5e873c6b05f1ffe1&bvc=vod&nettype=0&bw=12331&orderid=0,2&buvid=&build=0&mobi_app=&f=T_0_0&logo=80000000', //视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
  ];

  // videoDatas:Array<VideoData> =[];

  // 接收传递过来的参数
  // @Param videoData: VideoData;
  aboutToAppear(): void {
    //把数组VideoDatas中的元素加载进datas对象中
    for (let index = 0; index < this.videoDatas.length; index++) {
      this.datas.pushData(this.videoDatas[index]);
    }
    const params: object = router.getParams();
    console.info(JSON.stringify(params));
    console.info(JSON.stringify(params["videoDatas"]));
    console.info(JSON.stringify(params["videoDatas"][0]["description"]));

    const items: Array<string> = params["videoDatas"];

    for (let i = 0; i < items.length; i++) {
      const item = items[i];
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
        video: item["video"], // 视频链接
        name: item["name"], // UP主
        view: item["view"], // 播放量
        barrage: item["barrage"], // 弹幕数
        time: item["time"], // 时长
        controller: this.myController,
      });
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
            src: item.video,
            controller: item.controller
          })
            .autoPlay(true)
            .objectFit(ImageFit.Contain)
          // if (item.video.toString().startsWith("https") && !item.video.toString().endsWith(".mp4")) {
          //   Web({ src: item.video, controller: this.controller })
          //     .enableNativeMediaPlayer({ enable: true, shouldOverlay: false })
          // } else {
          //   Video({
          //     src: item.video,
          //     controller: item.controller
          //   })
          //     .autoPlay(true)
          //     .objectFit(ImageFit.Contain)
          // }
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


//
// import { it } from '@ohos/hypium';
// import { MyDataSource } from '../Model/MyDataSource';
// import { VideoData } from '../Model/VideoData';
//
// @Entry
// @Component
// export struct VideoPlayer {
//   private myController:VideoController =new VideoController();
//   private datas:MyDataSource =new MyDataSource();
//   @State index:number =0;
//   videoDatas:Array<VideoData> =[
//     {
//       description:'总得来看看雪山吧',//标题
//       head:$r('app.media.photo35'),//封面URL
//       video:$rawfile('short_video2.mp4'),//视频链接
//       name:'@登山爱好者',//UP主
//       view:'114514',//播放量
//       barrage:'114514',//弹幕数
//       time:'511',//时长
//       controller:this.myController,
//     },
//     {
//       description:'总得来看看雪山吧',//标题
//       head:$r('app.media.photo35'),//封面URL
//       video:$rawfile('short_video2.mp4'),//视频链接
//       name:'@登山爱好者',//UP主
//       view:'114514',//播放量
//       barrage:'114514',//弹幕数
//       time:'511',//时长
//       controller:this.myController,
//     },
//     {
//       description:'总得来看看雪山吧',//标题
//       head:$r('app.media.photo35'),//封面URL
//       // video:$rawfile('short_video2.mp4'),//视频链接
//       video:'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4',//视频链接
//       name:'@登山爱好者',//UP主
//       view:'114514',//播放量
//       barrage:'114514',//弹幕数
//       time:'511',//时长
//       controller:this.myController,
//     },
//   ];
//   aboutToAppear(): void {
//     //把数组VideoDatas中的元素加载进datas对象中
//     for (let index = 0; index < this.videoDatas.length; index++) {
//       this.datas.pushData(this.videoDatas[index]);
//     }
//   }
//   onPageShow(): void {
//     this.datas.getData(this.index).controller.start();
//   }
//   onPageHide(): void {
//     this.datas.getData(this.index).controller.pause();
//   }
//
//   build() {
//     Column(){
//       // Video({
//       //   src:'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4',
//       //   controller:this.myController
//       // })
//       //   .objectFit(ImageFit.Contain)
//       //   .autoPlay(true)
//
//       Swiper(){
//
//
//
//         LazyForEach(this.datas,(item:VideoData,index:number)=>{
//           //加载元素
//           Video({
//             src:item.video,
//             controller:item.controller
//           })
//             .autoPlay(true)
//             .objectFit(ImageFit.Contain)
//
//         },(item:VideoData)=>JSON.stringify(item))
//       }
//       .width('100%')
//       .height('100%')
//       .vertical(true)
//
//     }
//     .width('100%')
//     .height('100%')
//   }
// }