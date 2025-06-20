const express = require('express');
const router = express.Router();
const authorize = require("../auth/authUtils"); // 您的授权中间件
const { checkDailyDownloadLimit } = require('./videoUtils');
const redis = require('../../config/redis');

/**
 * @api {get} /api/video/daily-limit-status
 * @description 查询用户当前的每日下载申请限制状态
 * @access Protected - 需要用户登录
 */
router.get('/daily-limit-status', authorize(['1', '2', '3', '4']), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const userRole = req.user.role;
    
    // 获取今日申请次数
    const today = new Date().toISOString().split('T')[0];
    const redisKey = `download_requests:${userId}:${today}`;
    const currentCount = parseInt(await redis.get(redisKey) || 0);
    
    // 检查限制状态
    const limitStatus = await checkDailyDownloadLimit(userId, userRole, redis);
    
    // 根据权限等级设置每日限制
    const dailyLimits = {
      '1': 1,    // 1级权限：每天1个
      '2': 10,   // 2级权限：每天10个
      '3': 100,  // 3级权限：每天100个
      '4': -1    // 4级权限：无限制
    };
    
    const totalLimit = dailyLimits[userRole] || 1;
    const roleNames = { '1': '1级', '2': '2级', '3': '3级', '4': '4级' };
    
    res.status(200).json({
      code: 200,
      message: '获取每日限制状态成功',
      data: {
        userRole: userRole,
        roleName: roleNames[userRole],
        totalLimit: totalLimit === -1 ? '无限制' : totalLimit,
        usedCount: currentCount,
        remaining: limitStatus.remaining === -1 ? '无限制' : limitStatus.remaining,
        canApply: limitStatus.allowed,
        resetTime: '每日00:00重置'
      }
    });
  } catch (error) {
    console.error('获取每日限制状态失败:', error);
    res.status(500).json({
      code: 500,
      message: '获取每日限制状态失败',
      data: null
    });
  }
});

module.exports = router;
// model/video/videoRouters.js

const express = require("express");
const router = express.Router();
const videoUtils = require("./videoUtils");
const bilibiliUtils = require("../bilibili/bilibiliUtils");
const authorize = require("../auth/authUtils"); // 导入授权中间件

/**
 * @api {get} /api/video/list
 * @description 获取所有已处理的视频列表
 * @access Public
 */
router.get("/list", async (req, res) => {
  try {
    const videos = await videoUtils.listAllVideos();
    res.status(200).json({
      code: 200,
      message: "成功获取视频列表",
      data: videos,
    });
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message || "获取视频列表失败",
      data: null,
    });
  }
});

/**
 * @api {get} /api/video/user-list
 * @description 获取当前用户处理的视频列表
 * @access Protected - 需要用户登录
 */
router.get("/user-list", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const videos = await videoUtils.getUserVideos(userId);
    res.status(200).json({
      code: 200,
      message: "成功获取用户视频列表",
      data: videos,
    });
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message || "获取用户视频列表失败",
      data: null,
    });
  }
});

/**
 * @api {post} /api/video/parse
 * @description 解析B站视频信息（不下载，仅获取视频详情）
 * @access Protected - 需要用户登录和B站账号
 * @body { "url": "视频的URL或BVID", "quality": "清晰度(可选)" }
 */
router.post("/parse", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { url, quality = 80 } = req.body;
    
    if (!url || !url.trim()) {
      return res.status(400).json({
        code: 400,
        message: "请提供有效的视频 URL",
        data: null,
      });
    }

    // 检查用户是否有活跃的B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }

    console.log(`▶️ 开始解析视频: ${url}`);
    const result = await videoUtils.parseVideoInfo(url, bilibiliAccount.cookie_string, quality);
    console.log(`✅ 视频解析完成: ${result.title}`);
    
    res.status(200).json({
      code: 200,
      message: "视频解析成功",
      data: result,
    });
  } catch (error) {
    console.error(`❌ 解析视频失败:`, error);
    res.status(500).json({
      code: 500,
      message: error.message || "解析视频失败",
      data: null,
    });
  }
});

/**
 * @api {post} /api/video/process
 * @description 处理B站视频（解析、下载、合并、入库）
 * @access Protected - 需要用户登录和B站账号
 * @body { "url": "视频的URL或BVID", "quality": "清晰度(可选)", "downloadMode": "下载模式(可选)" }
 */
router.post("/process", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { url, quality = 80, downloadMode = "auto" } = req.body;
    
    if (!url || !url.trim()) {
      return res.status(400).json({
        code: 400,
        message: "请提供有效的视频 URL",
        data: null,
      });
    }

    // 检查用户是否有活跃的B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }

    console.log(`▶️ 开始处理视频请求: ${url}`);
    const result = await videoUtils.processVideoRequest({
      url,
      userId,
      cookieString: bilibiliAccount.cookie_string,
      quality,
      downloadMode,
      bilibiliAccountId: bilibiliAccount.id
    });
    console.log(`✅ 视频处理完成: ${result.title}`);
    
    res.status(201).json({
      code: 201,
      message: "视频处理成功并已入库",
      data: result,
    });
  } catch (error) {
    console.error(`❌ 处理视频失败:`, error);
    res.status(500).json({
      code: 500,
      message: error.message || "处理视频时发生未知错误",
      data: null,
    });
  }
});

/**
 * @api {post} /api/video/batch-process
 * @description 批量处理B站视频
 * @access Protected - 需要用户登录和B站账号
 * @body { "urls": ["视频URL数组"], "quality": "清晰度(可选)", "downloadMode": "下载模式(可选)" }
 */
router.post("/batch-process", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { urls, quality = 80, downloadMode = "auto" } = req.body;
    
    if (!urls || !Array.isArray(urls) || urls.length === 0) {
      return res.status(400).json({
        code: 400,
        message: "请提供有效的视频 URL 数组",
        data: null,
      });
    }

    if (urls.length > 10) {
      return res.status(400).json({
        code: 400,
        message: "批量处理最多支持10个视频",
        data: null,
      });
    }

    // 检查用户是否有活跃的B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }

    console.log(`▶️ 开始批量处理 ${urls.length} 个视频`);
    const results = await videoUtils.batchProcessVideos({
      urls,
      userId,
      cookieString: bilibiliAccount.cookie_string,
      quality,
      downloadMode,
      bilibiliAccountId: bilibiliAccount.id
    });
    console.log(`✅ 批量处理完成，成功: ${results.success.length}, 失败: ${results.failed.length}`);
    
    res.status(200).json({
      code: 200,
      message: `批量处理完成，成功: ${results.success.length}, 失败: ${results.failed.length}`,
      data: results,
    });
  } catch (error) {
    console.error(`❌ 批量处理视频失败:`, error);
    res.status(500).json({
      code: 500,
      message: error.message || "批量处理视频失败",
      data: null,
    });
  }
});

/**
 * @api {delete} /api/video/:id
 * @description 删除视频记录和文件
 * @access Protected - 需要用户登录
 */
router.delete("/:id", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { id } = req.params;
    const { deleteFile = false } = req.query;
    
    await videoUtils.deleteVideo(id, userId, deleteFile === 'true');
    
    res.status(200).json({
      code: 200,
      message: "视频删除成功",
      data: null,
    });
  } catch (error) {
    console.error(`❌ 删除视频失败:`, error);
    res.status(500).json({
      code: 500,
      message: error.message || "删除视频失败",
      data: null,
    });
  }
});

/**
 * @api {post} /api/video/generate-download-link
 * @description 生成安全下载链接
 * @access Protected - 需要用户登录
 */
router.post("/generate-download-link", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const { fileName } = req.body;
    const userId = req.user.uid || req.user.id;
    
    if (!fileName) {
      return res.status(400).json({
        code: 400,
        message: "文件名不能为空",
        data: null,
      });
    }
    
    // 检查用户是否有权限下载该文件
    const hasPermission = await videoUtils.checkDownloadPermission(fileName, userId);
    if (!hasPermission) {
      return res.status(403).json({
        code: 403,
        message: "无权限下载该文件",
        data: null,
      });
    }
    
    // 生成安全下载链接
    const downloadInfo = videoUtils.generateSecureDownloadLink(fileName, userId);
    
    res.status(200).json({
      code: 200,
      message: "下载链接生成成功",
      data: downloadInfo,
    });
  } catch (error) {
    console.error("生成下载链接失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "生成下载链接失败",
      data: null,
    });
  }
});

