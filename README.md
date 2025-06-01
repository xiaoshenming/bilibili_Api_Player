// modle\auth\authUtils.js
const jwt = require('jsonwebtoken');
const redis = require('../../config/redis');
require('dotenv').config();
const secret = process.env.JWT_SECRET;

// 定义一个辅助函数，用来检查 Redis 中的 JWT
async function checkJWTInRedis(userId, token, deviceType) {
    const storedToken = await redis.get(`user_${userId}_${deviceType}_token`);
    return storedToken === token;
}

// 定义鉴权中间件函数，支持传入允许的角色数组
function authorize(roles = []) {
    return async (req, res, next) => {
        console.log('开始权限验证，目标角色:', roles);

        const authHeader = req.headers.authorization;
        const deviceType = req.headers.devicetype; // 从请求头中获取设备类型
        if (!authHeader) {
            console.log('未提供授权信息');
            return res.status(401).json({
                code: 401,
                message: '未提供授权信息',
                data: null
            });
        }

        const token = authHeader.split(' ')[1];
        console.log('接收到的 Token:', token);
        try {
            const decoded = jwt.verify(token, secret);
            console.log('JWT 解码成功:', decoded);
            const isValid = await checkJWTInRedis(decoded.id, token, deviceType);

            if (!isValid) {
                console.log('Redis 中无效 Token');
                return res.status(401).json({
                    code: 401,
                    message: '无效的 Token',
                    data: null
                });
            }
            // 重置 token 在 Redis 中的有效期到 3600 秒
            await redis.expire(`user_${decoded.id}_${deviceType}_token`, 3600);

            console.log('用户角色：', decoded.role);
            if (roles.length && !roles.includes(decoded.role)) {
                console.log(`用户角色 ${decoded.role} 无权限访问`);
                return res.status(403).json({
                    code: 403,
                    message: `权限不足，用户角色 ${decoded.role} 无权限访问此资源`,
                    data: null
                });
            }

            console.log('权限验证通过');
            req.user = decoded; // 将解码后的用户信息存入请求对象
            next();
        } catch (err) {
            console.error('权限验证错误:', err.message);
            return res.status(401).json({
                code: 401,
                message: '无效的 Token',
                data: null
            });
        }
    };
}

module.exports = authorize;

const express = require("express");
const router = express.Router();
const bilibiliUtils = require("./bilibiliUtils");
const authorize = require("../auth/authUtils"); // 授权中间件
const axios = require("axios");

// B站请求头
const BILIBILI_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0',
  'Accept': '*/*',
  'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
  'Accept-Encoding': 'gzip, deflate',
  'Referer': 'https://www.bilibili.com/',
  'Connection': 'keep-alive'
};

// --- B站登录相关接口 ---

/**
 * 生成B站登录二维码
 * POST /api/bilibili/generate-qrcode
 * 需要用户登录
 */
router.post("/generate-qrcode", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id; // 从JWT中获取用户ID
    
    const result = await bilibiliUtils.generateBilibiliQRCode(userId);
    
    res.json({
      code: 200,
      message: "二维码生成成功",
      data: result
    });
  } catch (error) {
    console.error("生成B站二维码失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "生成二维码失败",
      data: null
    });
  }
});

/**
 * 获取B站登录状态
 * GET /api/bilibili/login-status/:sessionId
 * 需要用户登录
 */
router.get("/login-status/:sessionId", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const { sessionId } = req.params;
    
    const status = await bilibiliUtils.getBilibiliLoginStatus(sessionId);
    
    res.json({
      code: 200,
      message: "获取状态成功",
      data: status
    });
  } catch (error) {
    console.error("获取B站登录状态失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "获取状态失败",
      data: null
    });
  }
});

/**
 * 获取用户的B站账号列表
 * GET /api/bilibili/accounts
 * 需要用户登录
 */
router.get("/accounts", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    
    const accounts = await bilibiliUtils.getUserBilibiliAccounts(userId);
    
    res.json({
      code: 200,
      message: "获取账号列表成功",
      data: accounts
    });
  } catch (error) {
    console.error("获取B站账号列表失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "获取账号列表失败",
      data: null
    });
  }
});

/**
 * 切换B站账号状态
 * PUT /api/bilibili/accounts/:accountId/toggle
 * 需要用户登录
 */
router.put("/accounts/:accountId/toggle", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { accountId } = req.params;
    const { isActive } = req.body;
    
    await bilibiliUtils.toggleBilibiliAccountStatus(userId, accountId, isActive);
    
    res.json({
      code: 200,
      message: "账号状态更新成功",
      data: null
    });
  } catch (error) {
    console.error("切换B站账号状态失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "状态更新失败",
      data: null
    });
  }
});

/**
 * 删除B站账号
 * DELETE /api/bilibili/accounts/:accountId
 * 需要用户登录
 */
router.delete("/accounts/:accountId", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { accountId } = req.params;
    
    await bilibiliUtils.deleteBilibiliAccount(userId, accountId);
    
    res.json({
      code: 200,
      message: "账号删除成功",
      data: null
    });
  } catch (error) {
    console.error("删除B站账号失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "删除账号失败",
      data: null
    });
  }
});

// --- B站视频解析相关接口 ---

/**
 * 解析B站视频信息
 * GET /api/bilibili/parse-video
 * 需要用户登录，使用用户的B站账号
 */
router.get("/parse-video", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { input } = req.query;
    
    if (!input) {
      return res.status(400).json({
        code: 400,
        message: "输入不能为空",
        data: null
      });
    }
    
    // 获取用户的活跃B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }
    
    // 提取BVID
    const bvid = extractBvid(input);
    if (!bvid) {
      return res.status(400).json({
        code: 400,
        message: "无法解析BVID",
        data: null
      });
    }
    
    // 获取视频信息
    const videoInfo = await getVideoInfo(bvid, bilibiliAccount.cookie_string);
    if (!videoInfo) {
      return res.status(400).json({
        code: 400,
        message: "未能解析视频信息",
        data: null
      });
    }
    
    // 获取播放信息
    const playInfo = await getPlayInfo(bvid, videoInfo.cid, bilibiliAccount.cookie_string);
    if (!playInfo) {
      return res.status(500).json({
        code: 500,
        message: "无法获取播放信息",
        data: null
      });
    }
    
    res.json({
      code: 200,
      message: "解析成功",
      data: {
        bvid: videoInfo.bvid,
        cid: videoInfo.cid,
        title: videoInfo.title,
        desc: videoInfo.desc,
        type: videoInfo.tname,
        play_info: playInfo
      }
    });
    
  } catch (error) {
    console.error("解析B站视频失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "解析视频失败",
      data: null
    });
  }
});

/**
 * 解析B站视频详细信息（包含下载链接）
 * GET /api/bilibili/parse-videos
 * 需要用户登录，使用用户的B站账号
 */
