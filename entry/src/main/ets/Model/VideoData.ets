//是封装视频播放显示内容集合
export interface VideoData{
  video:Resource|string,
  name:string,
  description:string,
  time:string,
  controller:VideoController,
  auto:boolean,
  head:Resource,
  likeCount:string,
  commentCount:string,
  favoriteCount:string,
  shareount:string,
  hotsport:string,
  play:boolean,
  index:number
}