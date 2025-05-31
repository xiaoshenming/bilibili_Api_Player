// entry/src/main/ets/services/ApiService.ts

import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 【重要】请务必将此IP和端口替换为您后端服务器的实际地址
const BASE_URL = 'http://10.23.55.31:11111/api';

class ApiService {
  private async request<T>(endpoint: string, options: http.HttpRequestOptions): Promise<T> {
    const url = `${BASE_URL}${endpoint}`;
    let httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(url, {
        ...options,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000,
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
        connectTimeout: 10000,
        readTimeout: 10000,
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