router.get("/parse-videos", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { input } = req.query;
    
    if (!input) {
      return res.status(400).json({
        code: 400,
        message: "输入不能为空",
        data: null
      });
    }
    
    // 获取用户的活跃B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }
    
    // 提取BVID
    const bvid = extractBvid(input);
    if (!bvid) {
      return res.status(400).json({
        code: 400,
        message: "无法解析BVID",
        data: null
      });
    }
    
    // 获取视频信息
    const videoInfo = await getVideoInfo(bvid, bilibiliAccount.cookie_string);
    if (!videoInfo) {
      return res.status(400).json({
        code: 400,
        message: "未能解析视频信息",
        data: null
      });
    }
    
    // 获取播放信息
    const playInfo = await getPlayInfo(bvid, videoInfo.cid, bilibiliAccount.cookie_string);
    if (!playInfo) {
      return res.status(500).json({
        code: 500,
        message: "无法获取播放信息",
        data: null
      });
    }
    
    res.json({
      code: 200,
      message: "解析成功",
      data: {
        videoUrl: playInfo.dash?.video?.[0]?.backupUrl?.[0] || playInfo.dash?.video?.[0]?.baseUrl,
        audioUrl: playInfo.dash?.audio?.[0]?.backupUrl?.[0] || playInfo.dash?.audio?.[0]?.baseUrl,
        bvid: videoInfo.bvid,
        aid: videoInfo.aid,
        cid: videoInfo.cid,
        tname: videoInfo.tname,
        pic: videoInfo.pic,
        title: videoInfo.title,
        desc: videoInfo.desc,
        duration: videoInfo.duration,
        pubdate: videoInfo.pubdate,
        name: videoInfo.owner?.name,
        face: videoInfo.owner?.face,
        view: videoInfo.stat?.view,
        danmaku: videoInfo.stat?.danmaku,
        reply: videoInfo.stat?.reply,
        favorite: videoInfo.stat?.favorite,
        coin: videoInfo.stat?.coin,
        share: videoInfo.stat?.share,
        like: videoInfo.stat?.like
      }
    });
    
  } catch (error) {
    console.error("解析B站视频详情失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "解析视频失败",
      data: null
    });
  }
});

/**
 * 下载B站视频
 * GET /api/bilibili/download
 * 需要用户登录，使用用户的B站账号
 */
router.get("/download", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const userId = req.user.uid || req.user.id;
    const { bvid, cid, quality = 80 } = req.query;
    
    if (!bvid || !cid) {
      return res.status(400).json({
        code: 400,
        message: "缺少必要参数 bvid 或 cid",
        data: null
      });
    }
    
    // 获取用户的活跃B站账号
    const bilibiliAccount = await bilibiliUtils.getActiveBilibiliAccount(userId);
    if (!bilibiliAccount) {
      return res.status(400).json({
        code: 400,
        message: "请先登录B站账号",
        data: null
      });
    }
    
    // 获取播放信息
    const playInfo = await getPlayInfo(bvid, cid, bilibiliAccount.cookie_string);
    if (!playInfo) {
      return res.status(500).json({
        code: 500,
        message: "无法获取播放信息",
        data: null
      });
    }
    
    let videoUrl = null;
    const audioUrl = playInfo.dash?.audio?.[0]?.baseUrl;
    
    // 根据清晰度选择视频URL
    for (const video of playInfo.dash?.video || []) {
      if (video.id == quality) {
        videoUrl = video.baseUrl;
        break;
      }
    }
    
    // 如果没找到指定清晰度，使用第一个
    if (!videoUrl && playInfo.dash?.video?.length > 0) {
      videoUrl = playInfo.dash.video[0].baseUrl;
    }
    
    if (!videoUrl || !audioUrl) {
      return res.status(500).json({
        code: 500,
        message: "未找到视频或音频下载地址",
        data: null
      });
    }
    
    res.json({
      code: 200,
      message: "获取下载链接成功",
      data: {
        videoUrl,
        audioUrl,
        bvid,
        cid,
        quality
      }
    });
    
  } catch (error) {
    console.error("获取下载链接失败:", error);
    res.status(500).json({
      code: 500,
      message: error.message || "获取下载链接失败",
      data: null
    });
  }
});

// --- 辅助函数 ---

/**
 * 提取BVID
 * @param {string} input - 用户输入
 * @returns {string|null} BVID
 */
function extractBvid(input) {
  if (input.startsWith("https://www.bilibili.com/video/")) {
    const startIdx = input.indexOf("BV");
    const endIdx = input.indexOf("?", startIdx);
    if (endIdx === -1) {
      return input.substring(startIdx);
    }
    return input.substring(startIdx, endIdx);
  } else if (input.startsWith("BV")) {
    return input;
  }
  return null;
}

/**
 * 获取视频信息
 * @param {string} bvid - BVID
 * @param {string} cookieString - Cookie字符串
 * @returns {Object|null} 视频信息
 */
async function getVideoInfo(bvid, cookieString) {
  try {
    const response = await axios.get(
      `https://api.bilibili.com/x/web-interface/view?bvid=${bvid}`,
      {
        headers: {
          ...BILIBILI_HEADERS,
          'Cookie': cookieString
        }
      }
    );
    
    if (response.data && response.data.code === 0) {
      return response.data.data;
    }
    return null;
  } catch (error) {
    console.error('获取视频信息失败:', error);
    return null;
  }
}

/**
 * 获取播放信息
 * @param {string} bvid - BVID
 * @param {string} cid - CID
 * @param {string} cookieString - Cookie字符串
 * @returns {Object|null} 播放信息
 */
async function getPlayInfo(bvid, cid, cookieString) {
  try {
    const response = await axios.get(
      `https://api.bilibili.com/x/player/playurl?bvid=${bvid}&cid=${cid}&fnval=4048&fnver=0&fourk=1`,
      {
        headers: {
          ...BILIBILI_HEADERS,
          'Cookie': cookieString
        }
      }
    );
    
    if (response.data && response.data.code === 0) {
      return response.data.data;
    }
    return null;
  } catch (error) {
    console.error('获取播放信息失败:', error);
    return null;
  }
}

module.exports = router;
const db = require("../../config/db");
const redis = require("../../config/redis");
const axios = require("axios");
const QRCode = require("qrcode");
const { v4: uuidv4 } = require("uuid");

// B站请求头
const BILIBILI_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0',
  'Accept': '*/*',
  'Accept-Language': 'zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2',
  'Accept-Encoding': 'gzip, deflate',
  'Referer': 'https://www.bilibili.com/',
  'Connection': 'keep-alive',
  'Upgrade-Insecure-Requests': '1',
  'Sec-Fetch-Dest': 'document',
  'Sec-Fetch-Mode': 'navigate',
  'Sec-Fetch-Site': 'same-origin',
  'Sec-Fetch-User': '?1',
  'Priority': 'u=1',
  'TE': 'trailers'
};

/**
 * 生成B站登录二维码
 * @param {number} userId - 用户ID
 * @returns {Object} 包含二维码key和图片base64的对象
 */
async function generateBilibiliQRCode(userId) {
  try {
    // 调用B站API生成二维码
    const response = await axios.get(
      'https://passport.bilibili.com/x/passport-login/web/qrcode/generate?source=main_web',
      { headers: BILIBILI_HEADERS }
    );

    if (response.data && response.data.code === 0) {
      const { url, qrcode_key } = response.data.data;
      
      // 生成唯一的会话ID
      const sessionId = uuidv4();
      
      // 将二维码信息存储到Redis，设置10分钟过期
      await redis.setex(`bilibili_qr_${sessionId}`, 600, JSON.stringify({
        userId,
        qrcode_key,
        url,
        status: 'waiting',
        created_at: new Date().toISOString()
      }));

      // 生成二维码图片
      const qrCodeDataURL = await QRCode.toDataURL(url);
      
      // 启动轮询检查登录状态
      pollBilibiliLoginStatus(sessionId, qrcode_key);
      
      return {
        sessionId,
        qrcode_key,
        qrCodeImage: qrCodeDataURL,
        status: 'waiting'
      };
    } else {
      throw new Error('生成二维码失败');
    }
  } catch (error) {
    console.error('生成B站二维码失败:', error);
    throw new Error('生成二维码失败: ' + error.message);
  }
}

/**
 * 轮询检查B站登录状态
 * @param {string} sessionId - 会话ID
 * @param {string} qrcode_key - 二维码key
 */
