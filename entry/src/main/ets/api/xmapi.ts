import http from '@ohos.net.http';
// import { JSON } from '@kit.ArkTS';
interface agcookie {
  'Accept-Language': string;
  'User-Agent': string;
}
export const xmapi = async (blibliurl: string): Promise<object | null> => {
  // const url = 'https://api.aag.moe/api/bzspjx?url='+blibliurl;
  const url = `http://10.3.36.9:7894/video?url=${blibliurl}`;  // 发送请求到 Express 服务
  const headers: agcookie = {
    'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
  };

  let httpRequest = http.createHttp();

  try {
    const response: any = await httpRequest.request(url,
      {
        header: headers,
        method: http.RequestMethod.GET,
      });

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
