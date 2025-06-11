
// 接口定义
interface BannerItem {
  image: string;
  title: string;
}

interface CategoryItem {
  icon: string;
  name: string;
  color: string;
}

interface ProductItem {
  image: string;
  title: string;
  price: string;
  originalPrice: string;
  tag: string;
}

@Component
export struct Vipshopping {
  @State selectedTab: number = 0;
  @State currentBanner: number = 0;
  private bannerTimer: number = -1;

  // 轮播图数据
  private bannerData: BannerItem[] = [
    { image: 'https://i0.hdslb.com/bfs/activity-plat/static/20220614/e369244d0b14644f5e1a06431e22a4d5/KJunX09bM4.png', title: 'B站会员专享商品' },
    { image: 'https://i0.hdslb.com/bfs/activity-plat/static/20220614/e369244d0b14644f5e1a06431e22a4d5/VEzQJdAzSI.png', title: '限时优惠活动' },
    { image: 'https://i0.hdslb.com/bfs/activity-plat/static/20220614/e369244d0b14644f5e1a06431e22a4d5/MjQxOTY4NzY.png', title: '新品首发' }
  ];

  // 商品分类数据
  private categoryData: CategoryItem[] = [
    { icon: '🎮', name: '游戏周边', color: '#FF6B9D' },
    { icon: '👕', name: '服饰配件', color: '#4ECDC4' },
    { icon: '📱', name: '数码产品', color: '#45B7D1' },
    { icon: '🎨', name: '文创用品', color: '#96CEB4' },
    { icon: '🏠', name: '生活用品', color: '#FFEAA7' },
    { icon: '📚', name: '图书音像', color: '#DDA0DD' },
    { icon: '🍭', name: '零食饮品', color: '#FFB6C1' },
    { icon: '🎁', name: '礼品卡券', color: '#87CEEB' }
  ];

  // 推荐商品数据
  private productData: ProductItem[] = [
    { image: 'https://i0.hdslb.com/bfs/mall/mall/b8/85/b885c2b35f3d0f5c9b8c8f5c9b8c8f5c.png', title: 'B站22娘手办模型', price: '¥299', originalPrice: '¥399', tag: '会员专享' },
    { image: 'https://i0.hdslb.com/bfs/mall/mall/c9/96/c996d3c46f4e1f6d0c9d9f6d0c9d9f6d.png', title: 'bilibili周边T恤', price: '¥89', originalPrice: '¥129', tag: '限时特价' },
    { image: 'https://i0.hdslb.com/bfs/mall/mall/d0/a7/d0a7e4d57f5f2f7e1d0e0f7e1d0e0f7e.png', title: 'B站定制马克杯', price: '¥39', originalPrice: '¥59', tag: '新品上市' },
    { image: 'https://i0.hdslb.com/bfs/mall/mall/e1/b8/e1b8f5e68f6f3f8f2e1f1f8f2e1f1f8f.png', title: 'UP主联名徽章', price: '¥19', originalPrice: '¥29', tag: '热销' }
  ];

  aboutToAppear() {
    // 启动轮播图定时器
    this.bannerTimer = setInterval(() => {
      this.currentBanner = (this.currentBanner + 1) % this.bannerData.length;
    }, 3000);
  }

