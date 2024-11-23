/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { Home } from '../view/Home';
import { Dynamic } from '../view/Dynamic';
import { Add } from '../view/Add';
import { Vipshopping } from '../view/Vipshopping';
import { Mine } from '../view/Mine';
import { VideoPlayer } from './VideoPlayer';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { BottomTabsList } from '../viewmodel/BottomTabsModel';

@Entry
@Component
struct MainPage {
  @StorageLink('bottomTabIndex') bottomTabIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Image(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .width('40%')
        .height('40%')
        .objectFit(ImageFit.Contain)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(0.6)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_tabs_font_color_selected') : $r('app.color.bottom_tabs_font_color'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: 0.5 }, color: "#FF182431" })
    .backgroundColor($r('app.color.bottom_tabs_background_color'))//这里控制每个底部栏背景颜色
  }

  pageTransition() {
    PageTransitionEnter({ duration: Const.SHARED_DURATION })
      .slide(SlideEffect.Top)
    PageTransitionExit({ delay: Const.EXIT_DELAY })
      .opacity(0)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
      Tabs({ barPosition: BarPosition.End, index: this.bottomTabIndex, controller: this.controller }) {
        TabContent() {
          Home()
        }.tabBar(this.TabBuilder(0, 'Home'))

        TabContent() {
          Dynamic()
        }.tabBar(this.TabBuilder(1, 'Dynamic'))
        TabContent() {
          Add()
        }.tabBar(this.TabBuilder(2, 'add'))
        TabContent() {
          Vipshopping()
        }.tabBar(this.TabBuilder(3, 'Vipshopping'))
        TabContent() {
          Mine()
        }.tabBar(this.TabBuilder(4, 'Mine'))
      }
      .width('100%')
      .vertical(false)
      .barHeight('10%')
      .scrollable(false)
      .onChange((index: number) => {
        this.bottomTabIndex = index;
      })
      .height('100%')
    }
    .width('100%')
  }
}
