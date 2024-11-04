import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
// import { Param } from '@ohos/hypium';
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { xmapi } from '../api/xmapi'; // 确保路径正确
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
      video:$rawfile('short_video2.mp4'),//视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: 'http://i2.hdslb.com/bfs/archive/c4603188a8d0caa468649820dbd5750612095236.jpg', //封面URL
      video:'http://10.3.36.9:4567/download/bbb.mp4',//视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
    },
    {
      description: '总得来看看雪山吧', //标题
      head: $r('app.media.photo35'), //封面URL
      // video:'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4',//视频链接
      // video:'https://act-webstatic.mihoyo.com/puzzle/hk4e/pz_YvJfNJEi5F/resource/puzzle/2024/09/23/94927edf50261e3c1146f0d44db68b3f_8829009084590888673.mp4',//视频链接
      // video:'https://webstatic.mihoyo.com/upload/op-public/2020/09/27/fd431739ff26ceeb3010ac561d68446b_345688670889091949.mp4',//视频链接
      // video:'http://10.3.36.9:4567/download/bbb.mp4',//视频链接
      video:'http://10.3.36.9:7894/BV1kpSmYTEoy.mp4',//视频链接
      // video:'http://127.0.0.1:7894/fd431739ff26ceeb3010ac561d68446b_345688670889091949.mp4',//视频链接
      name: '@登山爱好者', //UP主
      view: '114514', //播放量
      barrage: '114514', //弹幕数
      time: '511', //时长
      controller: this.myController,
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

    // blibliurl=params["videoDatas"][0]["videom4s"]
    blibliurl='https://www.bilibili.com/video/BV1kpSmYTEoy';
    console.info('地址获取'+blibliurl)
    const response = await xmapi(blibliurl);
    if (response) {
      console.info(JSON.stringify(response));
      mp4=response["downloadLink"]
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
      // Video({
      //   src:'http://10.3.36.9:4567/download/BV1kpSmYTEoy.mp4',
      //   controller:this.myController
      // })
      //   .objectFit(ImageFit.Contain)
      //   .autoPlay(true)

      Swiper(){
        LazyForEach(this.datas,(item:VideoData,index:number)=>{
          //加载元素
          // VideoController(){
          //
          //
          // }


          // Text(item.videom4s+'\r\n'+item.videom4a)

          Video({
            src: item.video,
            controller: this.myController, // 同样使用同一个控制器
            previewUri:item.head,
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