async function pollBilibiliLoginStatus(sessionId, qrcode_key) {
  const maxAttempts = 120; // 最多轮询2分钟
  let attempts = 0;
  
  const poll = async () => {
    try {
      attempts++;
      
      // 检查会话是否还存在
      const sessionData = await redis.get(`bilibili_qr_${sessionId}`);
      if (!sessionData) {
        console.log(`会话 ${sessionId} 已过期或不存在`);
        return;
      }
      
      const session = JSON.parse(sessionData);
      
      // 调用B站API检查登录状态
      const response = await axios.get(
        `https://passport.bilibili.com/x/passport-login/web/qrcode/poll?qrcode_key=${qrcode_key}&source=navUserCenterLogin`,
        { headers: BILIBILI_HEADERS }
      );
      
      if (response.data && response.data.data) {
        const { code, url, message } = response.data.data;
        
        if (code === 0 && url) {
          // 登录成功，获取cookie
          await handleSuccessfulLogin(sessionId, session.userId, url);
          return;
        } else if (code === 86038) {
          // 二维码已过期
          await updateSessionStatus(sessionId, 'expired', '二维码已过期');
          return;
        } else if (code === 86101) {
          // 未扫码
          await updateSessionStatus(sessionId, 'waiting', '等待扫码');
        } else if (code === 86090) {
          // 已扫码，等待确认
          await updateSessionStatus(sessionId, 'scanned', '已扫码，等待确认');
        }
      }
      
      // 继续轮询
      if (attempts < maxAttempts) {
        setTimeout(poll, 1000); // 1秒后再次检查
      } else {
        await updateSessionStatus(sessionId, 'timeout', '登录超时');
      }
    } catch (error) {
      console.error('轮询B站登录状态失败:', error);
      if (attempts < maxAttempts) {
        setTimeout(poll, 2000); // 出错时2秒后重试
      }
    }
  };
  
  poll();
}

/**
 * 处理登录成功
 * @param {string} sessionId - 会话ID
 * @param {number} userId - 用户ID
 * @param {string} loginUrl - 登录URL
 */
async function handleSuccessfulLogin(sessionId, userId, loginUrl) {
  try {
    console.log('开始处理登录成功，URL:', loginUrl);
    
    let cookieObj = {};
    let cookieString = '';
    
    // 方法1: 从URL参数中解析cookie（适用于crossDomain类型的URL）
    try {
      const urlObj = new URL(loginUrl);
      const urlParams = urlObj.searchParams;
      
      // 检查URL参数中是否包含cookie信息
      if (urlParams.has('DedeUserID') && urlParams.has('bili_jct')) {
        cookieObj.DedeUserID = urlParams.get('DedeUserID');
        cookieObj.bili_jct = urlParams.get('bili_jct');
        cookieObj.SESSDATA = urlParams.get('SESSDATA') || '';
        cookieObj.DedeUserID__ckMd5 = urlParams.get('DedeUserID__ckMd5') || '';
        
        cookieString = `DedeUserID=${cookieObj.DedeUserID}; bili_jct=${cookieObj.bili_jct}; SESSDATA=${cookieObj.SESSDATA}; DedeUserID__ckMd5=${cookieObj.DedeUserID__ckMd5}; `;
        console.log('从URL参数中解析到cookie:', cookieObj);
      }
    } catch (urlError) {
      console.log('URL解析失败，尝试其他方法:', urlError.message);
    }
    
    // 方法2: 如果URL解析失败，尝试访问登录URL获取cookie
    if (!cookieObj.DedeUserID || !cookieObj.bili_jct) {
      console.log('尝试通过HTTP请求获取cookie');
      
      try {
        const response = await axios.get(loginUrl, {
          headers: {
            ...BILIBILI_HEADERS,
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
          },
          maxRedirects: 10,
          timeout: 10000,
          validateStatus: function (status) {
            return status >= 200 && status < 400;
          }
        });
        
        const cookies = response.headers['set-cookie'];
        console.log('HTTP响应headers:', response.headers);
        console.log('HTTP响应cookie:', cookies);
        
        if (cookies && cookies.length > 0) {
          cookies.forEach(cookie => {
            const parts = cookie.split(';')[0].split('=');
            if (parts.length === 2) {
              cookieObj[parts[0]] = parts[1];
              cookieString += `${parts[0]}=${parts[1]}; `;
            }
          });
        }
        
        // 检查响应体是否包含cookie信息
        if (response.data && typeof response.data === 'object') {
          console.log('HTTP响应数据:', response.data);
          
          // 检查是否有cookie_info字段
          if (response.data.cookie_info && response.data.cookie_info.cookies) {
            response.data.cookie_info.cookies.forEach(cookie => {
              cookieObj[cookie.name] = cookie.value;
              cookieString += `${cookie.name}=${cookie.value}; `;
            });
          }
        }
      } catch (httpError) {
        console.log('HTTP请求失败:', httpError.message);
      }
    }
    
    // 方法3: 尝试解析URL中的所有参数
    if (!cookieObj.DedeUserID || !cookieObj.bili_jct) {
      console.log('尝试解析URL中的所有参数');
      
      // 使用更强的正则表达式解析URL参数
      const paramRegex = /[?&]([^=&]+)=([^&]*)/g;
      let match;
      
      while ((match = paramRegex.exec(loginUrl)) !== null) {
        const key = decodeURIComponent(match[1]);
        const value = decodeURIComponent(match[2]);
        
        if (['DedeUserID', 'bili_jct', 'SESSDATA', 'DedeUserID__ckMd5', 'sid'].includes(key)) {
          cookieObj[key] = value;
          cookieString += `${key}=${value}; `;
        }
      }
    }
    
    const dedeuserid = cookieObj.DedeUserID;
    const bili_jct = cookieObj.bili_jct;
    const sessdata = cookieObj.SESSDATA;
    
    console.log('最终解析的cookie:', { dedeuserid, bili_jct, sessdata, cookieString });
    
    if (!dedeuserid || !bili_jct) {
      throw new Error(`登录cookie不完整: DedeUserID=${dedeuserid}, bili_jct=${bili_jct}, SESSDATA=${sessdata}`);
    }
    
    // 获取用户信息
    const userInfo = await getBilibiliUserInfo(dedeuserid, cookieString);
    
    // 保存到数据库
    await saveBilibiliAccount({
      userId,
      dedeuserid,
      bili_jct,
      cookieString: cookieString.trim(),
      nickname: userInfo.nickname,
      avatar: userInfo.avatar
    });
    
    // 更新会话状态
    await updateSessionStatus(sessionId, 'success', '登录成功', {
      dedeuserid,
      nickname: userInfo.nickname,
      avatar: userInfo.avatar
    });
    
  } catch (error) {
    console.error('处理登录成功失败:', error);
    await updateSessionStatus(sessionId, 'error', '登录处理失败: ' + error.message);
  }
}

/**
 * 获取B站用户信息
 * @param {string} dedeuserid - B站用户ID
 * @param {string} cookieString - Cookie字符串
 * @returns {Object} 用户信息
 */