/**
 * @api {get} /api/video/secure-download
 * @description 安全文件下载（支持断点续传）
 * @access Public - 通过token验证
 */
router.get("/secure-download", async (req, res) => {
  try {
    const { token, file } = req.query;
    
    if (!token || !file) {
      return res.status(400).json({
        code: 400,
        message: "缺少必要参数",
        data: null,
      });
    }
    
    // 验证token
    const payload = videoUtils.verifyDownloadToken(token);
    if (!payload) {
      return res.status(401).json({
        code: 401,
        message: "下载链接已过期或无效",
        data: null,
      });
    }
    
    // 验证文件名是否匹配
    if (payload.fileName !== file) {
      return res.status(403).json({
        code: 403,
        message: "文件访问权限验证失败",
        data: null,
      });
    }
    
    // 再次检查用户权限
    const hasPermission = await videoUtils.checkDownloadPermission(file, payload.userId);
    if (!hasPermission) {
      return res.status(403).json({
        code: 403,
        message: "无权限下载该文件",
        data: null,
      });
    }
    
    // 处理安全下载
    await videoUtils.handleSecureDownload(file, req, res);
    
  } catch (error) {
    console.error("安全下载失败:", error);
    if (!res.headersSent) {
      res.status(500).json({
        code: 500,
        message: error.message || "下载失败",
        data: null,
      });
    }
  }
});

/**
 * @api {get} /api/video/download/:bvid
 * @description 直接下载视频（兼容旧版本）
 * @access Protected - 需要用户登录
 */
router.get("/download/:bvid", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const { bvid } = req.params;
    const userId = req.user.uid || req.user.id;
    
    // 构造文件名
    const fileName = `${bvid}.mp4`;
    
    // 检查用户是否有权限下载该文件
    const hasPermission = await videoUtils.checkDownloadPermission(fileName, userId);
    if (!hasPermission) {
      return res.status(403).json({
        code: 403,
        message: "无权限下载该文件，请先添加下载权限",
        data: null,
      });
    }
    
    // 处理安全下载
    await videoUtils.handleSecureDownload(fileName, req, res);
    
  } catch (error) {
    console.error("直接下载失败:", error);
    if (!res.headersSent) {
      res.status(500).json({
        code: 500,
        message: error.message || "下载失败",
        data: null,
      });
    }
  }
});

/**
 * @api {get} /api/video/available
 * @description 获取所有可下载的视频列表（公开接口）
 * @access Public
 */
router.get("/available", async (req, res) => {
  try {
    const { limit = 20, offset = 0 } = req.query;
    // 确保参数是有效的数字，避免传递NaN
    const parsedLimit = parseInt(limit);
    const parsedOffset = parseInt(offset);
    const validLimit = Math.max(1, Math.min(100, isNaN(parsedLimit) ? 20 : parsedLimit));
    const validOffset = Math.max(0, isNaN(parsedOffset) ? 0 : parsedOffset);
    
    const result = await videoUtils.getAvailableVideos(
      validLimit, 
      validOffset
    );
    
    res.status(200).json({
      code: 200,
      message: "成功获取可下载视频列表",
      data: result,
    });
  } catch (error) {
    console.error("获取可下载视频列表失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "获取视频列表失败",
      data: null,
    });
  }
});

/**
 * @api {post} /api/video/add-download-permission
 * @description 添加视频下载权限
 * @access Protected - 需要用户登录
 * @body { "bvid": "视频BVID" }
 */
router.post("/add-download-permission", authorize(["1", "2", "3", "4"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { bvid } = req.body;
    
    if (!bvid || !bvid.trim()) {
      return res.status(400).json({
        code: 400,
        message: "请提供有效的视频BVID",
        data: null,
      });
    }
    
    const result = await videoUtils.addVideoDownloader(userId, bvid.trim());
    
    res.status(200).json({
      code: 200,
      message: result.message,
      data: result,
    });
  } catch (error) {
    console.error("添加下载权限失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "添加下载权限失败",
      data: null,
    });
  }
});

/**
 * @api {get} /api/video/my-permissions/:bvid
 * @description 查看用户对特定视频的权限
 * @access Protected - 需要用户登录
 */
router.get("/my-permissions/:bvid", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { bvid } = req.params;
    
    // 检查用户对该视频的权限
    const fileName = `${bvid}.mp4`;
    const hasPermission = await videoUtils.checkDownloadPermission(fileName, userId);
    
    if (hasPermission) {
      // 获取具体的关系类型
      const db = require("../../config/db").promise();
      const [relations] = await db.execute(
        `SELECT uv.relation_type, uv.created_at, v.title 
         FROM user_videos uv 
         INNER JOIN videos v ON uv.video_id = v.id 
         WHERE uv.user_id = ? AND v.bvid = ?`,
        [userId, bvid]
      );
      
      if (relations.length > 0) {
        const relation = relations[0];
        res.status(200).json({
          code: 200,
          message: "有权限访问该视频",
          data: {
            hasPermission: true,
            relationType: relation.relation_type,
            relationDesc: videoUtils.getRelationTypeDesc ? videoUtils.getRelationTypeDesc(relation.relation_type) : relation.relation_type,
            addedAt: relation.created_at,
            videoTitle: relation.title
          },
        });
      } else {
        res.status(200).json({
          code: 200,
          message: "无权限访问该视频",
          data: { hasPermission: false },
        });
      }
    } else {
      res.status(200).json({
        code: 200,
        message: "无权限访问该视频",
        data: { hasPermission: false },
      });
    }
  } catch (error) {
    console.error("查询权限失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "查询权限失败",
      data: null,
    });
  }
});

module.exports = router;
// model/video/videoUtils.js

const axios = require("axios");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");
const { v4: uuidv4 } = require("uuid");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const db = require("../../config/db").promise();
const bilibiliUtils = require("../bilibili/bilibiliUtils");
const { Worker } = require("worker_threads");
const EventEmitter = require("events");

// 配置路径
const DOWNLOAD_DIR = path.join(__dirname, "../../downloads"); // 临时下载目录
const VIDEO_DIR = path.join(__dirname, "../../videos"); // 最终视频存储目录
const FFMPEG_PATH = "ffmpeg"; // FFmpeg 可执行文件路径，确保已安装并在 PATH 中
const FFPROBE_PATH = "ffprobe"; // FFprobe 可执行文件路径，用于检测视频信息

// 确保目录存在
if (!fs.existsSync(DOWNLOAD_DIR)) {
  fs.mkdirSync(DOWNLOAD_DIR, { recursive: true });
  console.log(`📁 创建临时下载目录: ${DOWNLOAD_DIR}`);
}

if (!fs.existsSync(VIDEO_DIR)) {
  fs.mkdirSync(VIDEO_DIR, { recursive: true });
  console.log(`📁 创建视频存储目录: ${VIDEO_DIR}`);
}

// 视频合并队列管理系统
class VideoMergeQueue extends EventEmitter {
  constructor(maxConcurrent = 2) {
    super();
    this.maxConcurrent = maxConcurrent; // 最大并发数
    this.currentTasks = 0; // 当前运行任务数
    this.queue = []; // 任务队列
    this.taskStatus = new Map(); // 任务状态存储
  }

  // 添加合并任务到队列
  addTask(taskId, videoPath, audioPath, outputPath, progressCallback) {
    return new Promise((resolve, reject) => {
      const task = {
        id: taskId,
        videoPath,
        audioPath,
        outputPath,
        progressCallback,
        resolve,
        reject,
        status: 'queued',
        createdAt: Date.now()
      };

      this.queue.push(task);
      this.taskStatus.set(taskId, {
        status: 'queued',
        progress: 0,
        createdAt: Date.now()
      });

      console.log(`📋 任务 ${taskId} 已加入队列，当前队列长度: ${this.queue.length}`);
      this.processQueue();
    });
  }

