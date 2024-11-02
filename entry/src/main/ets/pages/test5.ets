import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import http from '@ohos.net.http';
// 定义数据结构

@Entry
@Component
export struct test5 {
  @State message: string = '测试';
  @State apiResponse: object = []; // 存储原始 API 响应
  async aboutToAppear() {
    const sessdata = '你的SESSDATA'; // 替换成实际的 SESSDATA
    const response = await requestSelf(sessdata, http.RequestMethod.GET, null);

    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      this.apiResponse = ['请求失败'];
    }
  }
  // 解析 API 响应
  private parseApiResponse(response: object) {
    console.info(JSON.stringify(response["data"]["item"][1]["id"]));
    console.info(JSON.stringify(response["data"]["item"][1]["owner"]["name"]));
    console.info(JSON.stringify(response["data"]["item"]));
    if (response["code"] === 0 && response["data"]["item"]) {
      const items = JSON.stringify(response["data"]["item"]);
      // 提取每个视频的信息
      for (let i = 0; i < items.length; i++) {
        // 输出每个视频的信息
        let description = JSON.stringify(response["data"]["item"][i]["title"])//标题
        let head = JSON.stringify(response["data"]["item"][i]["pic"])//封面URL
        let video = JSON.stringify(response["data"]["item"][i]["uri"])//视频链接
        let name = JSON.stringify(response["data"]["item"][i]["owner"]["name"])//UP主
        let view = JSON.stringify(response["data"]["item"][i]["stat"]["view"])//播放量
        let barrage = JSON.stringify(response["data"]["item"][i]["stat"]["danmaku"])//弹幕
        let time = JSON.stringify(response["data"]["item"][i]["duration"])//时长

        console.info("视频",i+1);
        console.info("标题",description);
        console.info("封面URL",head);
        console.info("视频链接",video);
        console.info("UP主",name);
        console.info("播放量",view);
        console.info("弹幕",barrage);
        console.info("时长",time);
        console.log('------------------------');
      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  build() {
    Row() {
    }
    .height('100%');
  }
}
