// entry/src/main/ets/view/Mine.ets (或其他 Mine.ets 所在路径)

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { tokenManager } from '../utils/TokenManager';
import { apiService } from '../api/ApiService';
import { preferences } from '@kit.ArkData';

// 用户信息接口
interface UserInfo {
  nickname: string;
  avatar: string;
  level: number;
  coins: number;
  followers: number;
  following: number;
}

// B站鉴权信息接口
interface BilibiliAuthInfo {
  nickname: string;
  avatar: string;
  dedeuserid: string;
}

// 统计数据接口
interface StatsItem {
  title: string;
  value: string;
  icon: string;
  color: string;
}

// 菜单项接口
interface MenuItem {
  icon: string;
  title: string;
  subtitle: string;
  color: string;
}

@Component
export struct Mine {
  @State isLoggingOut: boolean = false; // 添加状态，防止重复点击
  @State isLoading: boolean = true; // 数据加载状态
  @State userToken: string = ''; // 用户token
  @State bilibiliAuthInfo: BilibiliAuthInfo | null = null; // B站鉴权信息
  @State userInfo: UserInfo = {
    nickname: 'B站用户',
    avatar: 'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
    level: 6,
    coins: 1234,
    followers: 567,
    following: 89
  };
  @State realUserStats: StatsItem[] = [
    { title: '观看历史', value: '0', icon: '📺', color: '#FF6B9D' },
    { title: '收藏夹', value: '0', icon: '⭐', color: '#4ECDC4' },
    { title: '点赞数', value: '0', icon: '👍', color: '#45B7D1' },
    { title: '投币数', value: '0', icon: '🪙', color: '#FFEAA7' }
  ];
  @State statsData: Array<StatsItem> = [
    { title: '观看历史', value: '128', icon: '📺', color: '#FF6B9D' },
    { title: '收藏夹', value: '45', icon: '⭐', color: '#4ECDC4' },
    { title: '点赞数', value: '892', icon: '👍', color: '#45B7D1' },
    { title: '投币数', value: '234', icon: '🪙', color: '#FFEAA7' }
  ];

  // 功能菜单数据
  private menuData: Array<MenuItem> = [
    { icon: '📱', title: '我的设备', subtitle: '管理登录设备', color: '#FF6B9D' },
    { icon: '🔔', title: '消息通知', subtitle: '推送设置', color: '#4ECDC4' },
    { icon: '🎨', title: '个性装扮', subtitle: '主题皮肤', color: '#45B7D1' },
    { icon: '💰', title: '钱包', subtitle: '余额充值', color: '#96CEB4' },
    { icon: '🎁', title: '会员中心', subtitle: '特权服务', color: '#FFEAA7' },
    { icon: '📊', title: '数据统计', subtitle: '观看分析', color: '#DDA0DD' },
    { icon: '⚙️', title: '设置', subtitle: '账号安全', color: '#FFB6C1' },
    { icon: '❓', title: '帮助反馈', subtitle: '意见建议', color: '#87CEEB' }
  ];

  // 获取 UIAbility 上下文
  private getUIAbilityContext(): common.UIAbilityContext {
    return AppStorage.get('uiAbilityContext') as common.UIAbilityContext;
  }

  // 组件即将出现时调用
  async aboutToAppear() {
    await this.loadUserData();
  }

