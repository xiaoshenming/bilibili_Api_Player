// 封装视频播放显示内容集合

export interface VideoData {
  description: string; // 标题
  head: Resource | string; // 封面URL
  video: Resource | string; // 视频链接
  audioUrl?: string; // 音频链接（DASH格式需要）
  bvid: string; // BV号
  aid?: string; // AV号
  cid?: string; // CID
  name: string; // UP主
  face: Resource | string; // UP主头像
  view: string | number; // 播放量
  total?: string; // 当前观看人数
  like: string | number; // 点赞
  barrage: string | number; // 弹幕
  time: string | number; // 时长
  pubdate: string | number; // 发布时间
  coins: string | number; // 投币
  favorites: string | number; // 收藏
  shares: string | number; // 转发
  reply?: string | number; // 评论数
  tname?: string; // 分区名称
  preloaded_url?: string; // 预加载的视频链接
  preloaded_audio?: string; // 预加载的音频链接
  controller: VideoController;
  auto: boolean;
  play: boolean;
  index: string;
}

// B站视频解析结果接口
export interface BilibiliVideoInfo {
  videoUrl: string;
  audioUrl: string;
  bvid: string;
  aid: string;
  cid: string;
  tname: string;
  pic: string;
  title: string;
  desc: string;
  duration: number;
  pubdate: number;
  name: string;
  face: string;
  view: number;
  danmaku: number;
  reply: number;
  favorite: number;
  coin: number;
  share: number;
  like: number;
}

// 用户B站账号信息接口
export interface BilibiliAccount {
  id: string;
  nickname: string;
  avatar: string;
  is_active: boolean;
  created_at: string;
  // 兼容字段
  uname?: string; // 用户名
  face?: string; // 头像
  follower?: number; // 粉丝数
  sign?: string; // 签名
}