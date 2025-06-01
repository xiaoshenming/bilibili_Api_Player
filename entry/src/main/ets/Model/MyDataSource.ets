

import { BasicDataSource } from './BasicDataSource';
import { VideoData } from './VideoData';

export class MyDataSource extends BasicDataSource{
  private dataArray: Array<VideoData> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): VideoData {
    return this.dataArray[index];
  }

  public addData(index: number, data: VideoData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: VideoData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
  // 你可以增加一个方法来获取全部数据，这样就可以传递整个数组
  public getAllData(): Array<VideoData> {
    return this.dataArray;
  }

  // 更新指定索引的数据
  public updateDataAtIndex(index: number, data: VideoData): void {
    if (index >= 0 && index < this.dataArray.length) {
      this.dataArray[index] = data;  // 更新指定索引的数据
      // this.notifyDataUpdate(index);  // 通知数据源某个索引的数据已经更新
    } else {
      console.error('Index out of bounds');
    }
  }

  // 清空所有数据
  public clearData(): void {
    const length = this.dataArray.length;
    this.dataArray = [];
    this.notifyDataChange(0);
  }
}