  // 加载用户数据
  async loadUserData(): Promise<void> {
    try {
      this.isLoading = true;
      const context = this.getUIAbilityContext();
      
      // 获取用户token
      this.userToken = await tokenManager.getToken(context) || '';
      
      if (this.userToken) {
        // 获取B站鉴权信息
        await this.loadBilibiliAuthInfo();
        // 获取用户统计数据
        await this.loadUserStats();
      }
    } catch (error) {
      console.error('❌ 加载用户数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 获取B站鉴权信息
  async loadBilibiliAuthInfo(): Promise<void> {
    try {
      if (!this.userToken) {
        console.warn('⚠️ 用户token为空，无法获取哔哩哔哩鉴权信息');
        return;
      }

      console.log('🔄 开始获取哔哩哔哩鉴权信息...');
      const authInfo = await apiService.getBilibiliAuthInfo(this.userToken);
      
      if (authInfo && authInfo.cookies && authInfo.cookies.SESSDATA) {
        this.bilibiliAuthInfo = {
          nickname: authInfo.nickname || '未知用户',
          avatar: authInfo.avatar || '',
          dedeuserid: authInfo.dedeuserid || ''
        };
        
        // 更新用户信息
        this.userInfo = {
          nickname: authInfo.nickname || 'B站用户',
          avatar: authInfo.avatar || this.userInfo.avatar,
          level: this.userInfo.level,
          coins: this.userInfo.coins,
          followers: this.userInfo.followers,
          following: this.userInfo.following
        };
        
        console.log('✅ 获取哔哩哔哩鉴权信息成功');
      }
    } catch (error) {
      console.error('❌ 获取哔哩哔哩鉴权信息失败:', error);
    }
  }

  // 获取用户统计数据
  async loadUserStats(): Promise<void> {
    try {
      // 这里可以调用API获取真实的用户统计数据
      // 暂时使用模拟数据，可以根据实际API进行调整
      const historyCount = Math.floor(Math.random() * 500) + 100;
      const favoritesCount = Math.floor(Math.random() * 100) + 20;
      const likesCount = Math.floor(Math.random() * 1000) + 200;
      const coinsCount = Math.floor(Math.random() * 500) + 50;
      
      this.realUserStats = [
        { title: '观看历史', value: historyCount.toString(), icon: '📺', color: '#FF6B9D' },
        { title: '收藏夹', value: favoritesCount.toString(), icon: '⭐', color: '#4ECDC4' },
        { title: '点赞数', value: likesCount.toString(), icon: '👍', color: '#45B7D1' },
        { title: '投币数', value: coinsCount.toString(), icon: '🪙', color: '#FFEAA7' }
      ];
      
      // 更新硬币数量
      this.userInfo.coins = coinsCount;
      
      console.log('✅ 用户统计数据加载完成');
    } catch (error) {
      console.error('❌ 获取用户统计数据失败:', error);
    }
  }

  // 处理退出登录的函数
  async handleLogout() {
    if (this.isLoggingOut) {
      return;
    }
    this.isLoggingOut = true;

    const context = this.getUIAbilityContext();
    const token = await tokenManager.getToken(context);

    try {
      if (token) {
        // 1. 调用后端API，通知服务器用户登出
        await apiService.logout(token);
      }
    } catch (error) {
      const err = error as Error;
      // 即便后端API调用失败（比如网络问题或token已过期），客户端也应继续执行登出流程
      console.error(`Logout API call failed: ${err.message}`);
    } finally {
      // 2. 无论API调用成功与否，都必须清除本地Token
      await tokenManager.deleteToken(context);

      // 3. 提示用户并重定向到登录页
      promptAction.showToast({ message: '您已成功退出' });

      // 使用 replaceUrl 跳转，这样用户无法按返回键回到"我的"页面
      router.replaceUrl({ url: 'pages/LoginPage' });

      this.isLoggingOut = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()
      
      // 主要内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 用户信息卡片
          this.buildUserCard()
          
          // 数据统计卡片
          this.buildStatsCard()
          
          // 功能菜单
          this.buildMenuGrid()
          
          // 会员特权横幅
          this.buildVipBanner()
          
          // 退出登录按钮
          this.buildLogoutButton()
          
          // 底部间距
          Blank().height(20)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .backgroundColor('#F8F9FA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  // 构建顶部导航栏
  @Builder
  buildHeader() {
    Row() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Blank()
      
      Row({ space: 16 }) {
        Text('🔍')
          .fontSize(20)
          .onClick(() => {
            // 搜索功能
          })
        
        Text('⚙️')
          .fontSize(20)
          .onClick(() => {
            // 设置功能
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetY: 1 })
  }

  // 构建用户信息卡片
  @Builder
  buildUserCard() {
    Row({ space: 16 }) {
      // 头像
      Stack() {
        if (this.isLoading) {
          // 加载状态的占位符
          Column()
            .width(80)
            .height(80)
            .borderRadius(40)
            .backgroundColor('#F0F0F0')
            .animation({ duration: 1000, iterations: -1 })
        } else {
          Image(this.bilibiliAuthInfo?.avatar || this.userInfo.avatar)
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .alt($r('app.media.photo35'))
        }
        
        // 等级标识
        Text(`LV${this.userInfo.level}`)
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B9D')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .position({ x: 55, y: 60 })
          .opacity(this.isLoading ? 0.5 : 1)
      }
      
      // 用户信息
      Column({ space: 8 }) {
        if (this.isLoading) {
          // 加载状态
          Column()
            .width(120)
            .height(20)
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
        } else {
          Text(this.bilibiliAuthInfo?.nickname || this.userInfo.nickname)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        
        if (this.bilibiliAuthInfo?.dedeuserid && !this.isLoading) {
          Text(`UID: ${this.bilibiliAuthInfo.dedeuserid}`)
            .fontSize(12)
            .fontColor('#666666')
        }
        
        Text(this.isLoading ? '加载中...' : '哔哩哔哩用户')
          .fontSize(14)
          .fontColor('#999999')
        
        Row({ space: 16 }) {
          Column({ space: 2 }) {
            Text(this.isLoading ? '--' : this.userInfo.coins.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF6B9D')
            Text('硬币')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column({ space: 2 }) {
            Text(this.isLoading ? '--' : this.userInfo.followers.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#4ECDC4')
            Text('粉丝')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column({ space: 2 }) {
            Text(this.userInfo.following.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#45B7D1')
            Text('关注')
              .fontSize(12)
              .fontColor('#666666')
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 编辑按钮
      Text('✏️')
        .fontSize(20)
        .onClick(() => {
          // 编辑个人信息
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetY: 4 })
    .margin({ top: 16 })
  }

  // 构建数据统计卡片
  @Builder
  buildStatsCard() {
    Column({ space: 12 }) {
      Row() {
        Text('我的数据')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Row({ space: 8 }) {
          if (this.isLoading) {
            Text('🔄')
              .fontSize(16)
              .fontColor('#FF6B9D')
              .animation({ duration: 1000, iterations: -1, curve: Curve.Linear })
              .rotate({ angle: this.isLoading ? 360 : 0 })
          } else {
            Text('🔄')
              .fontSize(16)
              .fontColor('#FF6B9D')
              .onClick(async () => {
                await this.loadUserData();
              })
          }
          
          Text('查看详情 >')
            .fontSize(14)
            .fontColor('#FF6B9D')
        }
      }
      .width('100%')
      
      Row({ space: 12 }) {
        ForEach(this.isLoading ? this.statsData : this.realUserStats, (item: StatsItem) => {
          Column({ space: 8 }) {
            Text(item.icon)
              .fontSize(24)
              .opacity(this.isLoading ? 0.5 : 1)
            if (this.isLoading) {
              Column()
                .width(40)
                .height(20)
                .backgroundColor('#F0F0F0')
                .borderRadius(4)
            } else {
              Text(item.value)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.color)
            }
            Text(item.title)
              .fontSize(12)
              .fontColor('#666666')
              .opacity(this.isLoading ? 0.5 : 1)
          }
          .width('25%')
          .height(80)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
          .onClick(() => {
            // 点击统计项
          })
        })
      }
      .width('100%')
    }
    .margin({ top: 16 })
  }

  // 构建功能菜单网格
  @Builder
  buildMenuGrid() {
    Column({ space: 12 }) {
      Row() {
        Text('功能服务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      
      Grid() {
        ForEach(this.menuData, (item: MenuItem) => {
          GridItem() {
            Row({ space: 12 }) {
              Text(item.icon)
                .fontSize(24)
                .width(40)
                .height(40)
                .textAlign(TextAlign.Center)
                .backgroundColor(item.color + '20')
                .borderRadius(20)
                .lineHeight(40)
              
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                Text(item.subtitle)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text('>')
                .fontSize(16)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            .onClick(() => {
              // 功能点击事件
              promptAction.showToast({ message: `点击了${item.title}` });
            })
          }
        })
      }
      .columnsTemplate('1fr')
      .rowsGap(8)
      .width('100%')
    }
    .margin({ top: 16 })
  }

  // 构建会员特权横幅
  @Builder
  buildVipBanner() {
    Column({ space: 12 }) {
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text('👑')
              .fontSize(20)
            Text('哔哩哔哩大会员')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          Text('专属特权，畅享无限精彩')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .opacity(0.9)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Button(this.bilibiliAuthInfo ? '续费会员' : '立即开通')
          .width(80)
          .height(32)
          .fontSize(12)
          .backgroundColor('#FFFFFF')
          .fontColor('#FF6B9D')
          .borderRadius(16)
          .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }
      
      // 会员特权展示
      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text('🎬')
            .fontSize(16)
          Text('专属内容')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
        
        Column({ space: 4 }) {
          Text('📱')
            .fontSize(16)
          Text('免广告')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
        
        Column({ space: 4 }) {
          Text('⚡')
            .fontSize(16)
          Text('高清画质')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
        
        Column({ space: 4 }) {
          Text('🎁')
            .fontSize(16)
          Text('专属福利')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .opacity(0.8)
        }
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FF6B9D')
    .borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [['#FF6B9D', 0.0], ['#4ECDC4', 1.0]]
    })
    .shadow({ radius: 8, color: '#1A000000', offsetY: 4 })
    .margin({ top: 16 })
    .onClick(() => {
      // 开通会员
    })
  }

  // 构建退出登录按钮
  @Builder
  buildLogoutButton() {
    Button(this.isLoggingOut ? '正在退出...' : '退出登录')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor('#FF4757')
      .backgroundColor('#FFFFFF')
      .border({ width: 1, color: '#FF4757', radius: 24 })
      .enabled(!this.isLoggingOut)
      .margin({ top: 24 })
      .onClick(() => {
        this.handleLogout();
      })
  }
}