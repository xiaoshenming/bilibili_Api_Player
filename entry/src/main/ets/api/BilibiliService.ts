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