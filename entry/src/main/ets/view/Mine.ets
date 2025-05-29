// entry/src/main/ets/view/Mine.ets (或其他 Mine.ets 所在路径)

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { tokenManager } from '../utils/TokenManager';
import { apiService } from '../api/ApiService';

@Component
export struct Mine {
  @State isLoggingOut: boolean = false; // 添加状态，防止重复点击

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

      // 使用 replaceUrl 跳转，这样用户无法按返回键回到“我的”页面
      router.replaceUrl({ url: 'pages/LoginPage' });

      this.isLoggingOut = false;
    }
  }

  build() {
    // 使用 Column 实现垂直居中布局
    Column() {
      Text("我的页面")
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 50 })

      // 退出登录按钮
      Button(this.isLoggingOut ? '正在退出...' : '退出登录')
        .width('80%')
        .height(48)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor(Color.Red) // 使用醒目的红色背景
        .type(ButtonType.Capsule)
        .enabled(!this.isLoggingOut) // 正在退出时禁用按钮
        .onClick(() => {
          this.handleLogout();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center) // 主轴（垂直）居中
  }
}