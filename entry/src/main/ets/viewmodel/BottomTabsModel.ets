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

import { BottomTabsItem } from './BottomTabsItem';

export const BottomTabsList: Array<BottomTabsItem> = [
  {
    icon: $r('app.media.house_0'),
    iconSelected: $r('app.media.house_1'),
    text: $r('app.string.bottom_text_Home')
  },
  {
    icon: $r('app.media.heart_0'),
    iconSelected: $r('app.media.heart_1'),
    text: $r('app.string.bottom_text_Dynamic')
  },
  {
    icon: $r('app.media.plus_0'),
    iconSelected: $r('app.media.plus_1'),
    text: $r('app.string.bottom_text_add')
  },
  {
    icon: $r('app.media.star_fill_0'),
    iconSelected: $r('app.media.star_fill_1'),
    text: $r('app.string.bottom_text_Vipshopping')
  },
  {
    icon: $r('app.media.gearshape_0'),
    iconSelected: $r('app.media.gearshape_1'),
    text: $r('app.string.bottom_text_Mine')
  }
]