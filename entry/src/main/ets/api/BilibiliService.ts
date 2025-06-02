// B站服务类 - 处理B站相关的业务逻辑

import { apiService } from './ApiService';
import type { VideoData, BilibiliVideoInfo, BilibiliAccount } from '../Model/VideoData';
import { promptAction } from '@kit.ArkUI';
import { tokenManager } from '../utils/TokenManager';
import { common } from '@kit.AbilityKit';

class BilibiliService {

  /**
   * 解析B站视频链接，获取基本信息
   * @param context 应用上下文
   * @param input 视频链接或BV号
   * @returns 视频基本信息
   */
  async parseVideo(context: common.UIAbilityContext, input: string): Promise<{
    bvid: string;
    cid: string;
    title: string;
    desc: string;
    type: string;
    play_info: any;
  } | null> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return null;
      }

      const result = await apiService.parseVideo(token, input);
      return result;
    } catch (error) {
      console.error('解析视频失败:', error);
      promptAction.showToast({ message: `解析失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 解析B站视频详细信息，包含下载链接
   * @param context 应用上下文
   * @param input 视频链接或BV号
   * @returns 视频详细信息
   */
  async parseVideoDetails(context: common.UIAbilityContext, input: string): Promise<BilibiliVideoInfo | null> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return null;
      }

      const result = await apiService.parseVideoDetails(token, input);
      return result;
    } catch (error) {
      console.error('解析视频详情失败:', error);
      promptAction.showToast({ message: `解析失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 获取用户的B站账号列表
   * @param context 应用上下文
   * @returns B站账号列表
   */
  async getBilibiliAccounts(context: common.UIAbilityContext): Promise<BilibiliAccount[]> {
    try {
      const token = await tokenManager.getToken(context);
      if (!token) {
        promptAction.showToast({ message: '请先登录' });
        return [];
      }

      const accounts = await apiService.getBilibiliAccounts(token);
      return accounts;
    } catch (error) {
      console.error('获取B站账号列表失败:', error);
      promptAction.showToast({ message: `获取账号列表失败: ${error.message}` });
      return [];
    }
  }

  /**
   * 处理视频 - 新的API流程
   * @param context 应用上下文
   * @param url 视频链接
   * @param quality 视频质量
   * @param downloadMode 下载模式
   * @returns 处理结果
   */
  async processVideo(context: common.UIAbilityContext, url: string, quality: number = 80, downloadMode: string = 'auto'): Promise<{
    id: number;
    updated: boolean;
    title: string;
    bvid: string;
    filePath: string;
    playUrl: string;
    message: string;
    downloadMode: string;
    qualityDesc: string;
  } | null> {
    try {
      console.info('processVideo开始执行');
      console.info('获取token...');
      const token = await tokenManager.getToken(context);
      if (!token) {
        console.error('token为空，用户未登录');
        promptAction.showToast({ message: '请先登录' });
        return null;
      }
      console.info('token获取成功');

      console.info('开始处理视频:', url);
      console.info('调用apiService.processVideo...');
      const result = await apiService.processVideo(token, url, quality, downloadMode);
      console.info('视频处理成功:', result.title);
      console.info('processVideo执行完成');
      return result;
    } catch (error) {
      console.error('处理视频失败:', error);
      console.error('processVideo异常详情:', JSON.stringify(error));
      promptAction.showToast({ message: `处理失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 生成下载链接
   * @param context 应用上下文
   * @param fileName 文件名
   * @returns 下载链接信息
   */
  async generateDownloadLink(context: common.UIAbilityContext, fileName: string): Promise<{
    downloadUrl: string;
    token: string;
    expiresAt: string;
  } | null> {
    try {
      console.info('generateDownloadLink开始执行');
      console.info('获取token...');
      const token = await tokenManager.getToken(context);
      if (!token) {
        console.error('token为空，用户未登录');
        promptAction.showToast({ message: '请先登录' });
        return null;
      }
      console.info('token获取成功');

      console.info('生成下载链接:', fileName);
      console.info('调用apiService.generateDownloadLink...');
      const result = await apiService.generateDownloadLink(token, fileName);
      console.info('下载链接生成成功');
      console.info('generateDownloadLink执行完成');
      return result;
    } catch (error) {
      console.error('生成下载链接失败:', error);
      console.error('generateDownloadLink异常详情:', JSON.stringify(error));
      promptAction.showToast({ message: `生成链接失败: ${error.message}` });
      return null;
    }
  }

  /**
   * 完整的视频处理流程
   * @param context 应用上下文
   * @param url 视频链接
   * @returns 可播放的视频信息
   */
  async processVideoComplete(context: common.UIAbilityContext, url: string): Promise<BilibiliVideoInfo | null> {
    try {
      console.info('processVideoComplete开始执行');
      console.info('输入参数 - url:', url);
      
      // 第一步：解析视频信息（获取详细数据）
      console.info('第一步：开始解析视频信息...');
      const token = await tokenManager.getToken(context);
      if (!token) {
        console.error('token为空，用户未登录');
        return null;
      }
      
      // 先解析视频信息获取详细数据
      const parseResult = await apiService.parseVideoDetails(token, url);
      console.info('视频解析结果:', parseResult ? '成功' : '失败');
      if (!parseResult) {
        console.error('视频解析失败，返回null');
        return null;
      }
      
      // 第二步：处理视频（下载和转换）
      console.info('第二步：开始处理视频...');
      const processResult = await this.processVideo(context, url);
      console.info('视频处理结果:', processResult ? '成功' : '失败');
      if (!processResult) {
        console.error('视频处理失败，返回null');
        return null;
      }

      // 第三步：生成下载链接
      console.info('第三步：开始生成下载链接...');
      const fileName = `${processResult.bvid}.mp4`;
      console.info('文件名:', fileName);
      const downloadResult = await this.generateDownloadLink(context, fileName);
      console.info('下载链接生成结果:', downloadResult ? '成功' : '失败');
      if (!downloadResult) {
        console.error('下载链接生成失败，返回null');
        return null;
      }

      // 构造返回的视频信息，使用解析得到的详细数据
      const videoInfo: BilibiliVideoInfo = {
        videoUrl: downloadResult.downloadUrl,
        audioUrl: parseResult.audioUrl || '', 
        bvid: processResult.bvid,
        aid: String(parseResult.aid || processResult.id),
        cid: String(parseResult.cid || '0'),
        tname: parseResult.tname || '', 
        pic: parseResult.pic || '', 
        title: processResult.title,
        desc: parseResult.desc || '', 
        duration: parseResult.duration || 0, 
        pubdate: parseResult.pubdate || 0, 
        name: parseResult.name || '', 
        face: parseResult.face || '', 
        view: parseResult.view || 0, 
        danmaku: parseResult.danmaku || 0, 
        reply: parseResult.reply || 0, 
        favorite: parseResult.favorite || 0, 
        coin: parseResult.coin || 0, 
        share: parseResult.share || 0, 
        like: parseResult.like || 0 
      };

      return videoInfo;
    } catch (error) {
      console.error('完整视频处理流程失败:', error);
      return null;
    }
  }

  /**
   * 提取BVID
   * @param input 用户输入的链接或BV号
   * @returns BVID
   */
  extractBvid(input: string): string | null {
    if (input.includes('bilibili.com/video/')) {
      const match = input.match(/BV[a-zA-Z0-9]+/);
      return match ? match[0] : null;
    } else if (input.startsWith('BV')) {
      return input;
    }
    return null;
  }

  /**
   * 验证输入是否为有效的B站视频链接或BV号
   * @param input 用户输入
   * @returns 是否有效
   */
  isValidBilibiliInput(input: string): boolean {
    if (!input || input.trim() === '') {
      return false;
    }
    
    const trimmedInput = input.trim();
    
    // 检查是否为B站视频链接
    if (trimmedInput.includes('bilibili.com/video/')) {
      return /BV[a-zA-Z0-9]+/.test(trimmedInput);
    }
    
    // 检查是否为BV号
    if (trimmedInput.startsWith('BV')) {
      return /^BV[a-zA-Z0-9]+$/.test(trimmedInput);
    }
    
    return false;
  }

  /**
   * 格式化播放量、点赞数等数字
   * @param num 数字
   * @returns 格式化后的字符串
   */
  formatNumber(num: number): string {
    if (num >= 10000) {
      return (num / 10000).toFixed(1) + '万';
    }
    return num.toString();
  }

  /**
   * 格式化时长
   * @param duration 时长（秒）
   * @returns 格式化后的时长字符串
   */
  formatDuration(duration: number): string {
    const hours = Math.floor(duration / 3600);
    const minutes = Math.floor((duration % 3600) / 60);
    const seconds = duration % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
  }

  /**
   * 格式化发布时间
   * @param timestamp 时间戳
   * @returns 格式化后的时间字符串
   */
  formatPublishTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor(diff / (1000 * 60));
    
    if (days > 0) {
      return `${days}天前`;
    } else if (hours > 0) {
      return `${hours}小时前`;
    } else if (minutes > 0) {
      return `${minutes}分钟前`;
    } else {
      return '刚刚';
    }
  }
}

export const bilibiliService = new BilibiliService();