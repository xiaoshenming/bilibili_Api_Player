// entry/src/main/ets/view/Mine.ets (或其他 Mine.ets 所在路径)

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { tokenManager } from '../utils/TokenManager';
import { apiService } from '../api/ApiService';

// 用户信息接口
interface UserInfo {
  nickname: string;
  avatar: string;
  level: number;
  coins: number;
  followers: number;
  following: number;
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
  @State userInfo: UserInfo = {
    nickname: 'B站用户',
    avatar: 'https://i0.hdslb.com/bfs/face/84f1e4b0dd26cc45bb268275e68747cf9e8ba334.jpg',
    level: 6,
    coins: 1234,
    followers: 567,
    following: 89
  };
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
        Image(this.userInfo.avatar)
          .width(80)
          .height(80)
          .borderRadius(40)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.photo35'))
        
        // 等级标识
        Text(`LV${this.userInfo.level}`)
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B9D')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(8)
          .position({ x: 55, y: 60 })
      }
      
      // 用户信息
      Column({ space: 8 }) {
        Text(this.userInfo.nickname)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Row({ space: 16 }) {
          Column({ space: 2 }) {
            Text(this.userInfo.coins.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF6B9D')
            Text('硬币')
              .fontSize(12)
              .fontColor('#666666')
          }
          
          Column({ space: 2 }) {
            Text(this.userInfo.followers.toString())
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
        
        Text('查看详情 >')
          .fontSize(14)
          .fontColor('#FF6B9D')
      }
      .width('100%')
      
      Row({ space: 12 }) {
        ForEach(this.statsData, (item: StatsItem) => {
          Column({ space: 8 }) {
            Text(item.icon)
              .fontSize(24)
            Text(item.value)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(item.color)
            Text(item.title)
              .fontSize(12)
              .fontColor('#666666')
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
    Row({ space: 16 }) {
      Column({ space: 8 }) {
        Text('👑')
          .fontSize(32)
        Text('开通会员')
          .fontSize(14)
          .fontColor('#FFFFFF')
      }
      
      Column({ space: 4 }) {
        Text('B站大会员')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('专享特权，畅享无限精彩')
          .fontSize(12)
          .fontColor('#FFFFFF')
        Text('首月仅需 ¥9.9')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFD700')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Button('立即开通')
        .width(80)
        .height(32)
        .fontSize(12)
        .backgroundColor('#FFFFFF')
        .fontColor('#FF6B9D')
        .borderRadius(16)
    }
    .width('100%')
    .height(100)
    .padding(20)
    .backgroundColor('#FF6B9D')
    .borderRadius(16)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [['#FF6B9D', 0.0], ['#FF8E9B', 1.0]]
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