async function getBilibiliUserInfo(dedeuserid, cookieString) {
  try {
    console.log(`🔍 开始获取B站用户信息: dedeuserid=${dedeuserid}`);
    console.log(`🍪 使用的Cookie: ${cookieString}`);
    
    // 方法1: 尝试使用用户空间信息API
    try {
      const response = await axios.get(
        `https://api.bilibili.com/x/space/acc/info?mid=${dedeuserid}`,
        {
          headers: {
            ...BILIBILI_HEADERS,
            'Cookie': cookieString,
            'Referer': 'https://space.bilibili.com/',
            'Origin': 'https://space.bilibili.com'
          },
          timeout: 10000
        }
      );
      
      console.log(`📡 API响应状态: ${response.status}`);
      console.log(`📡 API响应数据:`, response.data);
      
      if (response.data && response.data.code === 0 && response.data.data) {
        const data = response.data.data;
        const userInfo = {
          nickname: data.name || '未知用户',
          avatar: data.face || ''
        };
        console.log(`✅ 成功获取用户信息:`, userInfo);
        return userInfo;
      } else {
        console.log(`⚠️ API返回错误: code=${response.data?.code}, message=${response.data?.message}`);
      }
    } catch (apiError) {
      console.log(`❌ 用户空间API请求失败:`, apiError.message);
    }
    
    // 方法2: 尝试使用导航栏用户信息API
    try {
      console.log(`🔄 尝试使用导航栏API获取用户信息`);
      const navResponse = await axios.get(
        'https://api.bilibili.com/x/web-interface/nav',
        {
          headers: {
            ...BILIBILI_HEADERS,
            'Cookie': cookieString,
            'Referer': 'https://www.bilibili.com/',
            'Origin': 'https://www.bilibili.com'
          },
          timeout: 10000
        }
      );
      
      console.log(`📡 导航API响应:`, navResponse.data);
      
      if (navResponse.data && navResponse.data.code === 0 && navResponse.data.data) {
        const data = navResponse.data.data;
        const userInfo = {
          nickname: data.uname || '未知用户',
          avatar: data.face || ''
        };
        console.log(`✅ 通过导航API获取用户信息:`, userInfo);
        return userInfo;
      }
    } catch (navError) {
      console.log(`❌ 导航API请求失败:`, navError.message);
    }
    
    // 方法3: 使用dedeuserid作为默认用户名
    console.log(`⚠️ 所有API都失败，使用dedeuserid作为用户名`);
    return {
      nickname: `用户${dedeuserid}`,
      avatar: ''
    };
    
  } catch (error) {
    console.error('获取B站用户信息失败:', error);
    return {
      nickname: `用户${dedeuserid || '未知'}`,
      avatar: ''
    };
  }
}

/**
 * 保存B站账号信息到数据库
 * @param {Object} accountData - 账号数据
 */
async function saveBilibiliAccount(accountData) {
  const connection = await db.promise().getConnection();
  
  try {
    await connection.beginTransaction();
    
    // 检查是否已存在该B站账号
    const [existing] = await connection.query(
      'SELECT id FROM bilibili_accounts WHERE user_id = ? AND dedeuserid = ?',
      [accountData.userId, accountData.dedeuserid]
    );
    
    if (existing.length > 0) {
      // 更新现有记录
      await connection.query(
        `UPDATE bilibili_accounts SET 
         bili_jct = ?, cookie_string = ?, nickname = ?, avatar = ?, 
         is_active = 1, login_time = NOW(), updated_at = NOW()
         WHERE user_id = ? AND dedeuserid = ?`,
        [
          accountData.bili_jct,
          accountData.cookieString,
          accountData.nickname,
          accountData.avatar,
          accountData.userId,
          accountData.dedeuserid
        ]
      );
    } else {
      // 插入新记录
      await connection.query(
        `INSERT INTO bilibili_accounts 
         (user_id, dedeuserid, bili_jct, cookie_string, nickname, avatar, login_time)
         VALUES (?, ?, ?, ?, ?, ?, NOW())`,
        [
          accountData.userId,
          accountData.dedeuserid,
          accountData.bili_jct,
          accountData.cookieString,
          accountData.nickname,
          accountData.avatar
        ]
      );
    }
    
    await connection.commit();
    console.log(`B站账号保存成功: 用户${accountData.userId} - ${accountData.nickname}`);
    
  } catch (error) {
    await connection.rollback();
    console.error('保存B站账号失败:', error);
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * 更新会话状态
 * @param {string} sessionId - 会话ID
 * @param {string} status - 状态
 * @param {string} message - 消息
 * @param {Object} data - 额外数据
 */
async function updateSessionStatus(sessionId, status, message, data = {}) {
  try {
    const sessionData = await redis.get(`bilibili_qr_${sessionId}`);
    if (sessionData) {
      const session = JSON.parse(sessionData);
      session.status = status;
      session.message = message;
      session.data = data;
      session.updated_at = new Date().toISOString();
      
      await redis.setex(`bilibili_qr_${sessionId}`, 600, JSON.stringify(session));
    }
  } catch (error) {
    console.error('更新会话状态失败:', error);
  }
}

/**
 * 获取登录状态
 * @param {string} sessionId - 会话ID
 * @returns {Object} 登录状态
 */
async function getBilibiliLoginStatus(sessionId) {
  try {
    const sessionData = await redis.get(`bilibili_qr_${sessionId}`);
    if (!sessionData) {
      return { status: 'expired', message: '会话已过期' };
    }
    
    const session = JSON.parse(sessionData);
    return {
      status: session.status,
      message: session.message,
      data: session.data || {}
    };
  } catch (error) {
    console.error('获取登录状态失败:', error);
    return { status: 'error', message: '获取状态失败' };
  }
}

/**
 * 获取用户的B站账号列表
 * @param {number} userId - 用户ID
 * @returns {Array} B站账号列表
 */
async function getUserBilibiliAccounts(userId) {
  try {
    const [accounts] = await db.promise().query(
      `SELECT id, dedeuserid, nickname, avatar, is_active, login_time, created_at
       FROM bilibili_accounts 
       WHERE user_id = ? 
       ORDER BY login_time DESC`,
      [userId]
    );
    
    return accounts;
  } catch (error) {
    console.error('获取用户B站账号失败:', error);
    throw error;
  }
}

/**
 * 获取用户的活跃B站账号
 * @param {number} userId - 用户ID
 * @returns {Object|null} 活跃的B站账号
 */
async function getActiveBilibiliAccount(userId) {
  try {
    const [accounts] = await db.promise().query(
      `SELECT * FROM bilibili_accounts 
       WHERE user_id = ? AND is_active = 1 
       ORDER BY login_time DESC 
       LIMIT 1`,
      [userId]
    );
    
    return accounts.length > 0 ? accounts[0] : null;
  } catch (error) {
    console.error('获取活跃B站账号失败:', error);
    throw error;
  }
}

/**
 * 切换B站账号状态
 * @param {number} userId - 用户ID
 * @param {number} accountId - 账号ID
 * @param {boolean} isActive - 是否激活
 */
async function toggleBilibiliAccountStatus(userId, accountId, isActive) {
  try {
    await db.promise().query(
      'UPDATE bilibili_accounts SET is_active = ? WHERE id = ? AND user_id = ?',
      [isActive ? 1 : 0, accountId, userId]
    );
  } catch (error) {
    console.error('切换B站账号状态失败:', error);
    throw error;
  }
}

/**
 * 删除B站账号
 * @param {number} userId - 用户ID
 * @param {string|number} accountIdentifier - 账号标识符（可以是主键ID或dedeuserid）
 */
async function deleteBilibiliAccount(userId, accountIdentifier) {
  try {
    console.log('删除账号参数:', { userId, accountIdentifier, userIdType: typeof userId, accountIdentifierType: typeof accountIdentifier });
    
    // 先尝试通过主键ID查询
    let [existingAccount] = await db.promise().query(
      'SELECT * FROM bilibili_accounts WHERE id = ?',
      [accountIdentifier]
    );
    
    // 如果通过主键ID没找到，尝试通过dedeuserid查询
    if (existingAccount.length === 0) {
      [existingAccount] = await db.promise().query(
        'SELECT * FROM bilibili_accounts WHERE dedeuserid = ?',
        [accountIdentifier]
      );
    }
    
    console.log('查询到的账号:', existingAccount);
    
    if (existingAccount.length === 0) {
      throw new Error(`账号 ${accountIdentifier} 不存在`);
    }
    
    const account = existingAccount[0];
    
    if (account.user_id != userId) {
      throw new Error(`无权限删除账号，账号属于用户ID ${account.user_id}，当前用户ID ${userId}`);
    }
    
    // 使用主键ID进行删除
    const [result] = await db.promise().query(
      'DELETE FROM bilibili_accounts WHERE id = ? AND user_id = ?',
      [account.id, userId]
    );
    
    console.log('删除结果:', result);
    
    // 检查是否真正删除了数据
    if (result.affectedRows === 0) {
      throw new Error('删除操作未影响任何记录');
    }
    
    return result;
  } catch (error) {
    console.error('删除B站账号失败:', error);
    throw error;
  }
}

/**
 * 验证B站Cookie是否有效
 * @param {string} cookieString - Cookie字符串
 * @returns {boolean} 是否有效
 */
async function validateBilibiliCookie(cookieString) {
  try {
    const response = await axios.get(
      'https://api.bilibili.com/x/web-interface/nav',
      {
        headers: {
          ...BILIBILI_HEADERS,
          'Cookie': cookieString
        }
      }
    );
    
    return response.data && response.data.code === 0 && response.data.data.isLogin;
  } catch (error) {
    console.error('验证B站Cookie失败:', error);
    return false;
  }
}

/**
 * 获取B站视频信息和下载链接
 * @param {string} bvid - 视频BVID
 * @param {string} cookieString - Cookie字符串
 * @returns {Object} 视频信息和下载链接
 */
async function getBilibiliVideoInfo(bvid, cookieString) {
  try {
    // 获取视频基本信息
    const videoInfoResponse = await axios.get(
      `https://api.bilibili.com/x/web-interface/view?bvid=${bvid}`,
      {
        headers: {
          ...BILIBILI_HEADERS,
          'Cookie': cookieString
        }
      }
    );

    if (videoInfoResponse.data.code !== 0) {
      throw new Error(`获取视频信息失败: ${videoInfoResponse.data.message}`);
    }

    const videoData = videoInfoResponse.data.data;
    const cid = videoData.cid;

    // 获取视频下载链接
    const playUrlResponse = await axios.get(
      `https://api.bilibili.com/x/player/playurl?bvid=${bvid}&cid=${cid}&qn=80&fnval=16&fourk=1`,
      {
        headers: {
          ...BILIBILI_HEADERS,
          'Cookie': cookieString,
          'Referer': `https://www.bilibili.com/video/${bvid}`
        }
      }
    );

    if (playUrlResponse.data.code !== 0) {
      throw new Error(`获取下载链接失败: ${playUrlResponse.data.message}`);
    }

    const playData = playUrlResponse.data.data;
    
    // 提取视频和音频链接
    let videoUrl = null;
    let audioUrl = null;
    
    if (playData.dash) {
      // DASH格式
      if (playData.dash.video && playData.dash.video.length > 0) {
        videoUrl = playData.dash.video[0].baseUrl || playData.dash.video[0].base_url;
      }
      if (playData.dash.audio && playData.dash.audio.length > 0) {
        audioUrl = playData.dash.audio[0].baseUrl || playData.dash.audio[0].base_url;
      }
    } else if (playData.durl && playData.durl.length > 0) {
      // FLV格式
      videoUrl = playData.durl[0].url;
    }

    // 返回完整的视频信息，包含所有可用字段
    return {
      // 基本信息
      aid: videoData.aid,
      bvid: videoData.bvid,
      cid: videoData.cid,
      title: videoData.title,
      description: videoData.desc,
      pic: videoData.pic,
      
      // 时间信息
      duration: videoData.duration,
      pubdate: videoData.pubdate,
      ctime: videoData.ctime,
      
      // 分区信息
      tid: videoData.tid,
      tname: videoData.tname,
      copyright: videoData.copyright,
      
      // UP主信息
      owner: {
        mid: videoData.owner.mid,
        name: videoData.owner.name,
        face: videoData.owner.face
      },
      
      // 统计信息
      stat: {
        view: videoData.stat.view,
        danmaku: videoData.stat.danmaku,
        reply: videoData.stat.reply,
        favorite: videoData.stat.favorite,
        coin: videoData.stat.coin,
        share: videoData.stat.share,
        like: videoData.stat.like,
        now_rank: videoData.stat.now_rank || 0,
        his_rank: videoData.stat.his_rank || 0,
        evaluation: videoData.stat.evaluation || ''
      },
      
      // 视频属性
      videos: videoData.videos, // 分P数量
      pages: videoData.pages || [],
      subtitle: videoData.subtitle || {},
      
      // 权限和状态
      state: videoData.state,
      attribute: videoData.attribute,
      
      // 下载相关
      downloadUrls: {
        video: videoUrl,
        audio: audioUrl
      },
      quality: playData.quality || 80,
      format: playData.format || 'mp4',
      
      // 其他信息
      mission_id: videoData.mission_id || null,
      redirect_url: videoData.redirect_url || null,
      
      // 标签信息
      tag: videoData.tag || [],
      
      // 荣誉信息
      honor_reply: videoData.honor_reply || {},
      
      // 用户权限
      user_garb: videoData.user_garb || {},
      
      // 互动信息
      elec: videoData.elec || null,
      
      // 合集信息
      ugc_season: videoData.ugc_season || null
    };
  } catch (error) {
    console.error('获取B站视频信息失败:', error);
    throw error;
  }
}

module.exports = {
  generateBilibiliQRCode,
  getBilibiliLoginStatus,
  getUserBilibiliAccounts,
  getActiveBilibiliAccount,
  toggleBilibiliAccountStatus,
  deleteBilibiliAccount,
  validateBilibiliCookie,
  getBilibiliVideoInfo
};
// model/user/userRouter.js
const express = require("express");
const router = express.Router();
const userUtils = require("./userUtils");
const authorize = require("../auth/authUtils"); // 您的授权中间件

// --- 公开路由 ---

// 用户注册 (PC/邮箱)
router.post("/register", async (req, res) => {
  try {
    // req.body: { name, email, password, code (可选的验证码) }
    const result = await userUtils.registerUser(req.body);
    res.status(201).json({ code: 201, message: result.message, data: null });
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "注册失败",
      data: null,
    });
  }
});