  aboutToDisappear() {
    // 清除定时器
    if (this.bannerTimer !== -1) {
      clearInterval(this.bannerTimer);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()
      
      // 主要内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 轮播图
          this.buildBanner()
          
          // 会员特权卡片
          this.buildVipPrivileges()
          
          // 商品分类
          this.buildCategories()
          
          // 优惠券区域
          this.buildCoupons()
          
          // 推荐商品
          this.buildRecommendProducts()
          
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
      Text('会员购物')
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
        
        Text('🛒')
          .fontSize(20)
          .onClick(() => {
            // 购物车功能
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetY: 1 })
  }

  // 构建轮播图
  @Builder
  buildBanner() {
    Stack() {
      Swiper() {
        ForEach(this.bannerData, (item: BannerItem) => {
          Stack() {
            Image(item.image)
              .width('100%')
              .height(180)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
              .alt($r('app.media.photo35'))
            
            // 渐变遮罩
            Column()
              .width('100%')
              .height(60)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#00000000', 0.0], ['#80000000', 1.0]]
              })
              .borderRadius({ bottomLeft: 12, bottomRight: 12 })
              .position({ x: 0, y: 120 })
            
            // 标题
            Text(item.title)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .position({ x: 16, y: 140 })
          }
        })
      }
      .width('100%')
      .height(180)
      .borderRadius(12)
      .autoPlay(true)
      .interval(3000)
      .indicator(false)
      .onChange((index: number) => {
        this.currentBanner = index;
      })
      
      // 自定义指示器
      Row({ space: 6 }) {
        ForEach(this.bannerData, (item: BannerItem, index: number) => {
          Circle({ width: 6, height: 6 })
            .fill(this.currentBanner === index ? '#FF6B9D' : '#FFFFFF80')
        })
      }
      .position({ x: '50%', y: 160 })
      .translate({ x: '-50%' })
    }
    .margin({ top: 16 })
  }

  // 构建会员特权卡片
  @Builder
  buildVipPrivileges() {
    Column({ space: 12 }) {
      Row() {
        Text('会员特权')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#FF6B9D')
      }
      .width('100%')
      
      Row({ space: 12 }) {
        // 专享折扣
        Column({ space: 8 }) {
          Text('💎')
            .fontSize(24)
          Text('专享折扣')
            .fontSize(14)
            .fontColor('#333333')
          Text('9折起')
            .fontSize(12)
            .fontColor('#FF6B9D')
        }
        .width('25%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        
        // 免费配送
        Column({ space: 8 }) {
          Text('🚚')
            .fontSize(24)
          Text('免费配送')
            .fontSize(14)
            .fontColor('#333333')
          Text('包邮')
            .fontSize(12)
            .fontColor('#4ECDC4')
        }
        .width('25%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        
        // 专属客服
        Column({ space: 8 }) {
          Text('👥')
            .fontSize(24)
          Text('专属客服')
            .fontSize(14)
            .fontColor('#333333')
          Text('7x24h')
            .fontSize(12)
            .fontColor('#45B7D1')
        }
        .width('25%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        
        // 积分返还
        Column({ space: 8 }) {
          Text('⭐')
            .fontSize(24)
          Text('积分返还')
            .fontSize(14)
            .fontColor('#333333')
          Text('双倍')
            .fontSize(12)
            .fontColor('#FFEAA7')
        }
        .width('25%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }
      .width('100%')
    }
    .margin({ top: 16 })
  }

  // 构建商品分类
  @Builder
  buildCategories() {
    Column({ space: 12 }) {
      Row() {
        Text('商品分类')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      
      Grid() {
        ForEach(this.categoryData, (item: CategoryItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(item.icon)
                .fontSize(28)
              Text(item.name)
                .fontSize(12)
                .fontColor('#333333')
            }
            .width('100%')
            .height(80)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            .border({ width: 2, color: item.color, radius: 12 })
            .onClick(() => {
              // 分类点击事件
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(172)
    }
    .margin({ top: 16 })
  }

  // 构建优惠券区域
  @Builder
  buildCoupons() {
    Column({ space: 12 }) {
      Row() {
        Text('限时优惠券')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text('更多优惠 >')
          .fontSize(14)
          .fontColor('#FF6B9D')
      }
      .width('100%')
      
      Row({ space: 12 }) {
        // 满减券
        Row({ space: 12 }) {
          Column() {
            Text('¥20')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('满100可用')
              .fontSize(10)
              .fontColor('#FFFFFF')
          }
          .width(60)
          .height(60)
          .backgroundColor('#FF6B9D')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          
          Column({ space: 4 }) {
            Text('满减券')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Text('满100减20')
              .fontSize(12)
              .fontColor('#666666')
            Text('有效期至12-31')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          Button('领取')
            .width(50)
            .height(28)
            .fontSize(12)
            .backgroundColor('#FF6B9D')
            .borderRadius(14)
        }
        .width('48%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .padding(12)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        
        // 折扣券
        Row({ space: 12 }) {
          Column() {
            Text('9折')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('无门槛')
              .fontSize(10)
              .fontColor('#FFFFFF')
          }
          .width(60)
          .height(60)
          .backgroundColor('#4ECDC4')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          
          Column({ space: 4 }) {
            Text('折扣券')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Text('全场9折')
              .fontSize(12)
              .fontColor('#666666')
            Text('有效期至12-31')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          Button('领取')
            .width(50)
            .height(28)
            .fontSize(12)
            .backgroundColor('#4ECDC4')
            .borderRadius(14)
        }
        .width('48%')
        .height(80)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .padding(12)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }
      .width('100%')
    }
    .margin({ top: 16 })
  }

  // 构建推荐商品
  @Builder
  buildRecommendProducts() {
    Column({ space: 12 }) {
      Row() {
        Text('为你推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text('换一批 🔄')
          .fontSize(14)
          .fontColor('#FF6B9D')
      }
      .width('100%')
      
      Grid() {
        ForEach(this.productData, (item: ProductItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Stack() {
                Image(item.image)
                  .width('100%')
                  .height(120)
                  .borderRadius({ topLeft: 12, topRight: 12 })
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.photo35'))
                
                // 标签
                Text(item.tag)
                  .fontSize(10)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF6B9D')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
                  .position({ x: 8, y: 8 })
              }
              
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .fontColor('#333333')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                Row({ space: 8 }) {
                  Text(item.price)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FF6B9D')
                  
                  Text(item.originalPrice)
                    .fontSize(12)
                    .fontColor('#999999')
                    .decoration({ type: TextDecorationType.LineThrough })
                }
                .alignItems(VerticalAlign.Bottom)
              }
              .padding({ left: 8, right: 8, bottom: 8 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            .onClick(() => {
              // 商品详情页
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
    }
    .margin({ top: 16 })
  }
}