  // 处理队列
  async processQueue() {
    if (this.currentTasks >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }

    const task = this.queue.shift();
    this.currentTasks++;
    
    task.status = 'processing';
    this.taskStatus.set(task.id, {
      status: 'processing',
      progress: 0,
      startedAt: Date.now()
    });

    console.log(`🔧 开始处理任务 ${task.id}，当前并发数: ${this.currentTasks}`);

    try {
      await this.executeMergeTask(task);
      task.resolve();
      this.taskStatus.set(task.id, {
        status: 'completed',
        progress: 100,
        completedAt: Date.now()
      });
      console.log(`✅ 任务 ${task.id} 完成`);
    } catch (error) {
      task.reject(error);
      this.taskStatus.set(task.id, {
        status: 'failed',
        error: error.message,
        failedAt: Date.now()
      });
      console.error(`❌ 任务 ${task.id} 失败:`, error.message);
    } finally {
      this.currentTasks--;
      // 清理过期的任务状态（保留1小时）
      this.cleanupExpiredTasks();
      // 继续处理队列中的下一个任务
      this.processQueue();
    }
  }

  // 执行合并任务
  async executeMergeTask(task) {
    return new Promise(async (resolve, reject) => {
      const { videoPath, audioPath, outputPath, progressCallback, id } = task;
      
      // 设置FFmpeg事件处理器的通用函数
      const setupFFmpegHandlers = (ffmpegProcess) => {
        let duration = null;
        
        ffmpegProcess.stderr.on("data", (data) => {
          const output = data.toString();
          
          // 提取总时长
          if (!duration) {
            const durationMatch = output.match(/Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})/);
            if (durationMatch) {
              const hours = parseInt(durationMatch[1]);
              const minutes = parseInt(durationMatch[2]);
              const seconds = parseInt(durationMatch[3]);
              duration = hours * 3600 + minutes * 60 + seconds;
            }
          }
          
          // 提取当前进度
          if (duration) {
            const timeMatch = output.match(/time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})/);
            if (timeMatch) {
              const hours = parseInt(timeMatch[1]);
              const minutes = parseInt(timeMatch[2]);
              const seconds = parseInt(timeMatch[3]);
              const currentTime = hours * 3600 + minutes * 60 + seconds;
              const progress = (currentTime / duration * 100).toFixed(2);
              
              // 更新任务状态
              this.taskStatus.set(id, {
                status: 'processing',
                progress: parseFloat(progress),
                currentTime,
                duration,
                updatedAt: Date.now()
              });
              
              // 调用进度回调
              if (progressCallback) {
                progressCallback(progress, currentTime, duration);
              }
            }
          }
        });

        ffmpegProcess.on("close", (code) => {
          if (code === 0) {
            resolve();
          } else {
            reject(new Error(`FFmpeg 合并失败，退出代码: ${code}`));
          }
        });

        ffmpegProcess.on("error", (error) => {
          reject(error);
        });
      };
      
      try {
        // 检测视频编码格式
        console.log(`🔍 正在检测视频编码格式: ${videoPath}`);
        const codecInfo = await detectVideoCodec(videoPath);
        
        // 根据编码格式和鸿蒙兼容性选择处理方式
        let videoCodecArgs;
        if (codecInfo.isHarmonyCompatible) {
          // H.264格式，鸿蒙兼容，直接复制
          console.log(`✅ 检测到H.264编码，使用快速复制模式`);
          videoCodecArgs = ["-c:v", "copy"];
        } else {
          // 非H.264格式（如H.265），需要转码为H.264以兼容鸿蒙
          console.log(`⚠️ 检测到${codecInfo.codec_name}编码，转码为H.264以兼容鸿蒙系统`);
          videoCodecArgs = [
            "-c:v", "libx264",
            "-preset", "fast",
            "-crf", "23",
            "-profile:v", "high",
            "-level", "4.1"
          ];
        }
        
        const ffmpegArgs = [
          "-i", videoPath,
          "-i", audioPath,
          ...videoCodecArgs,
          "-c:a", "aac",
          "-b:a", "128k",
          "-movflags", "+faststart", // 优化网络播放
          "-strict", "experimental",
          "-y", // 覆盖输出文件
          outputPath,
        ];
        
        console.log(`🎬 开始合并视频，FFmpeg参数:`, ffmpegArgs.join(' '));
        const ffmpeg = spawn(FFMPEG_PATH, ffmpegArgs);
        
        // 存储编码信息到任务状态中
        const taskStatus = this.taskStatus.get(id);
        if (taskStatus) {
          taskStatus.codecInfo = codecInfo;
          taskStatus.processingMode = codecInfo.isHarmonyCompatible ? 'copy' : 'transcode';
        }
        
        // 为正常流程的ffmpeg设置进度处理器
        setupFFmpegHandlers(ffmpeg);
      } catch (codecError) {
         console.error(`❌ 视频编码检测失败，使用默认H.264转码模式:`, codecError.message);
         // 检测失败时，使用安全的H.264转码模式
         const ffmpeg = spawn(FFMPEG_PATH, [
           "-i", videoPath,
           "-i", audioPath,
           "-c:v", "libx264",
           "-preset", "fast",
           "-crf", "23",
           "-c:a", "aac",
           "-b:a", "128k",
           "-movflags", "+faststart",
           "-y",
           outputPath,
         ]);
         
         // 为错误处理分支也添加进度处理
         setupFFmpegHandlers(ffmpeg);
       }
       
       // 为正常流程的ffmpeg也设置处理器
       if (typeof ffmpeg !== 'undefined') {
         setupFFmpegHandlers(ffmpeg);
       }
     });
  }

  // 获取任务状态
  getTaskStatus(taskId) {
    return this.taskStatus.get(taskId) || { status: 'not_found' };
  }

  // 获取队列状态
  getQueueStatus() {
    return {
      queueLength: this.queue.length,
      currentTasks: this.currentTasks,
      maxConcurrent: this.maxConcurrent,
      totalTasks: this.taskStatus.size
    };
  }

  // 清理过期任务状态
  cleanupExpiredTasks() {
    const oneHourAgo = Date.now() - (60 * 60 * 1000);
    for (const [taskId, status] of this.taskStatus.entries()) {
      const lastUpdate = status.completedAt || status.failedAt || status.updatedAt || status.createdAt;
      if (lastUpdate < oneHourAgo && ['completed', 'failed'].includes(status.status)) {
        this.taskStatus.delete(taskId);
      }
    }
  }
}

// 创建全局队列实例
const videoMergeQueue = new VideoMergeQueue(2); // 最大并发数为2

/**
 * 检测视频编码格式
 * @param {string} videoPath - 视频文件路径
 * @returns {Promise<Object>} 视频编码信息
 */
function detectVideoCodec(videoPath) {
  return new Promise((resolve, reject) => {
    const ffprobe = spawn(FFPROBE_PATH, [
      "-v", "quiet",
      "-print_format", "json",
      "-show_streams",
      "-select_streams", "v:0", // 只选择第一个视频流
      videoPath
    ]);

    let output = "";
    let errorOutput = "";

    ffprobe.stdout.on("data", (data) => {
      output += data.toString();
    });

    ffprobe.stderr.on("data", (data) => {
      errorOutput += data.toString();
    });

    ffprobe.on("close", (code) => {
      if (code !== 0) {
        console.error(`❌ FFprobe 检测失败:`, errorOutput);
        reject(new Error(`FFprobe 检测失败: ${errorOutput}`));
        return;
      }

      try {
        const result = JSON.parse(output);
        const videoStream = result.streams[0];
        
        if (!videoStream) {
          reject(new Error("未找到视频流"));
          return;
        }

        const codecInfo = {
          codec_name: videoStream.codec_name,
          codec_long_name: videoStream.codec_long_name,
          profile: videoStream.profile,
          level: videoStream.level,
          width: videoStream.width,
          height: videoStream.height,
          bit_rate: videoStream.bit_rate,
          duration: videoStream.duration,
          isH264: videoStream.codec_name === "h264",
          isH265: videoStream.codec_name === "hevc" || videoStream.codec_name === "h265",
          isHarmonyCompatible: videoStream.codec_name === "h264" // 鸿蒙系统兼容性
        };

        console.log(`🔍 视频编码检测结果: ${codecInfo.codec_name} (${codecInfo.codec_long_name})`);
        resolve(codecInfo);
      } catch (parseError) {
        console.error(`❌ 解析FFprobe输出失败:`, parseError.message);
        reject(new Error(`解析FFprobe输出失败: ${parseError.message}`));
      }
    });

    ffprobe.on("error", (error) => {
      console.error(`❌ FFprobe 启动失败:`, error.message);
      reject(new Error(`FFprobe 启动失败: ${error.message}`));
    });
  });
}

