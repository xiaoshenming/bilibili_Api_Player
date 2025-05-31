/**
 * 注册页面
 * 提供用户注册功能，包括用户名、邮箱、密码输入和邮箱验证码验证
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { apiService } from '../api/ApiService';
import { tokenManager } from '../utils/TokenManager';

@Entry
@Component
struct RegisterPage {
  @State name: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';
  @State isSendingCode: boolean = false;
  @State isRegistering: boolean = false;
  @State countdown: number = 0;
  private timer: number = -1;

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  private getUIAbilityContext(): common.UIAbilityContext {
    return AppStorage.get('uiAbilityContext') as common.UIAbilityContext;
  }

  // 发送验证码
  async sendVerificationCode() {
    if (this.isSendingCode || this.countdown > 0) return;

    if (!this.email.trim()) {
      promptAction.showToast({ message: '请输入邮箱地址' });
      return;
    }

    // 简单的邮箱格式验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      promptAction.showToast({ message: '请输入正确的邮箱格式' });
      return;
    }

    this.isSendingCode = true;
    try {
      await apiService.sendVerificationCode(this.email, 'register');
      promptAction.showToast({ message: '验证码已发送，请查收邮箱' });

      // 开始倒计时
      this.countdown = 60;
      this.timer = setInterval(() => {
        this.countdown--;
        if (this.countdown <= 0) {
          clearInterval(this.timer);
          this.timer = -1;
        }
      }, 1000);
    } catch (error) {
      const err = error as Error;
      promptAction.showToast({ message: `发送失败: ${err.message}` });
    } finally {
      this.isSendingCode = false;
    }
  }

  // 验证输入
  private validateInput(): boolean {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return false;
    }

    if (this.name.length < 2 || this.name.length > 20) {
      promptAction.showToast({ message: '用户名长度应在2-20个字符之间' });
      return false;
    }

    if (!this.email.trim()) {
      promptAction.showToast({ message: '请输入邮箱地址' });
      return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      promptAction.showToast({ message: '请输入正确的邮箱格式' });
      return false;
    }

    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return false;
    }

    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度不能少于6位' });
      return false;
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return false;
    }

    if (!this.verificationCode.trim()) {
      promptAction.showToast({ message: '请输入验证码' });
      return false;
    }

    if (this.verificationCode.length !== 6) {
      promptAction.showToast({ message: '验证码应为6位数字' });
      return false;
    }

    return true;
  }

  // 处理注册
  async handleRegister() {
    if (this.isRegistering) return;

    if (!this.validateInput()) return;

    this.isRegistering = true;
    try {
      await apiService.register(this.name, this.email, this.password, this.verificationCode);
      promptAction.showToast({ message: '注册成功！请返回登录页面登录' });

      // 延迟跳转，让用户看到成功提示
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (error) {
      const err = error as Error;
      promptAction.showToast({ message: `注册失败: ${err.message}` });
    } finally {
      this.isRegistering = false;
    }
  }

  // 返回登录页面
  goBackToLogin() {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor(Color.Black)
        }
        .type(ButtonType.Circle)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBackToLogin())

        Text('用户注册')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Button()
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 主要内容区域
      Column() {
        // 标题和描述
        Column() {
          Text('创建新账号')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Text('请填写以下信息完成注册')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 40 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        // 输入表单
        Column({ space: 20 }) {
          // 用户名输入
          Column({ space: 8 }) {
            Text('用户名')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入用户名（2-20个字符）' })
              .height(48)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .border({ width: 1, color: Color.Transparent })
              .focusOnTouch(true)
              .onChange((value) => {
                this.name = value;
              })
          }

          // 邮箱输入
          Column({ space: 8 }) {
            Text('邮箱地址')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入邮箱地址' })
              .type(InputType.Email)
              .height(48)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .border({ width: 1, color: Color.Transparent })
              .focusOnTouch(true)
              .onChange((value) => {
                this.email = value;
              })
          }

          // 密码输入
          Column({ space: 8 }) {
            Text('密码')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入密码（至少6位）' })
              .type(InputType.Password)
              .height(48)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .border({ width: 1, color: Color.Transparent })
              .focusOnTouch(true)
              .showPasswordIcon(true)
              .onChange((value) => {
                this.password = value;
              })
          }

          // 确认密码输入
          Column({ space: 8 }) {
            Text('确认密码')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请再次输入密码' })
              .type(InputType.Password)
              .height(48)
              .borderRadius(8)
              .backgroundColor('#F5F5F5')
              .border({ width: 1, color: Color.Transparent })
              .focusOnTouch(true)
              .showPasswordIcon(true)
              .onChange((value) => {
                this.confirmPassword = value;
              })
          }

          // 验证码输入
          Column({ space: 8 }) {
            Text('邮箱验证码')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row({ space: 12 }) {
              TextInput({ placeholder: '请输入6位验证码' })
                .type(InputType.Number)
                .height(48)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .border({ width: 1, color: Color.Transparent })
                .layoutWeight(1)
                .maxLength(6)
                .focusOnTouch(true)
                .onChange((value) => {
                  this.verificationCode = value;
                })

              Button(this.countdown > 0 ? `${this.countdown}s` : (this.isSendingCode ? '发送中...' : '发送验证码'))
                .height(48)
                .borderRadius(8)
                .backgroundColor(this.countdown > 0 || this.isSendingCode ? '#CCCCCC' : '#007AFF')
                .fontColor(Color.White)
                .fontSize(14)
                .enabled(this.countdown <= 0 && !this.isSendingCode)
                .onClick(() => this.sendVerificationCode())
            }
          }
        }
        .width('100%')

        // 注册按钮
        Button(this.isRegistering ? '注册中...' : '立即注册')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isRegistering ? '#CCCCCC' : '#007AFF')
          .fontColor(Color.White)
          .margin({ top: 40 })
          .enabled(!this.isRegistering)
          .onClick(() => this.handleRegister())

        // 底部提示
        Row() {
          Text('已有账号？')
            .fontSize(14)
            .fontColor('#666666')

          Text('立即登录')
            .fontSize(14)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
            .onClick(() => this.goBackToLogin())
        }
        .margin({ top: 30 })
        .justifyContent(FlexAlign.Center)
      }
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 20 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}