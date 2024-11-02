import { http } from '@kit.NetworkKit';

interface playcookie {
  'Cookie': string;
  'User-Agent': string;
  'Referer': string;
}

async function getHomepageRecommendations(sessdata: string, freshType: number = 4, ps: number = 30) {
  const url = 'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd';
  const headers: playcookie = {
    'Cookie': `SESSDATA=${sessdata}`,
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36',
    'Referer': 'https://www.bilibili.com/'
  };

  let httpRequest = http.createHttp();

  try {
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: headers,
      expectDataType: http.HttpDataType.STRING,
      extraData: {
        fresh_type: freshType,
        ps: ps
      }
    });

    if (response.responseCode === 200) {
      console.log('Response:', JSON.stringify(response.result));
    } else {
      console.log('请求失败:', response.responseCode);
    }
  } catch (error) {
    console.log('请求出错:', error);
  } finally {
    httpRequest.destroy();
  }
}

@Entry
@Component
struct test3 {
  @State message: string = '测试';

  async aboutToAppear() {
    await getHomepageRecommendations('你的SESSDATA'); // 替换为实际的 SESSDATA
  }

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
