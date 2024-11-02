import { ArrayList } from '@kit.ArkTS';

interface Winner { num: number };
let tmpStr: Record<string, Winner> = JSON.parse('{ "0": {"num": 1}, "1": {"num": 2} }');
const arrayList: ArrayList<string> = new ArrayList(); // 确保是字符串类型

// 遍历 tmpStr，将每个 Winner 对象的 num 转换为字符串并添加到 arrayList 中
Object.entries(tmpStr).forEach((item) => {
  const value = item[1];
  arrayList.add(value.num.toString()); // 将 num 转为字符串
});

// 打印 arrayList 中的内容
arrayList.forEach((numStr) => {
  console.log(numStr); // 输出每个 num 的字符串形式
});





@Entry
@Component
struct test3 {
  @State message: string = '测试';
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold);
      }
      .width('100%');
    }
    .height('100%');
  }
}