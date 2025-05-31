/**
 * 忘记密码页面
 * 提供密码重置功能界面（暂时留空，后续可扩展）
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ForgotPasswordPage {
  @State email: string = '';
  @State verificationCode: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State currentStep: number = 1; // 1: 输入邮箱, 2: 输入验证码, 3: 设置新密码
  @State isSendingCode: boolean = false;
  @State isResetting: boolean = false;
  @State countdown: number = 0;


  private timer: number = -1;

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  // 发送验证码（暂时模拟）
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
      // TODO: 调用后端API发送重置密码验证码
      // await apiService.sendVerificationCode(this.email, 'reset_password');
      
      // 暂时模拟发送成功
      // await new Promise(resolve => setTimeout(resolve, 1000));
      promptAction.showToast({ message: '验证码已发送，请查收邮箱' });
      
      // 跳转到下一步
      this.currentStep = 2;
      
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
      promptAction.showToast({ message: '发送失败，请稍后重试' });
    } finally {
      this.isSendingCode = false;
    }
  }

  // 验证验证码（暂时模拟）
  async verifyCode() {
    if (!this.verificationCode.trim()) {
      promptAction.showToast({ message: '请输入验证码' });
      return;
    }

    if (this.verificationCode.length !== 6) {
      promptAction.showToast({ message: '验证码应为6位数字' });
      return;
    }

    // TODO: 调用后端API验证验证码
    // 暂时模拟验证成功
    promptAction.showToast({ message: '验证码正确' });
    this.currentStep = 3;
  }

  // 重置密码（暂时模拟）
  async resetPassword() {
    if (this.isResetting) return;

    if (!this.newPassword.trim()) {
      promptAction.showToast({ message: '请输入新密码' });
      return;
    }

    if (this.newPassword.length < 6) {
      promptAction.showToast({ message: '密码长度不能少于6位' });
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    this.isResetting = true;
    try {
      // TODO: 调用后端API重置密码
      // await apiService.resetPassword(this.email, this.verificationCode, this.newPassword);
      
      // 暂时模拟重置成功
      // await new Promise(resolve => setTimeout(resolve, 1000));
      promptAction.showToast({ message: '密码重置成功！请使用新密码登录' });
      
      // 延迟跳转回登录页面
      setTimeout(() => {
        router.back();
      }, 1500);
    } catch (error) {
      promptAction.showToast({ message: '重置失败，请稍后重试' });
    } finally {
      this.isResetting = false;
    }
  }

  // 返回上一步
  goBack() {
    if (this.currentStep > 1) {
      this.currentStep--;
    } else {
      router.back();
    }
  }

  // 获取当前步骤标题
  getStepTitle(): string {
    switch (this.currentStep) {
      case 1:
        return '找回密码';
      case 2:
        return '验证邮箱';
      case 3:
        return '设置新密码';
      default:
        return '找回密码';
    }
  }

  // 获取当前步骤描述
  getStepDescription(): string {
    switch (this.currentStep) {
      case 1:
        return '请输入您的注册邮箱，我们将发送验证码';
      case 2:
        return `验证码已发送至 ${this.email}`;
      case 3:
        return '请设置您的新密码';
      default:
        return '';
    }
  }

  @Builder
  buildStep1() {
    Column({ space: 20 }) {
      // 邮箱输入
      Column({ space: 8 }) {
        Text('邮箱地址')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请输入注册时使用的邮箱' })
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

      // 发送验证码按钮
      Button(this.isSendingCode ? '发送中...' : '发送验证码')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isSendingCode ? '#CCCCCC' : '#007AFF')
        .fontColor(Color.White)
        .enabled(!this.isSendingCode)
        .onClick(() => this.sendVerificationCode())
    }
    .width('100%')
  }

  @Builder
  buildStep2() {
    Column({ space: 20 }) {
      // 验证码输入
      Column({ space: 8 }) {
        Text('验证码')
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

          Button(this.countdown > 0 ? `${this.countdown}s` : '重新发送')
            .height(48)
            .borderRadius(8)
            .backgroundColor(this.countdown > 0 ? '#CCCCCC' : '#007AFF')
            .fontColor(Color.White)
            .fontSize(14)
            .enabled(this.countdown <= 0)
            .onClick(() => this.sendVerificationCode())
        }
      }

      // 验证按钮
      Button('验证并继续')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .onClick(() => this.verifyCode())
    }
    .width('100%')
  }

  @Builder
  buildStep3() {
    Column({ space: 20 }) {
      // 新密码输入
      Column({ space: 8 }) {
        Text('新密码')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请输入新密码（至少6位）' })
          .type(InputType.Password)
          .height(48)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: Color.Transparent })
          .focusOnTouch(true)
          .showPasswordIcon(true)
          .onChange((value) => {
            this.newPassword = value;
          })
      }

      // 确认新密码输入
      Column({ space: 8 }) {
        Text('确认新密码')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请再次输入新密码' })
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

      // 重置密码按钮
      Button(this.isResetting ? '重置中...' : '完成重置')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isResetting ? '#CCCCCC' : '#007AFF')
        .fontColor(Color.White)
        .enabled(!this.isResetting)
        .onClick(() => this.resetPassword())
    }
    .width('100%')
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
        .onClick(() => this.goBack())

        Text(this.getStepTitle())
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
        // 步骤指示器
        Row({ space: 8 }) {
          ForEach([1, 2, 3], (step: number) => {
            Row() {
              Text(step.toString())
                .fontSize(12)
                .fontColor(this.currentStep >= step ? Color.White : '#999999')
                .fontWeight(FontWeight.Medium)
            }
            .width(24)
            .height(24)
            .borderRadius(12)
            .backgroundColor(this.currentStep >= step ? '#007AFF' : '#E5E5E5')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            if (step < 3) {
              Divider()
                .width(40)
                .height(2)
                .color(this.currentStep > step ? '#007AFF' : '#E5E5E5')
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 40 })

        // 标题和描述
        Column() {
          Text(this.getStepTitle())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Text(this.getStepDescription())
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 40 })
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')

        // 根据当前步骤显示不同内容
        if (this.currentStep === 1) {
          this.buildStep1()
        } else if (this.currentStep === 2) {
          this.buildStep2()
        } else if (this.currentStep === 3) {
          this.buildStep3()
        }

        Blank()

        // 底部提示
        Row() {
          Text('想起密码了？')
            .fontSize(14)
            .fontColor('#666666')

          Text('立即登录')
            .fontSize(14)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.back();
            })
        }
        .margin({ bottom: 20 })
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