// 视频质量映射
const QUALITY_MAP = {
  120: "4K 超清",
  116: "1080P60 高清",
  112: "1080P+ 高清",
  80: "1080P 高清",
  74: "720P60 高清",
  64: "720P 高清",
  32: "480P 清晰",
  16: "360P 流畅"
};

/**
 * 提取BVID从URL
 * @param {string} url - 视频URL或BVID
 * @returns {string} BVID
 */
function extractBVID(url) {
  if (url.startsWith('BV')) {
    return url;
  }
  const bvidMatch = url.match(/BV[a-zA-Z0-9]+/);
  if (bvidMatch) {
    return bvidMatch[0];
  }
  throw new Error('无法从URL中提取BVID');
}

/**
 * 解析B站视频信息（使用B站账号Cookie）
 * @param {string} url - 视频URL或BVID
 * @param {string} cookieString - B站账号Cookie
 * @param {number} quality - 视频质量
 * @returns {Promise<Object>} 视频信息
 */
async function parseVideoInfo(url, cookieString, quality = 80) {
  try {
    const bvid = extractBVID(url);
    console.log(`🔍 正在解析视频信息: ${bvid}`);
    
    // 获取视频信息和下载链接
    const videoInfo = await bilibiliUtils.getBilibiliVideoInfo(bvid, cookieString);
    
    const result = {
      bvid: bvid,
      aid: videoInfo.aid || null,
      title: videoInfo.title,
      description: videoInfo.description,
      duration: videoInfo.duration,
      view: videoInfo.stat.view,
      danmaku: videoInfo.stat.danmaku,
      like: videoInfo.stat.like,
      coin: videoInfo.stat.coin,
      share: videoInfo.stat.share,
      reply: videoInfo.stat.reply,
      favorite: videoInfo.stat.favorite,
      owner: {
        mid: videoInfo.owner.mid,
        name: videoInfo.owner.name,
        face: videoInfo.owner.face || null
      },
      pubdate: videoInfo.pubdate || null,
      pic: videoInfo.pic,
      pages: videoInfo.pages || [],
      cid: videoInfo.cid || null,
      tname: videoInfo.tname || null,
      current_viewers: videoInfo.stat.now_rank || 0,
      quality: quality,
      qualityDesc: QUALITY_MAP[quality] || '未知画质',
      downloadUrls: videoInfo.downloadUrls,
      videoUrl: videoInfo.downloadUrls.video,
      audioUrl: videoInfo.downloadUrls.audio,
      fileSize: null // 文件大小需要在下载时获取
    };
    
    console.log(`✅ 视频信息解析完成: ${result.title}`);
    return result;
  } catch (error) {
    console.error(`❌ 解析视频信息失败:`, error.message);
    throw new Error(`解析视频信息失败: ${error.message}`);
  }
}

/**
 * 下载文件（支持进度回调）
 * @param {string} url - 下载链接
 * @param {string} filePath - 保存路径
 * @param {string} cookieString - B站Cookie
 * @param {Function} progressCallback - 进度回调函数
 * @returns {Promise<void>}
 */
async function downloadFile(url, filePath, cookieString, progressCallback) {
  try {
    console.log(`⬇️ 开始下载文件: ${path.basename(filePath)}`);
    
    const response = await axios({
      method: "GET",
      url: url,
      responseType: "stream",
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Referer": "https://www.bilibili.com/",
        "Cookie": cookieString,
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"
      },
      timeout: 30000
    });

    const totalLength = parseInt(response.headers['content-length'], 10);
    let downloadedLength = 0;

    const writer = fs.createWriteStream(filePath);
    
    response.data.on('data', (chunk) => {
      downloadedLength += chunk.length;
      if (progressCallback && totalLength) {
        const progress = (downloadedLength / totalLength * 100).toFixed(2);
        progressCallback(progress, downloadedLength, totalLength);
      }
    });
    
    response.data.pipe(writer);

    return new Promise((resolve, reject) => {
      writer.on("finish", () => {
        console.log(`✅ 文件下载完成: ${path.basename(filePath)}`);
        resolve();
      });
      writer.on("error", (error) => {
        console.error(`❌ 文件下载失败: ${path.basename(filePath)}`, error);
        reject(error);
      });
    });
  } catch (error) {
    console.error(`❌ 下载文件失败: ${path.basename(filePath)}`, error.message);
    throw error;
  }
}

/**
 * 使用 FFmpeg 合并视频和音频（支持进度回调）- 队列版本
 * @param {string} videoPath - 视频文件路径
 * @param {string} audioPath - 音频文件路径
 * @param {string} outputPath - 输出文件路径
 * @param {Function} progressCallback - 进度回调函数
 * @returns {Promise<void>}
 */