// PC 端登录
router.post("/pc/login", async (req, res) => {
  try {
    // req.body: { account (邮箱或用户名), password }
    const result = await userUtils.loginPC(req.body);
    res.json({ code: 200, message: "登录成功", data: result });
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "登录失败",
      data: null,
    });
  }
});

// 微信小程序登录
router.post("/mobile/login/wxMiniprogram", async (req, res) => {
  try {
    // req.body: { code (来自 wx.login) }
    const result = await userUtils.loginWxMiniprogram(req.body);
    res.json({ code: 200, message: "登录成功", data: result });
  } catch (error) {
    const statusCode = error.code === 211 ? 211 : 400; // 处理特定的 211 错误码
    res.status(statusCode).json({
      code: statusCode,
      message: error.message,
      data: { openid: error.openid },
    });
  }
});

// 【新增】鸿蒙端登录接口
router.post("/harmony/login", async (req, res) => {
  try {
    // 调用为鸿蒙定制的登录工具函数
    const result = await userUtils.loginHarmony(req.body);
    res.json({ code: 200, message: "登录成功", data: result });
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "登录失败",
      data: null,
    });
  }
});


// 微信小程序绑定账户
router.post("/mobile/bind/wxMiniprogram", async (req, res) => {
  try {
    // req.body: { code (wx.login), email, verificationCode (验证码) }
    const result = await userUtils.bindWxMiniprogram(req.body);
    res.json({ code: 200, message: result.message, data: null });
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "绑定失败",
      data: null,
    });
  }
});

// 微信小程序注册新账户
router.post("/mobile/register/wxMiniprogram", async (req, res) => {
  try {
    // req.body: { code (wx.login), name (可选) }
    const result = await userUtils.registerWxMiniprogram(req.body);
    res.json({ code: 200, message: result.message, data: result }); // 包含 token
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "注册失败",
      data: null,
    });
  }
});

