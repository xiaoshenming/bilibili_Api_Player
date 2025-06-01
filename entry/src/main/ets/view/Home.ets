import { MyDataSource } from '../Model/MyDataSource';
import { VideoData, BilibiliAccount } from '../Model/VideoData';
import { bilibiliService } from '../api/BilibiliService';
import { promptAction, router } from '@kit.ArkUI';
import { tokenManager } from '../utils/TokenManager';
import { common } from '@kit.AbilityKit';



/*
 *
 * 1. top: { anchor: "row3", align: VerticalAlign.Bottom }
anchor: "row3"：这个参数指明了当前组件的上边缘将与名为 row3 的组件对齐。
align: VerticalAlign.Bottom：当前组件的上边缘将对齐到 row3 的底部。也就是说，当前组件的顶部将位于 row3 的底部位置。
2. bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
anchor: "__container__"：这里使用了 __container__ 作为锚点，表示当前组件的底部将与其父容器的底部对齐。
align: VerticalAlign.Bottom：当前组件的底部将对齐到容器的底部边缘。
3. left: { anchor: "__container__", align: HorizontalAlign.Start }
anchor: "__container__"：当前组件的左边缘将与父容器的左边缘对齐。
align: HorizontalAlign.Start：这表示当前组件的左边缘将对齐到容器的左侧开始位置。
4. right: { anchor: "row1", align: HorizontalAlign.End }
anchor: "row1"：当前组件的右边缘将与名为 row1 的组件对齐。
align: HorizontalAlign.End：这表示当前组件的右边缘将对齐到 row1 的右边缘。
* */
@Entry
@Component
export struct Home {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State index: number = 0;
  @State bilibiliAccounts: BilibiliAccount[] = []; // 存储哔哩哔哩账号列表
  @State loadingMore: boolean = false; // 用于指示是否正在加载更多数据
  @State bottomTabIndex: number = 1;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  async aboutToAppear() {
    await this.loadBilibiliAccounts(); // 加载哔哩哔哩账号数据
  }

  // 加载哔哩哔哩账号数据
  private async loadBilibiliAccounts() {
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const token = await tokenManager.getToken(context) as string;
      if (!token) {
        this.errorMessage = '请先登录';
        return;
      }
      const accounts = await bilibiliService.getBilibiliAccounts(context);
      if (accounts && accounts.length > 0) {
        this.bilibiliAccounts = accounts;
        // 为每个账号创建一个虚拟的视频数据项用于显示
        this.createAccountDisplayItems();
      } else {
        this.errorMessage = '暂无哔哩哔哩账号数据';
      }
    } catch (error) {
      console.error('加载账号数据失败:', error);
      this.errorMessage = '加载账号数据失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  // 为账号创建显示项
  private createAccountDisplayItems() {
    this.datas.clearData();
    
    this.bilibiliAccounts.forEach((account, index) => {
      this.datas.pushData({
        description: `${account.uname} 的账号`, // 标题
        head: account.face || '', // 头像
        video: '', // 暂无视频链接
        bvid: '',
        name: account.uname || '', // 用户名
        face: account.face || '', // 头像
        view: String(account.follower || 0), // 粉丝数作为播放量显示
         total: '0',
         like: '0',
         barrage: '0',
         time: '账号信息',
         pubdate: account.sign || '暂无签名',
         coins: '0',
         favorites: '0',
         shares: '0',
        controller: this.myController,
        auto: false,
        play: false,
        index: String(index),
        // 新增字段
         audioUrl: '',
         aid: String(account.id || 0),
         cid: String(account.id || 0),
         reply: '0',
         tname: '账号'
      });
    });
  }

  // 刷新数据
  private async refreshData() {
    await this.loadBilibiliAccounts();

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
        Text("哔哩哔哩账号管理")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold);
        Tabs({ barPosition: BarPosition.Start ,index: this.bottomTabIndex})
        {
          TabContent() {
          }.tabBar("直播");

          TabContent() {
            if (this.isLoading) {
              Column() {
                LoadingProgress()
                  .width(50)
                  .height(50)
                  .color('#0080DC')
                Text('加载中...')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ top: 10 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else if (this.errorMessage) {
              Column() {
                Text(this.errorMessage)
                  .fontSize(16)
                  .fontColor('#FF6B6B')
                  .textAlign(TextAlign.Center)
                  .margin({ bottom: 20 })
                Button('重试')
                  .onClick(() => {
                    this.refreshData()
                  })
                  .backgroundColor('#0080DC')
                  .fontColor(Color.White)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              List({ space: 5 }) {
                LazyForEach(this.datas, (item: VideoData, index: number) => {
                  ListItem() {
                    RelativeContainer() {
                      Image(item.head)
                        .width('100%')
                        .height(130)
                        .aspectRatio(0)
                        .objectFit(ImageFit.Cover)
                        .alignRules({
                          top: { anchor: "__container__", align: VerticalAlign.Top },
                          left: { anchor: "__container__", align: HorizontalAlign.Start }
                        })
                        .id("image1")
                        .borderRadius({ topLeft: 5, topRight: 5 })

                      Text(item.description)
                        .fontSize(14)
                        .padding({ top: 10, left: 10, bottom: 10 })
                        .fontWeight(FontWeight.Normal)
                        .letterSpacing(1)
                        .lineHeight(20)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .alignRules({
                          top: { anchor: "image1", align: VerticalAlign.Bottom },
                          left: { anchor: "image1", align: HorizontalAlign.Start }
                        })

                      Row() {
                        Text(item.name)
                          .fontSize(12)
                          .fontColor('#666666')
                          .fontWeight(FontWeight.Normal)
                        
                        Text(`粉丝: ${item.view}`)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ left: 10 })
                      }
                      .padding({ left: 10, bottom: 10, top: 5 })
                      .alignRules({
                        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      })
                    }
                    .onClick(() => {
                      // 点击账号项，可以添加账号相关操作
                      console.log(`选择账号: ${item.name}`);
                      promptAction.showToast({
                        message: `选择了账号: ${item.name}`,
                        duration: 2000
                      });
                    })
                    .borderRadius(8)
                    .width('100%')
                    .height(225)
                    .backgroundColor('#ffffff')
                    .shadow({
                      radius: 4,
                      color: '#1F000000',
                      offsetX: 0,
                      offsetY: 2
                    })
                  }
                  .borderRadius(8)
                  .height(225)
                  .margin({ bottom: 5 })
                })
              }
               .cachedCount(6)
               .lanes(2, 5)
               .width("100%")
               .edgeEffect(EdgeEffect.Spring)
             }
            // .edgeEffect(EdgeEffect.None)//听说可以防止反弹二次触发

          }.tabBar("推荐")


          TabContent() {
          }.tabBar("热门");
          TabContent() {
          }.tabBar("动画");
          TabContent() {
          }.tabBar("影视");
          TabContent() {
          }.tabBar("新征程");
          TabContent() {
          }.tabBar("#");

        }
        .onChange((newIndex) => {
          console.log(`当前选择的Tab索引: ${newIndex}`);
          // 判断是否切换到"推荐"标签
          if (newIndex === 1) { // 假设"推荐"对应索引为1
            this.refreshData()
            console.log("切换到推荐标签，开始刷新数据");

          }
        })
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