function mergeVideoAndAudio(videoPath, audioPath, outputPath, progressCallback) {
  // 生成唯一任务ID
  const taskId = `merge_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  console.log(`🔧 将视频合并任务加入队列: ${path.basename(outputPath)} (任务ID: ${taskId})`);
  
  // 将任务添加到队列中
  return videoMergeQueue.addTask(taskId, videoPath, audioPath, outputPath, progressCallback);
}

/**
 * 获取合并任务状态
 * @param {string} taskId - 任务ID
 * @returns {Object} 任务状态
 */
function getMergeTaskStatus(taskId) {
  return videoMergeQueue.getTaskStatus(taskId);
}

/**
 * 获取合并队列状态
 * @returns {Object} 队列状态
 */
function getMergeQueueStatus() {
  return videoMergeQueue.getQueueStatus();
}

/**
 * 直接执行合并（不使用队列，用于紧急情况）
 * @param {string} videoPath - 视频文件路径
 * @param {string} audioPath - 音频文件路径
 * @param {string} outputPath - 输出文件路径
 * @param {Function} progressCallback - 进度回调函数
 * @returns {Promise<void>}
 */
function mergeVideoAndAudioDirect(videoPath, audioPath, outputPath, progressCallback) {
  return new Promise((resolve, reject) => {
    console.log(`🔧 直接合并视频和音频: ${path.basename(outputPath)}`);

    const ffmpeg = spawn(FFMPEG_PATH, [
      "-i", videoPath,
      "-i", audioPath,
      "-c:v", "copy",
      "-c:a", "aac",
      "-strict", "experimental",
      "-y", // 覆盖输出文件
      outputPath,
    ]);

    let duration = null;
    
    ffmpeg.stderr.on("data", (data) => {
      const output = data.toString();
      
      // 提取总时长
      if (!duration) {
        const durationMatch = output.match(/Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})/);
        if (durationMatch) {
          const hours = parseInt(durationMatch[1]);
          const minutes = parseInt(durationMatch[2]);
          const seconds = parseInt(durationMatch[3]);
          duration = hours * 3600 + minutes * 60 + seconds;
        }
      }
      
      // 提取当前进度
      if (duration && progressCallback) {
        const timeMatch = output.match(/time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})/);
        if (timeMatch) {
          const hours = parseInt(timeMatch[1]);
          const minutes = parseInt(timeMatch[2]);
          const seconds = parseInt(timeMatch[3]);
          const currentTime = hours * 3600 + minutes * 60 + seconds;
          const progress = (currentTime / duration * 100).toFixed(2);
          progressCallback(progress, currentTime, duration);
        }
      }
    });

    ffmpeg.on("close", (code) => {
      if (code === 0) {
        console.log(`✅ 视频合并完成: ${path.basename(outputPath)}`);
        resolve();
      } else {
        console.error(`❌ FFmpeg 进程退出，代码: ${code}`);
        reject(new Error(`FFmpeg 合并失败，退出代码: ${code}`));
      }
    });

    ffmpeg.on("error", (error) => {
      console.error(`❌ FFmpeg 启动失败:`, error);
      reject(error);
    });
  });
}

/**
 * 将视频信息保存到数据库
 * @param {Object} videoInfo - 视频信息
 * @param {string} filePath - 文件路径
 * @param {string} playUrl - 播放地址
 * @param {number} userId - 用户ID
 * @param {number} bilibiliAccountId - B站账号ID
 * @returns {Promise<Object>} 数据库记录
 */
async function saveOrUpdateVideoInDb(videoInfo, filePath, playUrl, userId, bilibiliAccountId) {
  try {
    console.log(`💾 保存视频信息到数据库: ${videoInfo.title}`);

    // 检查视频是否已存在（根据bvid）
    const [existingVideos] = await db.execute(
      "SELECT * FROM videos WHERE bvid = ?",
      [videoInfo.bvid]
    );

    let videoId;
    let isNewVideo = false;

    if (existingVideos.length > 0) {
      // 更新现有记录
      videoId = existingVideos[0].id;
      await db.execute(
        `UPDATE videos SET 
         title = ?, pic = ?, view = ?, danmaku = ?, \`like\` = ?, 
         coin = ?, favorite = ?, share = ?, reply = ?, 
         name = ?, face = ?, pubdate = ?, 
         quality = ?, \`desc\` = ?, duration = ?, aid = ?, download_link = ?,
         cid = ?, tname = ?, current_viewers = ?
         WHERE bvid = ?`,
        [
          videoInfo.title,
          videoInfo.pic || "",
          videoInfo.view || 0,
          videoInfo.danmaku || 0,
          videoInfo.like || 0,
          videoInfo.coin || 0,
          videoInfo.favorite || 0,
          videoInfo.share || 0,
          videoInfo.reply || 0,
          videoInfo.owner?.name || "未知",
          videoInfo.owner?.face || "",
          videoInfo.pubdate || "",
          videoInfo.quality || 80,
          videoInfo.description || "",
          videoInfo.duration || 0,
          videoInfo.aid || "",
          playUrl,
          videoInfo.cid || "",
          videoInfo.tname || "",
          videoInfo.current_viewers || 0,
          videoInfo.bvid
        ]
      );
      
      console.log(`✅ 视频信息已更新: ${videoInfo.title}`);
    } else {
      // 插入新记录
      const [result] = await db.execute(
        `INSERT INTO videos (
          bvid, aid, title, pic, view, danmaku, \`like\`, coin, favorite, share, reply,
          name, face, pubdate, quality, \`desc\`, duration, download_link, cid, tname, current_viewers
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [  
          videoInfo.bvid,
          videoInfo.aid || "",
          videoInfo.title,
          videoInfo.pic || "",
          videoInfo.view || 0,
          videoInfo.danmaku || 0,
          videoInfo.like || 0,
          videoInfo.coin || 0,
          videoInfo.favorite || 0,
          videoInfo.share || 0,
          videoInfo.reply || 0,
          videoInfo.owner?.name || "未知",
          videoInfo.owner?.face || "",
          videoInfo.pubdate || "",
          videoInfo.quality || 80,
          videoInfo.description || "",
          videoInfo.duration || 0,
          playUrl,
          videoInfo.cid || "",
          videoInfo.tname || "",
          videoInfo.current_viewers || 0
        ]
      );
      
      videoId = result.insertId;
      isNewVideo = true;
      console.log(`✅ 视频信息已保存: ${videoInfo.title}`);
    }

    // 检查用户视频关联关系是否已存在
    const [existingRelation] = await db.execute(
      "SELECT * FROM user_videos WHERE user_id = ? AND video_id = ? AND relation_type = 'processor'",
      [userId, videoId]
    );

    if (existingRelation.length === 0) {
      // 创建用户视频关联关系（处理者）
      await db.execute(
        "INSERT INTO user_videos (user_id, video_id, relation_type) VALUES (?, ?, 'processor')",
        [userId, videoId]
      );
      console.log(`🔗 已创建用户视频关联关系: 用户${userId} -> 视频${videoId}`);
    }

    // 如果视频有UP主信息，尝试创建UP主关联关系
    if (videoInfo.owner?.mid) {
      // 这里可以扩展：如果系统中有对应的UP主用户，可以创建owner关联
      // 暂时只记录processor关联
    }

    return { 
      id: videoId, 
      updated: !isNewVideo,
      title: videoInfo.title,
      bvid: videoInfo.bvid,
      filePath: filePath,
      playUrl: playUrl
    };
  } catch (error) {
    console.error('❌ 保存视频信息到数据库失败:', error);
    throw error;
  }
}


/**
 * 获取所有视频列表
 * @returns {Promise<Array>} 视频列表
 */
async function listAllVideos() {
  try {
    const [videos] = await db.execute(
      `SELECT * FROM videos ORDER BY id DESC`
    );
    return videos;
  } catch (error) {
    console.error(`❌ 获取视频列表失败:`, error);
    throw error;
  }
}

/**
 * 获取用户处理的视频列表
 * @param {number} userId - 用户ID
 * @returns {Promise<Array>} 视频列表
 */
async function getUserVideos(userId) {
  try {
    console.log(`🔍 获取用户 ${userId} 的视频列表`);
    
    // 通过user_videos关联表查询用户相关的视频
    const [videos] = await db.execute(
      `SELECT v.*, uv.relation_type, uv.created_at as relation_created_at
       FROM videos v 
       INNER JOIN user_videos uv ON v.id = uv.video_id 
       WHERE uv.user_id = ? 
       ORDER BY uv.created_at DESC, v.id DESC`,
      [userId]
    );
    
    console.log(`✅ 找到 ${videos.length} 个相关视频`);
    
    // 为每个视频添加关系类型的中文描述
    const videosWithRelationDesc = videos.map(video => ({
      ...video,
      relation_desc: getRelationTypeDesc(video.relation_type)
    }));
    
    return videosWithRelationDesc;
  } catch (error) {
    console.error(`❌ 获取用户视频列表失败:`, error);
    throw error;
  }
}

/**
 * 获取关系类型的中文描述
 * @param {string} relationType - 关系类型
 * @returns {string} 中文描述
 */
function getRelationTypeDesc(relationType) {
  const relationMap = {
    'owner': 'UP主',
    'processor': '处理者',
    'downloader': '下载者'
  };
  return relationMap[relationType] || '未知关系';
}

/**
 * 删除视频记录和文件
 * @param {number} videoId - 视频ID
 * @param {number} userId - 用户ID
 * @param {boolean} deleteFile - 是否删除文件
 * @returns {Promise<void>}
 */
async function deleteVideo(videoId, userId, deleteFile = false) {
  try {
    console.log(`🗑️ 用户 ${userId} 尝试删除视频 ${videoId}`);
    
    // 检查用户是否有权限删除该视频（必须是处理者或下载者）
    const [userVideoRelations] = await db.execute(
      `SELECT uv.*, v.title, v.bvid, v.download_link 
       FROM user_videos uv 
       INNER JOIN videos v ON uv.video_id = v.id 
       WHERE uv.user_id = ? AND uv.video_id = ? 
       AND uv.relation_type IN ('processor', 'downloader')`,
      [userId, videoId]
    );
    
    if (userVideoRelations.length === 0) {
      throw new Error('无权限删除该视频：您不是该视频的处理者或下载者');
    }
    
    const videoInfo = userVideoRelations[0];
    console.log(`✅ 权限验证通过，用户是视频的${getRelationTypeDesc(videoInfo.relation_type)}`);
    
    // 获取完整视频信息
    const [videos] = await db.execute(
      "SELECT * FROM videos WHERE id = ?",
      [videoId]
    );
    
    if (videos.length === 0) {
      throw new Error('视频不存在');
    }
    
    const video = videos[0];
    
    // 删除用户视频关联记录
    await db.execute(
      "DELETE FROM user_videos WHERE video_id = ?", 
      [videoId]
    );
    console.log(`🔗 已删除用户视频关联记录`);
    
    // 删除视频记录
    await db.execute("DELETE FROM videos WHERE id = ?", [videoId]);
    console.log(`📝 已删除视频数据库记录`);
    
    // 删除文件
    if (deleteFile) {
      // 尝试从download_link推断文件路径
      let filePath = null;
      if (video.download_link) {
        // 从下载链接中提取文件名
        const fileName = video.download_link.split('/').pop();
        filePath = path.join(VIDEO_DIR, fileName);
      }
      
      // 如果有file_path字段，优先使用
      if (video.file_path) {
        filePath = video.file_path;
      }
      
      if (filePath && fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`🗑️ 已删除视频文件: ${filePath}`);
      } else if (filePath) {
        console.warn(`⚠️ 视频文件不存在: ${filePath}`);
      } else {
        console.warn(`⚠️ 无法确定视频文件路径`);
      }
    }
    
    console.log(`✅ 成功删除视频: ${video.title} (${video.bvid})`);
  } catch (error) {
    console.error(`❌ 删除视频失败:`, error);
    throw error;
  }
}

/**
 * 处理视频请求的主函数
 * @param {Object} options - 处理选项
 * @returns {Promise<Object>} 处理结果
 */
async function processVideoRequest(options) {
  const {
    url,
    userId,
    cookieString,
    quality = 80,
    downloadMode = "auto",
    bilibiliAccountId
  } = options;
  
  try {
    // 0. 提取BVID进行预检查
    const bvid = extractBVID(url);
    if (!bvid) {
      throw new Error('无法从URL中提取BVID');
    }
    
    // 1. 检查数据库和文件是否已存在（优化：避免重复解析）
    const finalFileName = `${bvid}.mp4`;
    const finalVideoPath = path.join(VIDEO_DIR, finalFileName);
    
    // 检查数据库中是否已有记录
    const [existingRecords] = await db.execute(
      'SELECT * FROM videos WHERE bvid = ?',
      [bvid]
    );
    
    // 检查文件是否存在
    const fileExists = fs.existsSync(finalVideoPath);
    
    if (existingRecords.length > 0 && fileExists) {
      console.log(`✅ 发现已存在的视频记录和文件: ${bvid}`);
      
      // 只解析基本信息用于更新数据库
      const videoInfo = await parseVideoInfo(url, cookieString, quality);
      
      // 生成播放地址
      const serverPort = process.env.PORT || 3000;
      const serverHost = process.env.SERVER_HOST || 'localhost';
      const playUrl = `http://${serverHost}:${serverPort}/api/video/download/${finalFileName}`;
      
      // 更新数据库记录（保持文件路径不变）
      const existingRecord = existingRecords[0];
      await db.execute(
        `UPDATE videos SET 
         title = ?, pic = ?, view = ?, danmaku = ?, \`like\` = ?, 
         coin = ?, favorite = ?, share = ?, reply = ?, 
         name = ?, face = ?, pubdate = ?, 
         quality = ?, \`desc\` = ?, duration = ?, aid = ?, download_link = ?,
         cid = ?, tname = ?, current_viewers = ?
         WHERE id = ?`,
        [
          videoInfo.title,
          videoInfo.pic || "",
          videoInfo.view || 0,
          videoInfo.danmaku || 0,
          videoInfo.like || 0,
          videoInfo.coin || 0,
          videoInfo.favorite || 0,
          videoInfo.share || 0,
          videoInfo.reply || 0,
          videoInfo.owner?.name || "未知",
          videoInfo.owner?.face || "",
          videoInfo.pubdate || "",
          videoInfo.quality || 80,
          videoInfo.description || "",
          videoInfo.duration || 0,
          videoInfo.aid || "",
          playUrl,
          videoInfo.cid || "",
          videoInfo.tname || "",
          videoInfo.current_viewers || 0,
          existingRecord.id
        ]
      );
      
      console.log(`🔄 已更新现有视频记录: ${videoInfo.title}`);
      
      return {
        id: existingRecord.id,
        updated: true,
        title: videoInfo.title,
        bvid: bvid,
        filePath: finalVideoPath,
        playUrl: playUrl,
        message: "视频已存在，仅更新数据库信息",
        downloadMode,
        qualityDesc: videoInfo.qualityDesc,
        skippedProcessing: true // 标记跳过了处理过程
      };
    }
    
    console.log(`🆕 开始处理新视频或重新处理: ${bvid}`);
    
    // 2. 解析视频信息（完整解析用于下载）
    const videoInfo = await parseVideoInfo(url, cookieString, quality);

    // 3. 创建文件名和路径
    const uniqueId = uuidv4().substring(0, 8);
    const tempVideoFileName = `${videoInfo.bvid}_${uniqueId}_video.mp4`;
    const tempAudioFileName = `${videoInfo.bvid}_${uniqueId}_audio.mp3`;
    const tempOutputFileName = `${videoInfo.bvid}_${uniqueId}_temp.mp4`;
    // finalFileName 已在前面声明过，这里不需要重复声明

    const tempVideoPath = path.join(DOWNLOAD_DIR, tempVideoFileName);
    const tempAudioPath = path.join(DOWNLOAD_DIR, tempAudioFileName);
    const tempOutputPath = path.join(DOWNLOAD_DIR, tempOutputFileName);
    // finalVideoPath 也已在前面声明过，这里不需要重复声明

    // 4. 下载视频和音频
    console.log(`📥 开始下载视频和音频...`);
    
    const downloadPromises = [];
    
    if (downloadMode === "video" || downloadMode === "auto") {
      downloadPromises.push(
        downloadFile(videoInfo.videoUrl, tempVideoPath, cookieString, (progress) => {
          console.log(`📹 视频下载进度: ${progress}%`);
        })
      );
    }
    
    if (downloadMode === "audio" || downloadMode === "auto") {
      downloadPromises.push(
        downloadFile(videoInfo.audioUrl, tempAudioPath, cookieString, (progress) => {
          console.log(`🎵 音频下载进度: ${progress}%`);
        })
      );
    }
    
    await Promise.all(downloadPromises);

    // 5. 合并视频和音频（如果都下载了）
    let tempFinalPath = tempOutputPath;
    if (downloadMode === "auto" && fs.existsSync(tempVideoPath) && fs.existsSync(tempAudioPath)) {
      console.log(`🔧 开始合并视频和音频: ${finalFileName}`);
      await mergeVideoAndAudio(tempVideoPath, tempAudioPath, tempOutputPath, (progress) => {
        console.log(`🔧 合并进度: ${progress}%`);
      });
      
      // 清理临时文件
      try {
        fs.unlinkSync(tempVideoPath);
        fs.unlinkSync(tempAudioPath);
        console.log(`🗑️ 清理临时文件完成`);
      } catch (cleanupError) {
        console.warn(`⚠️ 清理临时文件失败:`, cleanupError.message);
      }
    } else if (downloadMode === "video" && fs.existsSync(tempVideoPath)) {
      tempFinalPath = tempVideoPath;
    } else if (downloadMode === "audio" && fs.existsSync(tempAudioPath)) {
      tempFinalPath = tempAudioPath;
    }

    // 6. 移动文件到最终目录
    if (fs.existsSync(tempFinalPath)) {
      // 如果最终文件已存在，先删除
      if (fs.existsSync(finalVideoPath)) {
        fs.unlinkSync(finalVideoPath);
        console.log(`🗑️ 删除已存在的文件: ${finalFileName}`);
      }
      
      fs.renameSync(tempFinalPath, finalVideoPath);
      console.log(`📁 文件已移动到: ${finalVideoPath}`);
    } else {
      throw new Error('处理后的视频文件不存在');
    }

    // 7. 生成播放地址 - 使用SERVER_HOST配置
    const serverPort = process.env.PORT || 3000;
    const serverHost = process.env.SERVER_HOST || 'localhost';
    const playUrl = `http://${serverHost}:${serverPort}/api/video/download/${finalFileName}`;

    // 8. 保存到数据库
    const dbRecord = await saveOrUpdateVideoInDb(videoInfo, finalVideoPath, playUrl, userId, bilibiliAccountId);

    return {
      ...dbRecord,
      message: "视频处理完成",
      downloadMode,
      qualityDesc: videoInfo.qualityDesc,
      playUrl: playUrl
    };
  } catch (error) {
    console.error(`❌ 处理视频请求失败:`, error);
    throw error;
  }
}

