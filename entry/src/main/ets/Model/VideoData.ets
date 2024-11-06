//是封装视频播放显示内容集合

export interface VideoData{
  description:string,//标题
  head:Resource|string,//封面URL
  video:Resource|string,//视频链接
  bvid:string,//BV1xuSnYwEsr
  name:string,//UP主
  face:Resource|string,//UP主头像
  view:string,//播放量
  total:string,//当前观看人数
  like:string,//点赞
  barrage:string,//弹幕
  time:string,//时长
  pubdate:string,//发布时间
  coins: string,//投币
  favorites: string,//收藏
  shares: string,//转发
  controller:VideoController,
  auto:boolean,
  play:boolean,
  index:number,
}

