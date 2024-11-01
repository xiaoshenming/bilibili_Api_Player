
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
      video:$rawfile('short_video1.mp4'),
      name:'@山猫',
      description:'海的那边，是.....',
      time:'2024-01-24 12:32',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'1234',
      commentCount:'1122',
      favoriteCount:'445',
      shareount:'3321',
      hotsport:'海',
      play:true,
      index:0
    },
    {
      video:$rawfile('short_video2.mp4'),
      name:'@登山爱好者',
      description:'#雪山',
      time:'2022-04-24 12:12',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'1884',
      commentCount:'1542',
      favoriteCount:'4545',
      shareount:'861',
      hotsport:'雪的距离',
      play:true,
      index:1
    },
    {
      video:$rawfile('short_video3.mp4'),
      name:'@平平淡淡',
      description:'生活不只是眼前的苟且，还有诗和远方',
      time:'2023-08-20 10:45',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'777',
      commentCount:'4576',
      favoriteCount:'8896',
      shareount:'1112',
      hotsport:'日出',
      play:true,
      index:2
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