/**
 * 批量处理视频
 * @param {Object} options - 批量处理选项
 * @returns {Promise<Object>} 批量处理结果
 */
async function batchProcessVideos(options) {
  const {
    urls,
    userId,
    cookieString,
    quality = 80,
    downloadMode = "auto",
    bilibiliAccountId
  } = options;
  
  const results = {
    success: [],
    failed: [],
    total: urls.length
  };
  
  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    try {
      console.log(`📦 批量处理进度: ${i + 1}/${urls.length} - ${url}`);
      
      const result = await processVideoRequest({
        url,
        userId,
        cookieString,
        quality,
        downloadMode,
        bilibiliAccountId
      });
      
      results.success.push({
        url,
        result,
        index: i + 1
      });
      
      // 添加延迟避免请求过于频繁
      if (i < urls.length - 1) {
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
      
    } catch (error) {
      console.error(`❌ 批量处理第 ${i + 1} 个视频失败:`, error.message);
      results.failed.push({
        url,
        error: error.message,
        index: i + 1
      });
    }
  }
  
  return results;
}

/**
 * 生成安全下载token
 * @param {string} fileName - 文件名
 * @param {string} userId - 用户ID
 * @param {number} expiresIn - 过期时间（秒），默认1小时
 * @returns {string} JWT token
 */
