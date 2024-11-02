//是封装视频播放显示内容集合
// export interface VideoData{
//   video:Resource|string,
//   name:string,
//   description:string,
//   time:string,
//   controller:VideoController,
//   auto:boolean,
//   head:Resource,
//   likeCount:string,
//   commentCount:string,
//   favoriteCount:string,
//   shareount:string,
//   hotsport:string,
//   play:boolean,
//   index:number
// }

export interface VideoData{
  description:string,//标题
  head:Resource|string,//封面URL
  video:Resource|string,//视频链接
  name:string,//UP主
  view:string,//播放量
  barrage:string,//弹幕
  time:string,//时长
  controller:VideoController,
}


// videoDatas:Array<VideoData> =[
//
//   {
//     video:$rawfile('short_video2.mp4'),
//     name:'@登山爱好者',
//     description:'#雪山',
//     time:'2022-04-24 12:12',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo35'),
//     likeCount:'1884',
//     commentCount:'1542',
//     favoriteCount:'4545',
//     shareount:'861',
//     hotsport:'雪的距离',
//     play:true,
//     index:1
//   },
//   {
//     video:$rawfile('short_video3.mp4'),
//     name:'@平平淡淡',
//     description:'生活不只是眼前的苟且，还有诗和远方',
//     time:'2023-08-20 10:45',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo37'),
//     likeCount:'777',
//     commentCount:'4576',
//     favoriteCount:'8896',
//     shareount:'1112',
//     hotsport:'日出',
//     play:true,
//     index:2
//   },
//   {
//     video:$rawfile('short_video1.mp4'),
//     name:'@山猫',
//     description:'海的那边，是.....',
//     time:'2024-01-24 12:32',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo33'),
//     likeCount:'1234',
//     commentCount:'1122',
//     favoriteCount:'445',
//     shareount:'3321',
//     hotsport:'海',
//     play:true,
//     index:3
//   },
//   {
//     video:$rawfile('short_video2.mp4'),
//     name:'@登山爱好者',
//     description:'#雪山',
//     time:'2022-04-24 12:12',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo35'),
//     likeCount:'1884',
//     commentCount:'1542',
//     favoriteCount:'4545',
//     shareount:'861',
//     hotsport:'雪的距离',
//     play:true,
//     index:4
//   },
//   {
//     video:$rawfile('short_video3.mp4'),
//     name:'@平平淡淡',
//     description:'生活不只是眼前的苟且，还有诗和远方',
//     time:'2023-08-20 10:45',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo37'),
//     likeCount:'777',
//     commentCount:'4576',
//     favoriteCount:'8896',
//     shareount:'1112',
//     hotsport:'日出',
//     play:true,
//     index:5
//   },
//   {
//     video:$rawfile('short_video1.mp4'),
//     name:'@山猫',
//     description:'海的那边，是.....',
//     time:'2024-01-24 12:32',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo33'),
//     likeCount:'1234',
//     commentCount:'1122',
//     favoriteCount:'445',
//     shareount:'3321',
//     hotsport:'海',
//     play:true,
//     index:6
//   },
//   {
//     video:$rawfile('short_video2.mp4'),
//     name:'@登山爱好者',
//     description:'#雪山',
//     time:'2022-04-24 12:12',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo35'),
//     likeCount:'1884',
//     commentCount:'1542',
//     favoriteCount:'4545',
//     shareount:'861',
//     hotsport:'雪的距离',
//     play:true,
//     index:7
//   },
//   {
//     video:$rawfile('short_video3.mp4'),
//     name:'@平平淡淡',
//     description:'生活不只是眼前的苟且，还有诗和远方',
//     time:'2023-08-20 10:45',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo37'),
//     likeCount:'777',
//     commentCount:'4576',
//     favoriteCount:'8896',
//     shareount:'1112',
//     hotsport:'日出',
//     play:true,
//     index:8
//   },
//   {
//     video:$rawfile('short_video1.mp4'),
//     name:'@山猫',
//     description:'海的那边，是.....',
//     time:'2024-01-24 12:32',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo33'),
//     likeCount:'1234',
//     commentCount:'1122',
//     favoriteCount:'445',
//     shareount:'3321',
//     hotsport:'海',
//     play:true,
//     index:9
//   },
//   {
//     video:$rawfile('short_video2.mp4'),
//     name:'@登山爱好者',
//     description:'#雪山',
//     time:'2022-04-24 12:12',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo35'),
//     likeCount:'1884',
//     commentCount:'1542',
//     favoriteCount:'4545',
//     shareount:'861',
//     hotsport:'雪的距离',
//     play:true,
//     index:10
//   },
//   {
//     video:$rawfile('short_video3.mp4'),
//     name:'@平平淡淡',
//     description:'生活不只是眼前的苟且，还有诗和远方',
//     time:'2023-08-20 10:45',
//     controller:this.myController,
//     auto:true,
//     head:$r('app.media.photo37'),
//     likeCount:'777',
//     commentCount:'4576',
//     favoriteCount:'8896',
//     shareount:'1112',
//     hotsport:'日出',
//     play:true,
//     index:11
//   },
// ];



