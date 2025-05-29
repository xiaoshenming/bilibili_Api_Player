/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { router } from '@kit.ArkUI';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { splashImages } from '../viewmodel/SplashModel';
// 导入TokenManager
import { tokenManager } from '../utils/TokenManager';
// 【新增】导入 AbilityKit 的 common 模块
import { common } from '@kit.AbilityKit';
@Entry
@Component
struct Index {
  private swiperController: SwiperController = new SwiperController();
  private data: Resource[] = [];
  @State countdown: number = Const.COUNTDOWN;
  @State showSwiper: boolean = false;
  private timer: number = 0;

  // aboutToAppear 保持不变
  aboutToAppear(): void {
    let data: Resource[] = [];
    let hours = new Date().getHours();
    if (hours >= Const.MORNING_TIME && hours < Const.EVENING_TIME) {
      data = splashImages.day;
    } else if (hours >= Const.EVENING_TIME && hours <= Const.NIGHT_TIME) {
      data = splashImages.dusk;
    } else {
      data = splashImages.night;
    }
    this.data = data;
    setTimeout(() => {
      this.showSwiper = true;
      this.startTiming();
    }, Const.SPLASH_DURATION);
  }

  startTiming() {
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown === 0) {
        this.clearTiming();
        // 调用新的导航决策函数
        this.decideAndNavigate();
      }
    }, Const.DURATION);
  }

  clearTiming() {
    if (this.timer !== null && this.timer !== 0) { // 检查条件更严谨
      clearInterval(this.timer);
      this.timer = 0;
    }
  }

  // 【核心修改】
  // 原 jumpToMainPage() 函数被替换为 decideAndNavigate()
  async decideAndNavigate() {
    this.clearTiming();
    // 获取UIAbility的上下文，用于读写Preferences
    const context = AppStorage.get('uiAbilityContext') as common.UIAbilityContext;

    // 检查是否存在Token
    const token = await tokenManager.getToken(context);

    if (token) {
      // 如果有token，跳转到主页
      // 这里可以增加一步，调用后端的/api/status接口验证token有效性，如果无效则清除token并跳转登录页
      console.info('Token found, navigating to MainPage.');
      router.replaceUrl({
        url: 'pages/MainPage'
      });
    } else {
      // 如果没有token，跳转到登录页
      console.info('No token found, navigating to LoginPage.');
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    }
  }

  aboutToDisappear() {
    this.clearTiming();
  }

  build() {
    Column() {
      Stack() {
        if (this.showSwiper) {
          Swiper(this.swiperController) {
            ForEach(this.data, (item: Resource) => {
              Image(item)
                .width(Const.FULL_SIZE)
                .height(Const.FULL_SIZE)
                .objectFit(ImageFit.Cover)
            })
          }
          .loop(true)
          .interval(2 * Const.DURATION)
          .duration(Const.DURATION)
          .autoPlay(true)
          .indicator(false)
          .curve(Curve.Linear)
          .onChange((index: number) => {
            console.info(index.toString())
          })

          Text() {
            Span($r('app.string.skip'))
            Span(`${this.countdown}`)
          }
          // 点击跳过按钮，也执行导航决策
          .onClick(() => this.decideAndNavigate())
          .fontColor(Color.White)
          .fontSize($r('app.float.12fp'))
          .backgroundColor($r('app.color.swiper_jump_bg_color'))
          .width($r('app.float.63'))
          .height($r('app.float.24'))
          .borderRadius($r('app.float.10'))
          .textAlign(TextAlign.Center)
          .position({
            x: Const.PERCENTAGE_78,
            y: $r('app.float.35')
          })
        } else {
          Image($r('app.media.splash_bg'))
            .width('100%')
            .height('100%')
          Image($r('app.media.ic_splash'))
            .width($r('app.float.192'))
            .height($r('app.float.192'))
            .offset({
              y: `-${Const.PERCENTAGE_15}`
            })
            .objectFit(ImageFit.Contain)

          Column() {
            Text(Const.SPLASH_DES)
              .fontColor(Color.White)
              .fontSize($r('app.float.font_size_24fp'))
              .fontWeight(FontWeight.Medium)

            Text(Const.SPLASH_WELCOME)
              .fontSize($r('app.float.font_size_16fp'))
              .fontColor(Color.White)
              .margin({
                top: $r('app.float.5')
              })
          }
          .offset({
            y: Const.PERCENTAGE_25
          })
        }
      }
    }
    .height(Const.FULL_SIZE)
    .width(Const.FULL_SIZE)
  }
}