function generateDownloadToken(fileName, userId, expiresIn = 3600) {
  const payload = {
    fileName,
    userId,
    type: 'download',
    timestamp: Date.now()
  };
  
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
}

/**
 * 验证下载token
 * @param {string} token - JWT token
 * @returns {object|null} 解码后的payload或null
 */
function verifyDownloadToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    console.error('Token验证失败:', error.message);
    return null;
  }
}

/**
 * 生成临时下载链接
 * @param {string} fileName - 文件名
 * @param {string} userId - 用户ID
 * @returns {object} 包含下载链接和token的对象
 */
function generateSecureDownloadLink(fileName, userId) {
  const token = generateDownloadToken(fileName, userId, 3600); // 1小时有效期
  const serverPort = process.env.PORT || 3000;
  const serverHost = process.env.SERVER_HOST || 'localhost';
  
  return {
    downloadUrl: `http://${serverHost}:${serverPort}/api/video/secure-download?token=${token}&file=${encodeURIComponent(fileName)}`,
    token,
    expiresAt: new Date(Date.now() + 3600 * 1000).toISOString()
  };
}

/**
 * 检查用户是否有权限下载指定文件
 * @param {string} fileName - 文件名
 * @param {string} userId - 用户ID
 * @returns {Promise<boolean>} 是否有权限
 */
async function checkDownloadPermission(fileName, userId) {
  try {
    console.log(`🔐 检查用户 ${userId} 对文件 ${fileName} 的下载权限`);
    
    // 从文件名提取BVID
    const bvid = fileName.replace(/\.(mp4|mp3)$/, '');
    
    // 通过user_videos关联表检查用户是否有权限访问该视频
    const [userVideoRelations] = await db.execute(
      `SELECT uv.relation_type, v.title, v.bvid 
       FROM user_videos uv 
       INNER JOIN videos v ON uv.video_id = v.id 
       WHERE uv.user_id = ? AND v.bvid = ?`,
      [userId, bvid]
    );
    
    if (userVideoRelations.length > 0) {
      const relation = userVideoRelations[0];
      console.log(`✅ 用户有权限下载，关系类型: ${getRelationTypeDesc(relation.relation_type)}`);
      return true;
    }
    
    console.log(`❌ 用户无权限下载该视频: ${bvid}`);
    return false;
  } catch (error) {
    console.error('检查下载权限失败:', error);
    return false;
  }
}

/**
 * 安全文件下载处理
 * @param {string} fileName - 文件名
 * @param {object} req - Express请求对象
 * @param {object} res - Express响应对象
 */
async function handleSecureDownload(fileName, req, res) {
  try {
    const filePath = path.join(VIDEO_DIR, fileName);
    
    // 检查文件是否存在
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        code: 404,
        message: '文件不存在'
      });
    }
    
    // 获取文件信息
    const stat = fs.statSync(filePath);
    const fileSize = stat.size;
    
    // 设置响应头，支持断点续传
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(fileName)}"`);
    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Content-Length', fileSize);
    
    // 处理Range请求（断点续传）
    const range = req.headers.range;
    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = (end - start) + 1;
      
      res.status(206);
      res.setHeader('Content-Range', `bytes ${start}-${end}/${fileSize}`);
      res.setHeader('Content-Length', chunksize);
      
      const stream = fs.createReadStream(filePath, { start, end });
      stream.pipe(res);
    } else {
      // 完整文件下载
      const stream = fs.createReadStream(filePath);
      stream.pipe(res);
    }
    
  } catch (error) {
    console.error('安全下载处理失败:', error);
    res.status(500).json({
      code: 500,
      message: '下载失败'
    });
  }
}

/**
 * 检查用户每日下载申请限制
 * @param {number} userId - 用户ID
 * @param {string} userRole - 用户权限等级
 * @param {Object} redis - Redis连接实例
 * @returns {Promise<Object>} 检查结果
 */
async function checkDailyDownloadLimit(userId, userRole, redis) {
  try {
    // 根据用户权限等级设置每日限制
    const dailyLimits = {
      '1': 1,    // 1级权限：每天1个
      '2': 10,   // 2级权限：每天10个
      '3': 100,  // 3级权限：每天100个
      '4': -1    // 4级权限：无限制
    };
    
    const limit = dailyLimits[userRole] || 1; // 默认1级权限
    
    // 4级权限无限制
    if (limit === -1) {
      return { allowed: true, remaining: -1 };
    }
    
    // 获取今日申请次数的Redis键
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD格式
    const redisKey = `download_requests:${userId}:${today}`;
    
    // 获取当前申请次数
    const currentCount = await redis.get(redisKey) || 0;
    const remaining = limit - parseInt(currentCount);
    
    if (remaining <= 0) {
      const roleNames = { '1': '1级', '2': '2级', '3': '3级', '4': '4级' };
      return {
        allowed: false,
        message: `您的${roleNames[userRole]}权限每日只能申请${limit}个视频下载权限，今日已达上限。明日00:00重置。`,
        remaining: 0
      };
    }
    
    return { allowed: true, remaining };
  } catch (error) {
    console.error('检查每日下载限制失败:', error);
    throw error;
  }
}

/**
 * 增加用户每日下载申请计数
 * @param {number} userId - 用户ID
 * @param {Object} redis - Redis连接实例
 */
async function incrementDailyDownloadCount(userId, redis) {
  try {
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD格式
    const redisKey = `download_requests:${userId}:${today}`;
    
    // 增加计数
    await redis.incr(redisKey);
    
    // 设置过期时间到明日00:00
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    const secondsUntilMidnight = Math.floor((tomorrow.getTime() - Date.now()) / 1000);
    
    await redis.expire(redisKey, secondsUntilMidnight);
    
    console.log(`📊 用户${userId}今日申请计数已更新，过期时间：${secondsUntilMidnight}秒后`);
  } catch (error) {
    console.error('更新每日下载计数失败:', error);
    throw error;
  }
}

