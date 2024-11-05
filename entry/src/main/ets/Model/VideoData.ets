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
  auto:boolean,
  play:boolean,
  index:number,
}