// 发送验证码接口 (例如：用于注册、绑定、重置密码等)
router.post("/send-verification-code", async (req, res) => {
  try {
    const { email, type } = req.body; // type: 'register', 'bind', 'reset_password' 等
    if (!email || !type) {
      return res.status(400).json({
        code: 400,
        message: "邮箱和类型为必填项。",
        data: null,
      });
    }
    const result = await userUtils.sendVerificationCode(email, type);
    res.json({ code: 200, message: result.message, data: null });
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message || "发送验证码失败。",
      data: null,
    });
  }
});

// --- 受保护的路由 (需要身份验证) ---
// 角色: '1' (用户), '2' (管理员), '3' (超级管理员)

// 用户登出
// 所有已认证用户都可以登出
router.post("/logout", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const token = req.headers.authorization.split(" ")[1];
    const deviceType = req.headers.devicetype || req.user.device; // 从请求头或 JWT 获取 deviceType
    const result = await userUtils.logoutUser({ token, deviceType });
    res.json({ code: 200, message: result.message, data: null });
  } catch (error) {
    // 即使服务器端登出失败 (例如 token 已失效)，客户端也应继续清除本地 token
    res.status(401).json({
      code: 401,
      message: error.message || "登出失败",
      data: null,
    });
  }
});

// 获取当前用户的登录状态和详细信息 (适配 Ant Design Pro 格式)
// 所有已认证用户都可以检查自己的状态
router.get("/status", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    // req.user 由 authorize 中间件从 JWT 中填充: {id, role, device, name, email}
    // req.user.id 是 loginverification.id
    const detailedUserInfo = await userUtils.getUserInfo(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        name: detailedUserInfo.name, // 来自 getUserInfo，通常是用户昵称或真实姓名
        avatar:
          detailedUserInfo.avatar || // 优先使用用户自己设置的头像
          "https://gw.alipayobjects.com/zos/antfincdn/XAosXuNZyF/BiazfanxmamNRoxxVxka.png", // 默认头像
        userid: req.user.id.toString(), // loginverification 表的 id，作为用户唯一标识符
        email: detailedUserInfo.email, // 来自 getUserInfo
        signature: detailedUserInfo.signature || "", // 个性签名，如果getUserInfo提供则使用，否则为空
        title: detailedUserInfo.title || "", // 职称，如果getUserInfo提供则使用，否则为空
        group: detailedUserInfo.group || "", // 所属组，如果getUserInfo提供则使用，否则为空
        tags: detailedUserInfo.tags || [], // 标签，如果getUserInfo提供则使用，否则为空数组
        notifyCount: detailedUserInfo.notifyCount || 0, // 通知数量
        unreadCount: detailedUserInfo.unreadCount || 0, // 未读消息数量
        country: detailedUserInfo.country || "中国", // 国家，优先从用户信息获取
        access: req.user.role, // 用户角色，来自 JWT
        address: detailedUserInfo.address || "", // 地址，如果getUserInfo提供则使用，否则为空
        phone: detailedUserInfo.phoneNumber || "", // 电话号码，来自 getUserInfo
      },
    });
  } catch (error) {
    console.error("获取当前用户信息错误:", error); // 打印实际错误信息到控制台
    res.status(500).json({
      success: false,
      message: "服务器错误，请稍后再试",
      // 如果需要，可以添加一个空的 data 字段或错误代码
      // data: null,
      // errorCode: 'INTERNAL_SERVER_ERROR'
    });
  }
});

// 获取当前用户的详细信息
// 所有已认证用户都可以获取自己的信息
router.get("/user", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    const result = await userUtils.getUserInfo(req.user.id); // req.user.id 是 loginverification.id
    res.json({
      code: 200,
      message: "用户信息获取成功。",
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      code: 500,
      message: error.message || "获取用户信息失败。",
      data: null,
    });
  }
});

// 更新当前用户信息
// 所有已认证用户都可以更新自己的信息
router.put("/user", authorize(["1", "2", "3"]), async (req, res) => {
  try {
    // req.body: { type: "email"|"phoneNumber"|"name"|"avatar"|"password", data: "newValue" }
    const { type, data } = req.body;
    if (!type || data === undefined) {
      return res.status(400).json({
        code: 400,
        message: "更新操作需要 type 和 data。",
        data: null,
      });
    }
    const result = await userUtils.updateUserInfo(req.user.id, { type, data });
    res.json({ code: 200, message: result.message, data: null });
  } catch (error) {
    res.status(400).json({
      code: 400,
      message: error.message || "更新用户信息失败。",
      data: null,
    });
  }
});

// --- 管理员路由 (示例) ---

// 获取所有用户 (供管理员/超级管理员使用)
router.get("/admin/users", authorize(["2", "3"]), async (req, res) => {
  // 占位符：在 userUtils 中实现获取所有用户的逻辑 (带分页、筛选等)
  // 目前仅返回成功消息
  res.json({
    code: 200,
    message: "管理员：获取所有用户接口 (待实现逻辑)。",
    data: [],
  });
});

// 更新任意用户的角色或信息 (供超级管理员使用)
router.put(
  "/admin/user/:userIdToUpdate",
  authorize(["3"]),
  async (req, res) => {
    // 占位符：在 userUtils 中实现超级管理员更新特定用户详细信息的逻辑
    // req.params.userIdToUpdate 将是 loginverification.id
    // req.body 可能包含 { role, name, email, 等 }
    const { userIdToUpdate } = req.params;
    const updateData = req.body;
    res.json({
      code: 200,
      message: `超级管理员：更新用户 ${userIdToUpdate} 接口 (待实现逻辑)。`,
      data: updateData,
    });
  }
);

module.exports = router;
// model/user/userUtils.js
const db = require("../../config/db"); // 您的 db.js
const redis = require("../../config/redis"); // 您的 redis.js
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
// const { getOpenid } = require("../wx/getOpenid"); // 假设您有此工具函数
require("dotenv").config();

const secret = process.env.JWT_SECRET;

// 如果 getOpenid 不可用，则使用模拟函数，请替换为您的实际实现
const getOpenid = async (code) => {
  console.log(`模拟 getOpenid 调用，code: ${code}`);
  if (code === "validWxCode") {
    return { openid: `mock_openid_${Date.now()}` };
  } else if (code === "existingOpenidCode") {
    return { openid: "mock_openid_existing" };
  }
  throw new Error("模拟微信 code 无效");
};

/** 生成 JWT */
function generateJWT(loginUser, deviceType) {
  // loginUser 是 loginverification 表中的一个条目
  return jwt.sign(
    {
      id: loginUser.id,
      role: loginUser.role,
      device: deviceType,
      name: loginUser.name,
      email: loginUser.email,
    }, // 如果 JWT 中需要更多字段，请在此添加
    secret,
    { expiresIn: "7d" } // 例如：7 天
  );
}

/** 将 JWT 保存到 Redis (例如，活动会话为1小时，JWT 本身具有更长的有效期) */
async function saveJWTToRedis(loginVerificationId, token, deviceType) {
  await redis.set(
    `user_${loginVerificationId}_${deviceType}_token`,
    token,
    "EX",
    3600 * 24 * 7 // 匹配 JWT 有效期或更短，用于活动会话跟踪
  );
}

/** 从 Redis 中删除 JWT */
async function deleteJWTFromRedis(loginVerificationId, deviceType) {
  await redis.del(`user_${loginVerificationId}_${deviceType}_token`);
}

