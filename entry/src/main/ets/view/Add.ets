
import { bilibiliService } from '../api/BilibiliService';
import { BilibiliVideoInfo, VideoData } from '../Model/VideoData';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Component
export struct Add {
  @State inputUrl: string = '';
  @State isLoading: boolean = false;
  @State parseResult: BilibiliVideoInfo | null = null;
  @State showResult: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private controller: VideoController = new VideoController();

  build() {
    Column({ space: 20 }) {
      // 标题
      Text('B站视频解析')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20 })

      // 输入区域
      Column({ space: 15 }) {
        Text('请输入B站视频链接或BV号')
          .fontSize(16)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextInput({
          placeholder: '例如：https://www.bilibili.com/video/BV1xx411c7mD 或 BV1xx411c7mD'
        })
          .width('100%')
          .height(50)
          .fontSize(14)
          .borderRadius(8)
          .backgroundColor('#f5f5f5')
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
            this.inputUrl = value;
          })

        // 解析按钮
        Button(this.isLoading ? '解析中...' : '开始解析')
          .width('100%')
          .height(45)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isLoading ? '#cccccc' : '#00a1d6')
          .borderRadius(8)
          .enabled(!this.isLoading && this.inputUrl.trim() !== '')
          .onClick(() => {
            this.parseVideo();
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 8, color: '#1a000000', offsetX: 0, offsetY: 2 })

      // 解析结果
      if (this.showResult && this.parseResult) {
        this.buildResultCard();
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f2f5')
    .padding({ left: 20, right: 20 })
  }

  @Builder
  buildResultCard() {
    Column({ space: 15 }) {
      // 视频封面和基本信息
      Row({ space: 15 }) {
        Image(this.parseResult!.pic)
          .width(120)
          .height(80)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        Column({ space: 8 }) {
          Text(this.parseResult!.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`UP主: ${this.parseResult!.name}`)
            .fontSize(14)
            .fontColor('#666666')

          Row({ space: 10 }) {
            Text(`${bilibiliService.formatNumber(this.parseResult!.view)}播放`)
              .fontSize(12)
              .fontColor('#999999')
            Text(`${bilibiliService.formatNumber(this.parseResult!.like)}点赞`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 视频信息
      Column({ space: 10 }) {
        this.buildInfoRow('时长', bilibiliService.formatDuration(this.parseResult!.duration));
        this.buildInfoRow('分区', this.parseResult!.tname);
        this.buildInfoRow('发布时间', bilibiliService.formatPublishTime(this.parseResult!.pubdate));
        this.buildInfoRow('BV号', this.parseResult!.bvid);
      }

      // 播放按钮
      Button('立即播放')
        .width('100%')
        .height(45)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#ff6699')
        .borderRadius(8)
        .onClick(() => {
          this.playVideo();
        })
    }
    .width('90%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 8, color: '#1a000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
  }

  // 解析视频
  private async parseVideo() {
    if (!bilibiliService.isValidBilibiliInput(this.inputUrl)) {
      AlertDialog.show({
        title: '输入错误',
        message: '请输入有效的B站视频链接或BV号',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }

    this.isLoading = true;
    this.showResult = false;

    try {
      const result = await bilibiliService.parseVideoDetails(this.context, this.inputUrl);
      if (result) {
        this.parseResult = result;
        this.showResult = true;
      }
    } catch (error) {
      console.error('解析失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 播放视频
  private playVideo() {
    if (!this.parseResult) return;

    // 构造VideoData格式的数据
    const videoData: VideoData = {
      description: this.parseResult.title,
      head: this.parseResult.pic,
      video: this.parseResult.videoUrl,
      audioUrl: this.parseResult.audioUrl,
      bvid: this.parseResult.bvid,
      aid: String(this.parseResult.aid),
      cid: String(this.parseResult.cid),
      name: this.parseResult.name,
      face: this.parseResult.face,
      view: this.parseResult.view,
      like: this.parseResult.like,
      barrage: this.parseResult.danmaku,
      time: this.parseResult.duration,
      pubdate: this.parseResult.pubdate,
      coins: this.parseResult.coin,
      favorites: this.parseResult.favorite,
      shares: this.parseResult.share,
      reply: String(this.parseResult.reply),
      tname: this.parseResult.tname,
      controller: this.controller,
      auto: false,
      play: false,
      index: '0'
    };

    // 跳转到视频播放页面
    router.pushUrl({
      url: 'pages/VideoPlayer',
      params: {
        videoDatas: [videoData],
        bvidflag: this.parseResult.bvid,
        fromParse: true
      }
    });
  }
}