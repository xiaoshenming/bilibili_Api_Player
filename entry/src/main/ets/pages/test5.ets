import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
// import { JSON } from '@kit.ArkTS';
interface VideoData {
  head: string; // 视频封面图片地址
  name: string; // 视频名称
  description: string; // 视频描述
}

@Entry
@Component
export  struct test5 {
  @State message: string = '测试';
  @State apiResponse: object = []; // 存储原始 API 响应
  @State  datas: Array<VideoData> = [];

  async aboutToAppear() {
    const sessdata = '你的SESSDATA'; // 替换成实际的 SESSDATA
    const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      this.apiResponse = [ '请求失败' ];
    }
  }

  // 解析 API 响应
  private parseApiResponse(response: object) {

    try {
      console.log('从ts发送过来的数据', response);
      console.info(JSON.stringify(response));
      console.info(JSON.stringify(response["data"]["item"][1]["id"]));
    } catch (error) {
      console.error('解析 JSON 失败:', error); // 错误处理
      this.datas = []; // 清空数据
    }

    // let data = JSON.parse(response);
    // console.info((data as object)?.["code"]);
    //
    //
    // console.info('aaaaaa',data)
    // console.info('bbbbbb',response)
    // if (data.code === 0 && data.data.item) {
    //   this.datas = data.data.item.map(item => ({
    //     head: item.pic, // 假设 pic 是视频封面图片地址
    //     name: item.title,
    //     description: item.desc || '无描述' // 假设有描述字段
    //   }));
    // }
  }





  build() {
    Row() {
      Scroll() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);

        List({ space: 5 }) {
          ForEach(this.datas, (item: VideoData, index: number) => {
            ListItem() {
              RelativeContainer() {
                Image(item.head)
                  .width('100%')
                  .aspectRatio(1)// 封面图片为正方形
                  .objectFit(ImageFit.Cover)
                  .alignRules({
                    top: { anchor: "__container__", align: VerticalAlign.Top },
                    left: { anchor: "__container__", align: HorizontalAlign.Start }
                  })
                  .id("image1")
                  .onClick(() => {
                    console.log(`Clicked on video: ${item.name}`);
                  });

                Text(item.description)
                  .fontSize(14)
                  .padding({ top: 10, left: 10, bottom: 10 })
                  .fontWeight(FontWeight.Normal)
                  .letterSpacing(2)
                  .lineHeight(20)
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
              .borderRadius(5)
              .width('100%')
              .height(225)
              .backgroundColor('#ffffff'); // 可选：背景颜色
            }
            .borderRadius(5)
            .height(225);
          });
        }
      }
      .width('100%');
    }
    .height('100%');

  }
  }
}
