// entry/src/main/ets/pages/LoginPage.ets

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { apiService } from '../api/ApiService';
import { tokenManager } from '../utils/TokenManager';

@Entry
@Component
struct LoginPage {
  @State isLoginMode: boolean = true;
  // 【优化 1/4】将 email 状态变量重命名为更通用的 account
  @State account: string = '';
  @State password: string = '';
  @State name: string = ''; // 仅注册用
  @State emailForRegister: string = ''; // 【优化 2/4】注册时专门用于发送验证码的邮箱
  @State code: string = ''; // 仅注册用
  @State isSendingCode: boolean = false;
  @State isProcessing: boolean = false;

  private getUIAbilityContext(): common.UIAbilityContext {
    return AppStorage.get('uiAbilityContext') as common.UIAbilityContext;
  }

  async sendCode() {
    if (this.isSendingCode) return;
    if (!this.emailForRegister) { // 使用专门的注册邮箱变量
      promptAction.showToast({ message: '请输入注册邮箱地址' });
      return;
    }
    this.isSendingCode = true;
    try {
      // 【修复】确保注册时使用的 email 变量是正确的
      await apiService.sendVerificationCode(this.emailForRegister, 'register');
      promptAction.showToast({ message: '验证码已发送，请查收' });
    } catch (error) {
      const err = error as Error;
      promptAction.showToast({ message: `发送失败: ${err.message}` });
    } finally {
      this.isSendingCode = false;
    }
  }

  async handleSubmit() {
    if (this.isProcessing) return;
    this.isProcessing = true;

    try {
      const context = this.getUIAbilityContext();
      if (this.isLoginMode) { // 登录逻辑
        // 【修复】检查 account 变量
        if (!this.account || !this.password) {
          promptAction.showToast({ message: '账号和密码不能为空' });
          this.isProcessing = false; // 需要重置状态
          return;
        }
        // 【修复】将 account 变量传递给登录服务
        const result = await apiService.login(this.account, this.password);
        await tokenManager.saveToken(context, result.token);
        promptAction.showToast({ message: '登录成功' });
        router.replaceUrl({ url: 'pages/MainPage' });
      } else { // 注册逻辑
        // 【修复】确保注册时使用的 email 变量是正确的
        if (!this.name || !this.emailForRegister || !this.password || !this.code) {
          promptAction.showToast({ message: '请填写所有注册信息' });
          this.isProcessing = false; // 需要重置状态
          return;
        }
        await apiService.register(this.name, this.emailForRegister, this.password, this.code);
        promptAction.showToast({ message: '注册成功，请登录' });
        this.isLoginMode = true;
        this.password = '';
        this.code = '';
        // 注册成功后，将注册邮箱填入账号输入框，方便用户直接登录
        this.account = this.emailForRegister;
      }
    } catch (error) {
      const err = error as Error;
      promptAction.showToast({ message: err.message });
    } finally {
      this.isProcessing = false;
    }
  }

  build() {
    Column() {
      Text(this.isLoginMode ? '欢迎回来' : '创建新账号')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: '15%', bottom: 40 })

      Column({ space: 15 }) {
        if (this.isLoginMode) {
          // 【优化 3/4】登录输入框，提示更准确，并绑定到 account
          TextInput({ placeholder: '请输入邮箱或用户名' })
            .type(InputType.Normal)
            .onChange((value) => {
              this.account = value;
            })
        }

        if (!this.isLoginMode) {
          TextInput({ placeholder: '请输入用户名' })
            .type(InputType.Normal)
            .onChange((value) => { this.name = value; })
          // 【优化 4/4】注册时的邮箱输入框，绑定到 emailForRegister
          TextInput({ placeholder: '请输入邮箱' })
            .type(InputType.Email)
            .onChange((value) => { this.emailForRegister = value; })
        }

        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .onChange((value) => { this.password = value; })

        if (!this.isLoginMode) {
          Row() {
            TextInput({ placeholder: '请输入验证码' }).type(InputType.Number).layoutWeight(1)
              .onChange((value) => { this.code = value; })
            Button(this.isSendingCode ? '发送中...' : '发送验证码')
              .width(120).margin({ left: 10 }).enabled(!this.isSendingCode)
              .onClick(() => this.sendCode())
          }
        }
      }
      .width('85%')
      .alignItems(HorizontalAlign.Center)

      Button(this.isProcessing ? '处理中...' : (this.isLoginMode ? '登 录' : '注 册'))
        .type(ButtonType.Capsule).width('85%').height(50).fontSize(18).margin({ top: 30 })
        .enabled(!this.isProcessing)
        .onClick(() => this.handleSubmit())

      // 登录模式下的操作链接
      if (this.isLoginMode) {
        Column({ space: 16 }) {
          // 忘记密码链接
          Text('忘记密码？')
            .fontSize(14)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              router.pushUrl({ url: 'pages/ForgotPasswordPage' });
            })

          // 注册链接
          Row({ space: 5 }) {
            Text('还没有账号？')
              .fontSize(14)
              .fontColor('#666666')
            Text('立即注册')
              .fontSize(14)
              .fontColor('#007AFF')
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                router.pushUrl({ url: 'pages/RegisterPage' });
              })
          }
        }
        .margin({ top: 20 })
        .alignItems(HorizontalAlign.Center)
      } else {
        // 注册模式下的返回登录链接
        Row({ space: 5 }) {
          Text('已有账号？')
            .fontSize(14)
            .fontColor('#666666')
          Text('立即登录')
            .fontSize(14)
            .fontColor('#007AFF')
            .fontWeight(FontWeight.Medium)
            .onClick(() => { this.isLoginMode = !this.isLoginMode; })
        }
        .margin({ top: 20 })
      }
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}