import http from '@ohos.net.http';
// import { JSON } from '@kit.ArkTS';
interface playcookie {
  'Cookie': string;
  'User-Agent': string;
  'Referer': string;
}
export const requestSelf = async (sessdata: string, method: http.RequestMethod, extraData: any): Promise<object | null> => {
  const url = 'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd';
  const headers: playcookie = {
    'Cookie': `SESSDATA=${sessdata}`,
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36',
    'Referer': 'https://www.bilibili.com/'
  };

  let httpRequest = http.createHttp();

  try {
    const response: any = await httpRequest.request(
      url,
      {
        method,
        header: headers,
        expectDataType: http.HttpDataType.STRING,
        usingCache: true,
        priority: 1,
        connectTimeout: 60000,
        readTimeout: 60000,
        usingProtocol: http.HttpProtocol.HTTP1_1,
        extraData: {
          fresh_type: 4,
          ps: 30
        }
      }
    );

    if (response.responseCode === 200) {
      return JSON.parse(response.result);
    } else {
      console.log('请求失败:', response.responseCode);
      return null;
    }
  } catch (error) {
    console.log('请求出错:', error);
    return null;
  } finally {
    httpRequest.destroy();
  }
}