/**
 * 添加用户视频关联关系（下载者）
 * @param {number} userId - 用户ID
 * @param {string} bvid - 视频BVID
 * @returns {Promise<Object>} 操作结果
 */
async function addVideoDownloader(userId, bvid) {
  const redis = require('../../config/redis');
  
  try {
    console.log(`🔗 用户 ${userId} 请求添加视频 ${bvid} 的下载权限`);
    
    // 获取用户信息和权限等级
    const [users] = await db.execute(
      "SELECT lv.role FROM loginverification lv WHERE lv.uid = ?",
      [userId]
    );
    
    if (users.length === 0) {
      throw new Error('用户不存在');
    }
    
    const userRole = users[0].role;
    
    // 检查视频是否存在
    const [videos] = await db.execute(
      "SELECT id, title FROM videos WHERE bvid = ?",
      [bvid]
    );
    
    if (videos.length === 0) {
      throw new Error('视频不存在');
    }
    
    const video = videos[0];
    
    // 检查用户是否已有该视频的关联关系
    const [existingRelations] = await db.execute(
      "SELECT relation_type FROM user_videos WHERE user_id = ? AND video_id = ?",
      [userId, video.id]
    );
    
    if (existingRelations.length > 0) {
      const existingType = existingRelations[0].relation_type;
      return {
        success: true,
        message: `您已经是该视频的${getRelationTypeDesc(existingType)}，无需重复添加`,
        existingRelation: existingType
      };
    }
    
    // 检查是否为自己的视频（上传者或处理者不受限制）
    const [ownerRelations] = await db.execute(
      "SELECT relation_type FROM user_videos WHERE user_id = ? AND video_id = ? AND relation_type IN ('uploader', 'processor')",
      [userId, video.id]
    );
    
    if (ownerRelations.length === 0) {
      // 不是自己的视频，需要检查每日申请限制
      const dailyLimit = await checkDailyDownloadLimit(userId, userRole, redis);
      if (!dailyLimit.allowed) {
        throw new Error(dailyLimit.message);
      }
    }
    
    // 添加下载者关系
    await db.execute(
      "INSERT INTO user_videos (user_id, video_id, relation_type) VALUES (?, ?, 'downloader')",
      [userId, video.id]
    );
    
    // 如果不是自己的视频，增加今日申请计数
    if (ownerRelations.length === 0) {
      await incrementDailyDownloadCount(userId, redis);
    }
    
    console.log(`✅ 成功添加下载者关系: 用户${userId} -> 视频${video.title}`);
    
    return {
      success: true,
      message: '成功添加下载权限',
      videoTitle: video.title,
      bvid: bvid
    };
  } catch (error) {
    console.error('添加视频下载者关系失败:', error);
    throw error;
  }
}

/**
 * 获取所有可下载的视频列表（公开列表）
 * @param {number} limit - 限制数量
 * @param {number} offset - 偏移量
 * @returns {Promise<Object>} 视频列表和总数
 */
async function getAvailableVideos(limit = 20, offset = 0) {
  try {
    // 确保参数是有效的数字
    const parsedLimit = parseInt(limit);
    const parsedOffset = parseInt(offset);
    const validLimit = Math.max(1, Math.min(100, isNaN(parsedLimit) ? 20 : parsedLimit));
    const validOffset = Math.max(0, isNaN(parsedOffset) ? 0 : parsedOffset);
    
    console.log(`📋 获取可下载视频列表，限制: ${validLimit}, 偏移: ${validOffset}`);
    
    // 获取总数
    const [countResult] = await db.execute(
      "SELECT COUNT(*) as total FROM videos"
    );
    const total = countResult[0].total;
    
    // 获取视频列表（简化查询）
    // 将参数转换为字符串以解决MySQL 8.0.22的已知问题
    const limitStr = String(validLimit);
    const offsetStr = String(validOffset);
    
    console.log('SQL参数调试信息:');
    console.log('limitStr:', limitStr, 'type:', typeof limitStr);
    console.log('offsetStr:', offsetStr, 'type:', typeof offsetStr);
    
    const [videos] = await db.execute(
      `SELECT * FROM videos 
       ORDER BY id DESC 
       LIMIT ? OFFSET ?`,
      [limitStr, offsetStr]
    );
    
    // 为每个视频获取用户数量和处理者信息
    for (let video of videos) {
      // 获取用户数量
      const [userCountResult] = await db.execute(
        'SELECT COUNT(*) as count FROM user_videos WHERE video_id = ?',
        [video.id]
      );
      video.user_count = userCountResult[0].count;
      
      // 获取处理者列表
      const [processorsResult] = await db.execute(
        `SELECT DISTINCT u.username 
         FROM user_videos uv 
         INNER JOIN user u ON uv.user_id = u.id 
         WHERE uv.video_id = ? AND uv.relation_type = 'processor'`,
        [video.id]
      );
      video.processors = processorsResult.map(p => p.username).join(',');
    }
    
    console.log(`✅ 找到 ${videos.length} 个可下载视频`);
    
    return {
      videos: videos.map(video => ({
        ...video,
        processors: video.processors ? video.processors.split(',').slice(0, 3) : []
      })),
      total,
      limit: validLimit,
      offset: validOffset,
      hasMore: validOffset + validLimit < total
    };
  } catch (error) {
    console.error('获取可下载视频列表失败:', error);
    throw error;
  }
}

module.exports = {
  parseVideoInfo,
  downloadFile,
  mergeVideoAndAudio,
  mergeVideoAndAudioDirect,
  getMergeTaskStatus,
  getMergeQueueStatus,
  saveOrUpdateVideoInDb,
  listAllVideos,
  getUserVideos,
  deleteVideo,
  processVideoRequest,
  batchProcessVideos,
  extractBVID,
  QUALITY_MAP,
  generateDownloadToken,
  verifyDownloadToken,
  generateSecureDownloadLink,
  checkDownloadPermission,
  handleSecureDownload,
  addVideoDownloader,
  getAvailableVideos,
  checkDailyDownloadLimit,
  incrementDailyDownloadCount,
  detectVideoCodec,
  // 队列管理相关
  videoMergeQueue
};
// app.js
const express = require("express");
const cors = require("cors");
const http = require("http");
require("dotenv").config();

const { startHeartbeats } = require("./config/heartbeat");
const userRouter = require("./model/user/userRouters");
const videoRouter = require("./model/video/videoRouters"); // 【新增】导入视频路由
const dailyLimitRouter = require("./model/video/dailyLimitRoutes"); // 【新增】导入每日限制路由
const bilibiliRouter = require("./model/bilibili/bilibiliRouters"); // 【新增】导入B站路由

const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 3000;

// --- 中间件 ---
app.use(cors()); // 启用 CORS
app.use(express.json()); // 解析 JSON 请求体

// --- 静态文件服务 ---
// 提供视频文件的直接访问服务
// 移除静态文件服务 - 改为安全的token验证下载方案
// const path = require("path");
// const serveIndex = require("serve-index");
// const videoDir = path.join(__dirname, "videos");
// app.use("/api/videos", express.static(videoDir), serveIndex(videoDir, { icons: true }));

// --- 路由 ---
app.use("/api", userRouter); // 挂载用户路由，建议添加前缀 /user
app.use("/api/video", videoRouter); // 【新增】挂载视频路由，统一前缀 /video
app.use("/api/video", dailyLimitRouter); // 【新增】挂载每日限制路由，统一前缀 /video
app.use("/api/bilibili", bilibiliRouter); // 【新增】挂载B站路由，统一前缀 /bilibili

// --- 启动服务 ---
startHeartbeats(); // 启动数据库和 Redis 的心跳检测

server.listen(port, "0.0.0.0", () => {
  console.log(`✅ 服务器已成功启动，正在监听端口：http://0.0.0.0:${port}`);
});
