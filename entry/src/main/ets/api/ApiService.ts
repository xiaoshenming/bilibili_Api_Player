// entry/src/main/ets/services/ApiService.ts

import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 【重要】请务必将此IP和端口替换为您后端服务器的实际地址
const BASE_URL = 'http://10.3.36.15:11111/api';

class ApiService {
  private async request<T>(endpoint: string, options: http.HttpRequestOptions): Promise<T> {
    const url = `${BASE_URL}${endpoint}`;
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        ...options,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
    readTimeout: 900000,
        header: {
          'Content-Type': 'application/json',
          ...options.header
        }
      });

      httpRequest.destroy();

      // 支持200 OK和201 Created状态码
      if (response.responseCode === http.ResponseCode.OK || response.responseCode === 201) {
        const result = JSON.parse(response.result as string);
        if (result.code !== 200 && result.code !== 201) {
          throw new Error(result.message || '操作失败');
        }
        return result.data as T;
      } else {
        console.error(`HTTP Error: ${response.responseCode}, Message: ${response.result}`);
        throw new Error(`网络请求失败，错误码: ${response.responseCode}`);
      }
    } catch (err) {
      httpRequest.destroy();
      const businessError = err as BusinessError;
      console.error(`Request failed for ${url}. Error: ${businessError.message}`);
      throw new Error(businessError.message || '未知错误');
    }
  }

  // PC端登录
  login(account: string, password: string): Promise<{ token: string; }> {
    // 【核心修复】将前端的 `account` 变量，映射为后端需要的 `username` 字段
    return this.request('/harmony/login', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ username: account, password: password })
    });
  }

  // 发送验证码
  sendVerificationCode(email: string, type: 'register' | 'bind'): Promise<void> {
    return this.request('/send-verification-code', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ email, type })
    });
  }

  // 用户注册
  register(name: string, email: string, password: string, code: string): Promise<{ message: string; }> {
    // 【修复】后端 registerUser 需要 name, email, password, code 四个字段，这里已经正确
    return this.request('/register', {
      method: http.RequestMethod.POST,
      extraData: JSON.stringify({ name, email, password, code })
    });
  }

  // 用户退出登录方法
  logout(token: string): Promise<void> {
    return this.request('/logout', {
      method: http.RequestMethod.POST,
      header: {
        // 后端 authorize 中间件需要 Authorization 请求头来验证用户身份
        'Authorization': `Bearer ${token}`,
        // 【核心修复】添加 devicetype 请求头，值必须与登录时一致
        'devicetype': 'harmony'
      }
    });
  }

  // B站视频解析接口
  parseVideo(token: string, input: string): Promise<{
    bvid: string;
    cid: string;
    title: string;
    desc: string;
    type: string;
    play_info: any;
  }> {
    return this.request('/bilibili/parse-video', {
      method: http.RequestMethod.GET,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      },
      extraData: `input=${encodeURIComponent(input)}`
    });
  }

  // B站视频详细信息解析接口（包含下载链接）
  parseVideoDetails(token: string, input: string): Promise<{
    videoUrl: string;
    audioUrl: string;
    bvid: string;
    aid: string;
    cid: string;
    tname: string;
    pic: string;
    title: string;
    desc: string;
    duration: number;
    pubdate: number;
    name: string;
    face: string;
    view: number;
    danmaku: number;
    reply: number;
    favorite: number;
    coin: number;
    share: number;
    like: number;
  }> {
    return this.request('/bilibili/parse-videos', {
      method: http.RequestMethod.GET,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      },
      extraData: `input=${encodeURIComponent(input)}`
    });
  }

  // 视频处理接口 - 根据用户提供的API流程
  processVideo(token: string, url: string, quality: number = 80, downloadMode: string = 'auto'): Promise<{
    id: number;
    updated: boolean;
    title: string;
    bvid: string;
    filePath: string;
    playUrl: string;
    message: string;
    downloadMode: string;
    qualityDesc: string;
  }> {
    return this.request('/video/process', {
      method: http.RequestMethod.POST,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      },
      extraData: JSON.stringify({ url, quality, downloadMode })
    });
  }

  // 生成下载链接接口
  generateDownloadLink(token: string, fileName: string): Promise<{
    downloadUrl: string;
    token: string;
    expiresAt: string;
  }> {
    return this.request('/video/generate-download-link', {
      method: http.RequestMethod.POST,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      },
      extraData: JSON.stringify({ fileName })
    });
  }

  // 获取B站账号列表
  getBilibiliAccounts(token: string): Promise<Array<{
    id: string;
    nickname: string;
    avatar: string;
    is_active: boolean;
    created_at: string;
  }>> {
    return this.request('/bilibili/accounts', {
      method: http.RequestMethod.GET,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      }
    });
  }

  // 获取哔哩哔哩鉴权信息
  getBilibiliAuthInfo(token: string): Promise<{
    dedeuserid: string;
    bili_jct: string;
    cookie_string: string;
    nickname: string;
    avatar: string;
    login_time: string;
    expire_time: string | null;
    cookies: {
      DedeUserID: string;
      bili_jct: string;
      SESSDATA: string;
      DedeUserID__ckMd5: string;
    };
  }> {
    return this.request('/bilibili/auth-info', {
      method: http.RequestMethod.GET,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      }
    });
  }

  // 获取哔哩哔哩推荐视频列表
  // 注意：后端暂时没有此API，返回空数据避免404错误
  async getBilibiliRecommendVideos(token: string, page: number = 1): Promise<{
    videos: Array<{
      bvid: string;
      aid: number;
      cid: number;
      title: string;
      pic: string;
      desc: string;
      duration: number;
      pubdate: number;
      owner: {
        name: string;
        face: string;
        mid: number;
      };
      stat: {
        view: number;
        danmaku: number;
        reply: number;
        favorite: number;
        coin: number;
        share: number;
        like: number;
      };
      tname: string;
    }>;
    has_more: boolean;
  }> {
    // 由于后端没有recommend-videos API，直接返回空数据
    // 这样会触发Home.ets中的catch块，回退到loadData方法
    console.log('getBilibiliRecommendVideos: 后端暂无此API，将回退到原有数据加载方式');
    throw new Error('recommend-videos API暂未实现，回退到原有方式');
  }

  // 获取用户视频列表
  async getUserVideos(token: string): Promise<Array<{
    id: number;
    bvid: string;
    title: string;
    pic: string;
    view: string;
    danmaku: string;
    like: string;
    coin: string;
    favorite: string;
    share: string;
    current_viewers: string;
    quality: string;
    download_link: string;
    pubdate: string;
    aid: string;
    tname: string;
    desc: string;
    duration: string;
    name: string;
    face: string;
    reply: string;
    cid: string;
    relation_type: string;
    relation_created_at: string;
    relation_desc: string;
  }>> {
    return this.request('/video/user-list', {
      method: http.RequestMethod.GET,
      header: {
        'Authorization': `Bearer ${token}`,
        'devicetype': 'harmony'
      }
    });
  }

  // 【新增】检查用户登录状态和Token有效性
  async checkStatus(token: string): Promise<{
    success: boolean;
    data?: {
      name: string;
      avatar: string;
      userid: string;
      email: string;
      access: string;
      [key: string]: any;
    };
    message?: string;
  }> {
    const url = `${BASE_URL}/status`;
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
    readTimeout: 900000,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'devicetype': 'harmony'
        }
      });

      httpRequest.destroy();

      if (response.responseCode === http.ResponseCode.OK) {
        const result = JSON.parse(response.result as string);
        console.log('Status API 原始响应:', JSON.stringify(result));
        
        if (result.success && result.data) {
          return {
            success: true,
            data: result.data
          };
        } else {
          throw new Error(result.message || '状态检查失败');
        }
      } else {
        console.error(`HTTP Error: ${response.responseCode}, Message: ${response.result}`);
        throw new Error(`网络请求失败，错误码: ${response.responseCode}`);
      }
    } catch (err) {
      httpRequest.destroy();
      const businessError = err as BusinessError;
      console.error(`Request failed for ${url}. Error: ${businessError.message}`);
      return {
        success: false,
        message: businessError.message || '状态检查失败'
      };
    }
  }
}

export const apiService = new ApiService();