/** 用户注册 (邮箱/密码) */
async function registerUser({ name, email, password, code, role = "1" }) {
  if (!name || !email || !password) {
    throw new Error("姓名、邮箱和密码为必填项。");
  }
  if (code) {
    // 假设 code 用于邮箱验证
    const storedCode = await redis.get(`code_register_${email}`);
    if (storedCode !== code) {
      throw new Error("验证码不正确或已过期。");
    }
  }

  const connection = await db.promise().getConnection();
  await connection.beginTransaction();

  try {
    let [existingLogins] = await connection.query(
      "SELECT id FROM loginverification WHERE email = ?",
      [email]
    );
    if (existingLogins.length > 0) {
      throw new Error("此邮箱已被注册。");
    }

    // 创建用户个人资料条目
    const [userResult] = await connection.query(
      "INSERT INTO user (username, email) VALUES (?, ?)",
      [name, email]
    );
    const userId = userResult.insertId;

    // 哈希密码
    const hashedPassword = await bcrypt.hash(password, 10);

    // 创建登录验证条目
    await connection.query(
      "INSERT INTO loginverification (name, email, password, role, uid) VALUES (?, ?, ?, ?, ?)",
      [name, email, hashedPassword, role, userId]
    );

    await connection.commit();
    if (code) {
      await redis.del(`code_register_${email}`);
    }
    return { message: "注册成功。" };
  } catch (error) {
    await connection.rollback();
    console.error("registerUser 出错:", error);
    throw error;
  } finally {
    connection.release();
  }
}

/** PC 端登录 (邮箱/密码 或 用户名/密码) */
async function loginPC({ username, password }) {
  if (!username?.trim() || !password?.trim()) {
    throw new Error("账户和密码不能为空。");
  }

  const connection = db.promise();
  // 尝试使用邮箱或用户名登录 (假设 loginverification 中的 'name' 可以是用户名)
  const [results] = await connection.query(
    "SELECT * FROM loginverification WHERE email = ? OR name = ?", // 或者，如果用户名存储在其他地方，请进行调整
    [username, username]
  );

  if (results.length === 0) {
    throw new Error("账户未找到。");
  }

  const loginUser = results[0];
  if (!loginUser.password) {
    throw new Error("此账户未启用密码登录。");
  }

  const validPassword = await bcrypt.compare(password, loginUser.password);
  if (!validPassword) {
    throw new Error("密码错误。");
  }

  const token = generateJWT(loginUser, "pc");
  await saveJWTToRedis(loginUser.id, token, "pc");

  return {
    token,
    role: loginUser.role,
    name: loginUser.name,
    id: loginUser.id,
  };
}

/** 微信小程序登录 */
async function loginWxMiniprogram({ code }) {
  if (!code) throw new Error("微信 code 是必需的。");
  const { openid } = await getOpenid(code); // 实现 getOpenid 以从微信 API 获取

  const connection = db.promise();
  const [results] = await connection.query(
    "SELECT * FROM loginverification WHERE openid = ?",
    [openid]
  );

  if (results.length > 0) {
    const loginUser = results[0];
    const token = generateJWT(loginUser, "mobile");
    await saveJWTToRedis(loginUser.id, token, "mobile");
    return {
      token,
      role: loginUser.role,
      name: loginUser.name,
      id: loginUser.id,
    };
  } else {
    // 未通过 openid 找到用户，需要注册或绑定
    const error = new Error("微信账户未注册。请注册或绑定您的账户。");
    error.code = 211; // 自定义代码，用于前端指示新微信用户
    error.openid = openid; // 将 openid 返回以进行注册流程
    throw error;
  }
}

/** 微信小程序绑定 */
async function bindWxMiniprogram({ code, email, verificationCode }) {
  if (!code || !email || !verificationCode) {
    throw new Error("微信 code、邮箱和验证码是必需的。");
  }

  const { openid } = await getOpenid(code);
  const connection = await db.promise().getConnection();
  await connection.beginTransaction();

  try {
    const [openidResults] = await connection.query(
      "SELECT id FROM loginverification WHERE openid = ?",
      [openid]
    );
    if (openidResults.length > 0) {
      throw new Error("此微信账户已绑定到其他用户。");
    }

    // 可选：验证邮箱验证码
    const storedEmailCode = await redis.get(`code_bind_${email}`);
    if (storedEmailCode !== verificationCode) {
      throw new Error("验证码不正确或已过期。");
    }

    const [emailResults] = await connection.query(
      "SELECT id, uid FROM loginverification WHERE email = ?",
      [email]
    );
    if (emailResults.length === 0) {
      throw new Error("邮箱账户未找到。请先注册。");
    }
    const loginEntry = emailResults[0];

    // 使用 openid 更新 loginverification
    await connection.query(
      "UPDATE loginverification SET openid = ? WHERE id = ?",
      [openid, loginEntry.id]
    );

    // 可选地，如果 user 表存在且 uid 已链接，则更新 user 表的 openid
    if (loginEntry.uid) {
      await connection.query("UPDATE user SET openid = ? WHERE id = ?", [
        openid,
        loginEntry.uid,
      ]);
    }

    await connection.commit();
    await redis.del(`code_bind_${email}`);
    return { message: "微信账户绑定成功。" };
  } catch (error) {
    await connection.rollback();
    console.error("bindWxMiniprogram 出错:", error);
    throw error;
  } finally {
    connection.release();
  }
}

/** 微信小程序注册 (通过微信创建新用户) */
async function registerWxMiniprogram({
  code,
  name = "微信用户", // 默认名称
  role = "1",
}) {
  if (!code) throw new Error("微信 code 是必需的。");
  const { openid } = await getOpenid(code);

  const connection = await db.promise().getConnection();
  await connection.beginTransaction();
  try {
    const [existingLogins] = await connection.query(
      "SELECT id FROM loginverification WHERE openid = ?",
      [openid]
    );
    if (existingLogins.length > 0) {
      throw new Error("此微信账户已被注册。");
    }

    // 创建用户个人资料条目
    const [userResult] = await connection.query(
      "INSERT INTO user (username, openid) VALUES (?, ?)",
      [name, openid] // 使用提供的名称或默认值
    );
    const userId = userResult.insertId;

    // 创建登录验证条目
    const [loginResult] = await connection.query(
      "INSERT INTO loginverification (name, openid, role, uid) VALUES (?, ?, ?, ?)",
      [name, openid, role, userId]
    );
    const loginVerificationId = loginResult.insertId;

    await connection.commit();

    // 注册后自动登录用户
    const loginUser = { id: loginVerificationId, name, role, openid }; // 为 JWT 构建足够的信息
    const token = generateJWT(loginUser, "mobile");
    await saveJWTToRedis(loginUser.id, token, "mobile");

    return {
      message: "注册成功。",
      token,
      role: loginUser.role,
      name: loginUser.name,
      id: loginUser.id,
    };
  } catch (error) {
    await connection.rollback();
    console.error("registerWxMiniprogram 出错:", error);
    throw error;
  } finally {
    connection.release();
  }
}

/** 用户登出 */
async function logoutUser({ token, deviceType }) {
  try {
    const decoded = jwt.verify(token, secret); // 验证是一个好习惯
    await deleteJWTFromRedis(decoded.id, deviceType);
    return { message: "登出成功。" };
  } catch (error) {
    // 如果 token 无效/过期，它可能已从 Redis 中删除或无关紧要
    console.warn("登出警告 (token 可能无效或已过期):", error.message);
    // 仍然返回成功，因为目标是确保用户在客户端也已登出
    return { message: "登出已处理。" };
  }
}

/** 获取用户信息 */
async function getUserInfo(loginVerificationId) {
  // loginVerificationId 来自 JWT (decoded.id)
  const connection = db.promise();
  const [lvRows] = await connection.query(
    "SELECT * FROM loginverification WHERE id = ?",
    [loginVerificationId]
  );

  if (!lvRows || lvRows.length === 0) {
    throw new Error("登录会话未找到或用户不存在。");
  }
  const loginUser = lvRows[0];
  let userProfile = null;

  if (loginUser.uid) {
    const [userRows] = await connection.query(
      "SELECT * FROM user WHERE id = ?",
      [loginUser.uid]
    );
    if (userRows.length > 0) {
      userProfile = userRows[0];
    }
  }

  return {
    id: loginUser.id, // 这是 loginverification.id，JWT 中的那个
    role: loginUser.role,
    name: userProfile?.username || loginUser.name, // 首选个人资料用户名，备用登录名
    email: userProfile?.email || loginUser.email, // 首选个人资料邮箱
    avatar: userProfile?.avatar || null,
    phoneNumber: userProfile?.phoneNumber || loginUser.phoneNumber,
    uid: loginUser.uid, // user 表的 id
    // 根据需要添加 userProfile 或 loginUser 中的任何其他字段
  };
}

