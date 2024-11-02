// 代码示例
import { http } from '@kit.NetworkKit'

const req = http.createHttp()
req.request('www.baidu.com')
  .then((res: http.HttpResponse) => {
    AlertDialog.show({ message: JSON.stringify(res) })
    console.log('aaaaa')
  })

@Entry
@Component
struct Index {
  @State message: string = '测试';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
