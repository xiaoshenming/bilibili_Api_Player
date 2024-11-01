// /*
//  * Copyright (c) 2023 Huawei Device Co., Ltd.
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
//
//
// import { Home } from '../view/Home';
// import { Dynamic } from '../view/Dynamic';
// import { Add } from '../view/Add';
// import { Vipshopping } from '../view/Vipshopping';
// import { Mine } from '../view/Mine';
// import { CommonConstants as Const } from '../common/constants/CommonConstants';
// import { BottomTabsList } from '../viewmodel/BottomTabsModel';
//
// @Entry
// @Component
// struct Index {
//   @StorageLink('bottomTabIndex') bottomTabIndex: number = 1;
//   private controller: TabsController = new TabsController();
//
//   @Builder
//   TabBuilder(index: number, name: string) {
//     Column() {
//       Image(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
//         .width('40%')
//         .height('40%')
//         .objectFit(ImageFit.Contain)
//
//       Text(BottomTabsList[index].text)
//         .fontSize($r('app.float.bottom_font_size'))
//         .opacity(0.6)
//         .fontColor(this.bottomTabIndex === index ?
//         $r('app.color.bottom_tabs_font_color_selected') : $r('app.color.bottom_tabs_font_color'))
//     }
//     .width('100%')
//     .height('100%')
//     .justifyContent(FlexAlign.Center)
//     .border({ width: { top: 0.5 }, color: "#FF182431" })
//     .backgroundColor($r('app.color.bottom_tabs_background_color'))//这里控制每个底部栏背景颜色
//   }
//
//   pageTransition() {
//     PageTransitionEnter({ duration: Const.SHARED_DURATION })
//       .slide(SlideEffect.Top)
//     PageTransitionExit({ delay: Const.EXIT_DELAY })
//       .opacity(0)
//   }
//
//   build() {
//     Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
//       Tabs({ barPosition: BarPosition.End, index: this.bottomTabIndex, controller: this.controller }) {
//         TabContent() {
//           Home()
//         }.tabBar(this.TabBuilder(0, 'Home'))
//
//         TabContent() {
//           Dynamic()
//         }.tabBar(this.TabBuilder(1, 'Dynamic'))
//         TabContent() {
//           Add()
//         }.tabBar(this.TabBuilder(2, 'add'))
//         TabContent() {
//           Vipshopping()
//         }.tabBar(this.TabBuilder(3, 'Vipshopping'))
//         TabContent() {
//           Mine()
//         }.tabBar(this.TabBuilder(4, 'Mine'))
//       }
//       .width('100%')
//       .vertical(false)
//       .barHeight('10%')
//       .scrollable(false)
//       .onChange((index: number) => {
//         this.bottomTabIndex = index;
//       })
//       .height('100%')
//     }
//     .width('100%')
//   }
// }

import { it } from '@ohos/hypium';
import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';

@Entry
@Component
struct Index {
  private myController:VideoController =new VideoController();
  private datas:MyDataSource =new MyDataSource();
  @State index:number =0;
  videoDatas:Array<VideoData> =[
    {
      video:$rawfile('short_video1.mp4'),
      name:'@山猫',
      description:'海的那边，是.....',
      time:'2024-01-24 12:32',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'1234',
      commentCount:'1122',
      favoriteCount:'445',
      shareount:'3321',
      hotsport:'海',
      play:true,
      index:0
    },
    {
      video:$rawfile('short_video2.mp4'),
      name:'@登山爱好者',
      description:'#雪山',
      time:'2022-04-24 12:12',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'1884',
      commentCount:'1542',
      favoriteCount:'4545',
      shareount:'861',
      hotsport:'雪的距离',
      play:true,
      index:1
    },
    {
      video:$rawfile('short_video3.mp4'),
      name:'@平平淡淡',
      description:'生活不只是眼前的苟且，还有诗和远方',
      time:'2023-08-20 10:45',
      controller:this.myController,
      auto:true,
      head:$r('app.media.b'),
      likeCount:'777',
      commentCount:'4576',
      favoriteCount:'8896',
      shareount:'1112',
      hotsport:'日出',
      play:true,
      index:2
    },

  ];
  aboutToAppear(): void {
    //把数组VideoDatas中的元素加载进datas对象中
    for (let index = 0; index < this.videoDatas.length; index++) {
      this.datas.pushData(this.videoDatas[index]);
    }
  }
  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }
  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Column(){
      // Video({
      //   src:'https://www.gcc.edu.cn/videos/2024-05/5b56fb85b44d46f99034cda0da35c025.mp4',
      //   controller:this.myController
      // })
      //   .objectFit(ImageFit.Contain)
      //   .autoPlay(true)

      Swiper(){
        LazyForEach(this.datas,(item:VideoData,index:number)=>{
          //加载元素
          Video({
            src:item.video,
            controller:item.controller
          })
            .autoPlay(true)
            .objectFit(ImageFit.Contain)

        },(item:VideoData)=>JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
      .vertical(true)

    }
    .width('100%')
    .height('100%')
  }
}