/** 更新用户信息 */
async function updateUserInfo(loginVerificationId, { type, data }) {
  // loginVerificationId 来自 req.user.id (JWT 的 id 声明)
  const validTypes = ["phoneNumber", "email", "name", "avatar", "password"];
  if (!validTypes.includes(type)) {
    throw new Error(`无效的更新类型。允许的类型: ${validTypes.join("、 ")}`);
  }

  // 基本验证 (可以更全面)
  if (type === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data)) {
    throw new Error("邮箱格式无效。");
  }
  if (type === "phoneNumber" && data && !/^\+?[1-9]\d{1,14}$/.test(data)) {
    // 简单的国际格式
    throw new Error("电话号码格式无效。");
  }
  if (type === "name" && !data?.trim()) {
    throw new Error("姓名不能为空。");
  }

  const connection = await db.promise().getConnection();
  await connection.beginTransaction();
  try {
    const [lvRows] = await connection.query(
      "SELECT uid, email, phoneNumber FROM loginverification WHERE id = ?",
      [loginVerificationId]
    );
    if (lvRows.length === 0) {
      throw new Error("用户未找到。");
    }
    const loginUser = lvRows[0];

    // 处理 loginverification 表的更新
    if (type === "email") {
      if (data === loginUser.email) throw new Error("新邮箱与当前邮箱相同。");
      const [existing] = await connection.query(
        "SELECT id FROM loginverification WHERE email = ? AND id != ?",
        [data, loginVerificationId]
      );
      if (existing.length > 0) throw new Error("此邮箱已被其他账户使用。");
      await connection.query(
        "UPDATE loginverification SET email = ? WHERE id = ?",
        [data, loginVerificationId]
      );
    } else if (type === "phoneNumber") {
      if (data === loginUser.phoneNumber)
        throw new Error("新电话号码与当前电话号码相同。");
      const [existing] = await connection.query(
        "SELECT id FROM loginverification WHERE phoneNumber = ? AND id != ?",
        [data, loginVerificationId]
      );
      if (existing.length > 0) throw new Error("此电话号码已被其他账户使用。");
      await connection.query(
        "UPDATE loginverification SET phoneNumber = ? WHERE id = ?",
        [data, loginVerificationId]
      );
    } else if (type === "name" && !loginUser.uid) {
      // 如果没有单独的用户个人资料，则更新 loginverification 中的 name
      await connection.query(
        "UPDATE loginverification SET name = ? WHERE id = ?",
        [data, loginVerificationId]
      );
    } else if (type === "password") {
      if (!data || data.length < 6) throw new Error("密码长度至少为6个字符。");
      const hashedPassword = await bcrypt.hash(data, 10);
      await connection.query(
        "UPDATE loginverification SET password = ? WHERE id = ?",
        [hashedPassword, loginVerificationId]
      );
    }

    // 处理 user 表 (个人资料) 的更新
    if (loginUser.uid) {
      let userUpdateQuery = "";
      let userUpdateParams = [];
      if (type === "name") {
        userUpdateQuery = "UPDATE user SET username = ? WHERE id = ?";
        userUpdateParams = [data, loginUser.uid];
      } else if (type === "email") {
        // 如果不同，也更新个人资料邮箱
        userUpdateQuery = "UPDATE user SET email = ? WHERE id = ?";
        userUpdateParams = [data, loginUser.uid];
      } else if (type === "phoneNumber") {
        // 如果不同，也更新个人资料电话号码
        userUpdateQuery = "UPDATE user SET phoneNumber = ? WHERE id = ?";
        userUpdateParams = [data, loginUser.uid];
      } else if (type === "avatar") {
        userUpdateQuery = "UPDATE user SET avatar = ? WHERE id = ?";
        userUpdateParams = [data, loginUser.uid];
      }
      // 注意：密码通常不存储在 'user' 个人资料表中，而是存储在 'loginverification' 中

      if (userUpdateQuery) {
        await connection.query(userUpdateQuery, userUpdateParams);
      }
    }

    await connection.commit();
    return { message: "用户信息更新成功。" };
  } catch (error) {
    await connection.rollback();
    console.error("updateUserInfo 出错:", error);
    throw error;
  } finally {
    connection.release();
  }
}

// 【新增】鸿蒙端登录 (逻辑与PC端类似，但设备类型不同)
async function loginHarmony({ username, password }) {
  if (!username?.trim() || !password?.trim()) {
    throw new Error("账户和密码不能为空。");
  }

  const connection = db.promise();
  const [results] = await connection.query(
    "SELECT * FROM loginverification WHERE email = ? OR name = ?",
    [username, username]
  );

  if (results.length === 0) {
    throw new Error("账户未找到。");
  }

  const loginUser = results[0];
  if (!loginUser.password) {
    throw new Error("此账户未启用密码登录。");
  }

  const validPassword = await bcrypt.compare(password, loginUser.password);
  if (!validPassword) {
    throw new Error("密码错误。");
  }

  // 【关键区别】设备类型标记为 'harmony'
  const token = generateJWT(loginUser, "harmony");
  await saveJWTToRedis(loginUser.id, token, "harmony");

  return {
    token,
    role: loginUser.role,
    name: loginUser.name,
    id: loginUser.id,
  };
}

module.exports = {
  registerUser,
  loginPC,
  loginWxMiniprogram,
  bindWxMiniprogram,
  registerWxMiniprogram,
  logoutUser,
  getUserInfo,
  updateUserInfo,
  loginHarmony,
  // 用于发送验证码 (示例，根据需要实现)
  async sendVerificationCode(email, type = "register") {
    // type 可以是 'register', 'bind', 'reset_password' 等
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const key = `code_${type}_${email}`;
    await redis.set(key, code, "EX", 300); // 5 分钟有效期
    console.log(`邮箱 ${email} (${type}) 的验证码: ${code}`); // 替换为实际的邮件发送逻辑
    return { message: "验证码已发送。" };
  },
};
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

// 配置路径
const DOWNLOAD_DIR = path.join(__dirname, "../../downloads"); // 临时下载目录
const VIDEO_DIR = path.join(__dirname, "../../videos"); // 最终视频存储目录
const FFMPEG_PATH = "ffmpeg"; // FFmpeg 可执行文件路径，确保已安装并在 PATH 中

// 确保目录存在
if (!fs.existsSync(DOWNLOAD_DIR)) {
  fs.mkdirSync(DOWNLOAD_DIR, { recursive: true });
  console.log(`📁 创建临时下载目录: ${DOWNLOAD_DIR}`);
}

if (!fs.existsSync(VIDEO_DIR)) {
  fs.mkdirSync(VIDEO_DIR, { recursive: true });
  console.log(`📁 创建视频存储目录: ${VIDEO_DIR}`);
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
 * 使用 FFmpeg 合并视频和音频（支持进度回调）
 * @param {string} videoPath - 视频文件路径
 * @param {string} audioPath - 音频文件路径
 * @param {string} outputPath - 输出文件路径
 * @param {Function} progressCallback - 进度回调函数
 * @returns {Promise<void>}
 */
function mergeVideoAndAudio(videoPath, audioPath, outputPath, progressCallback) {
  return new Promise((resolve, reject) => {
    console.log(`🔧 开始合并视频和音频: ${path.basename(outputPath)}`);

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
  incrementDailyDownloadCount
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

