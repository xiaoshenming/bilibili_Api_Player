import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';
@Entry
@Component
export struct test7 {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State index: number = 0;
  @State apiResponse: object = []; // 存储原始 API 响应
  @State loadingMore: boolean = false; // 用于指示是否正在加载更多数据

  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  async aboutToAppear() {
    await this.loadData(); // 加载初始数据
  }

  // 加载数据的公共方法
  private async loadData() {
    const sessdata = '你的SESSDATA'; // 替换成实际的 SESSDATA
    const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      console.error('请求失败');
    }
  }

  private parseApiResponse(response: object) {
    if (response["code"] === 0 && response["data"]["item"]) {
      const items:Array<string> = response["data"]["item"];

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        this.datas.pushData({
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["uri"], // 视频链接
          name: item["owner"]["name"], // UP主
          view: item["stat"]["view"], // 播放量
          barrage: item["stat"]["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          controller: this.myController,
        });
      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  // 列表到底部时触发
  private async onReachEnd() {
    if (this.loadingMore) return; // 避免重复加载
    this.loadingMore = true; // 设置为加载中

    await this.loadData(); // 重新加载数据

    this.loadingMore = false; // 重置加载状态
  }

  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }

  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Scroll() {
      Column() {
        Text("Scroll Area")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center);
        Tabs({ barPosition: BarPosition.Start }) {
          TabContent() {
            List({ space: 5 }) {
              LazyForEach(this.datas, (item: VideoData, index: number) => {
                ListItem() {
                  RelativeContainer() {
                    Image(item.head)
                      .width('100%')
                      .height(130)   // 设置固定高度
                      .aspectRatio(0)
                      .objectFit(ImageFit.Cover)
                      .alignRules({
                        top: { anchor: "__container__", align: VerticalAlign.Top },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      })
                      .id("image1")


                    Text(item.description)
                      .fontSize(14)
                      .padding({ top: 10, left: 10, bottom: 10 })
                      .fontWeight(FontWeight.Normal)
                      .letterSpacing(2)
                      .lineHeight(20)
                      .maxLines(2)  // 设置最多两行
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignRules({
                        top: { anchor: "image1", align: VerticalAlign.Bottom },
                        left: { anchor: "image1", align: HorizontalAlign.Start }
                      });

                    Text(item.name)
                      .fontSize(12)
                      .letterSpacing(2)
                      .fontColor(Color.Gray)
                      .fontWeight(FontWeight.Normal)
                      .padding({ left: 10, bottom: 10, top: 10 })
                      .alignRules({
                        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      });
                  }
                  .onClick(() => {
                    //点击之后跳转到Videoplay
                    console.log(`Clicked on video: ${item.name}`);

                    // 跳转到 VideoPlayer 页面，并传递视频数据
                    router.push({
                      url: 'pages/VideoPlayer', // 目标页面
                      params: {
                        videoData: item // 将当前视频信息作为参数传递
                      }
                    });
                  })
                  .borderRadius(5)
                  .width('100%')
                  .height(225)
                  .backgroundColor('#ffffff');
                }
                .borderRadius(5)
                .height(225);
              });
            }
            .onReachEnd(() => {
              this.onReachEnd()
              console.log('触底')
            })
            .cachedCount(6)
            .lanes(2, 5)
            .width("100%")
            .edgeEffect(EdgeEffect.Spring)
            // .edgeEffect(EdgeEffect.None)//听说可以防止反弹二次触发
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            });
          }.tabBar("Tab1");

          TabContent() {
          }.tabBar("Tab2");
        }
        .padding({ left: 5, right: 5 })
        .vertical(false)
        .height("100%");
      }.width("100%");
    }
    .edgeEffect(EdgeEffect.Spring)
    .friction(0.6)
    .backgroundColor('#DCDCDC')
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%');
  }
}
