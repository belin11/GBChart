### 1 折线图的使用
#### 1.1功能简介
支持或满足以下功能，如下：
- x轴、y轴分别可支持是否显示，以及它的颜色、线宽
- x轴文字支持大小、颜色、旋转
- y轴文字支持是否显示、大小、颜色、格式
- y轴文字不设置，可根据点的值自动计算
- 折线图可支持设置边距
- 横向分隔虚线可支持是否显示，以及它的颜色、线宽
- 折线可支持动画、颜色、线宽，支持显示一条或多条折线
- 折线可支持直线、贝塞尔曲线
- 折线上的点支持是否显示、填充颜色、描边颜色，以及有圆形、方形、三角形三种形状可选
- 折线上的点支持是否显示文字，以及文字的颜色、大小以及格式
- 可支持一条折线中显示渐变区域
- 可支持折线图更新
---
大家肯定会说：无图说个JB。行，先上效果图，是不是有种熟悉的感觉？
![折线图.png](https://github.com/belin11/GBChart/blob/master/折线图.png)

#### 1.2实现步骤
实现步骤大概如下：
1. 首先绘制x轴、y轴和横向分割虚线
2. 显示x轴和y轴的文字控件
3. 计算所有折线上点的位置
4. 绘制折线以及折线上的点
5. 显示折线上点的文字控制

实现步骤很清晰，看上去不难，其实里面有很多细节需要调整和优化，比较花时间。

####3.如何使用
那我直接上代码，这样就一目了然，使用起来还是很简单的
```
    GBLineChart *chart = [[GBLineChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 220)];
    [self.view addSubview:chart];
    chart.XLabelTitles = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月",];
//    chart.YLabelTitles = @[@"0", @"20", @"40", @"60", @"80", @"100"];
    chart.XLabelRotationAngle = M_PI/6;
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];

    for (int i = 0; i < chart.XLabelTitles.count; i++) {
        NSNumber *a = [NSNumber numberWithInteger:arc4random() % 100];
        [array addObject:a];
        [array1 addObject:[NSNumber numberWithInteger:arc4random() % 100]];
    }
    
    GBLineChartData *data = [GBLineChartData new];
    data.lineAlpha = 0.7;
    data.lineColor = [UIColor blueColor];
    data.lineWidth = 1;
    data.itemCount = array.count;
    data.lineChartPointStyle = GBLineChartPointStyleCircle;
    data.inflexionPointStrokeColor = [UIColor redColor];
    data.inflexionPointFillColor = [UIColor greenColor];
    data.inflexionPointWidth = 6;
    
    data.showPointLabel = YES;
    data.pointLabelFont = [UIFont systemFontOfSize:10];
    data.pointLabelColor = [UIColor blackColor];
    data.pointLabelFormat = @"%0.1f";
    
    data.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
      
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue]];
    };
    
    GBLineChartData *data1 = [GBLineChartData new];
    data1.lineAlpha = 1;
    data1.lineColor = [UIColor orangeColor];
    data1.lineWidth = 3;
    data1.itemCount = array1.count;
    data1.lineChartPointStyle = GBLineChartPointStyleSquare;
    data1.inflexionPointStrokeColor = [UIColor cyanColor];
    data1.inflexionPointWidth = 5;
    
    data1.showPointLabel = NO;
    data1.pointLabelFont = [UIFont systemFontOfSize:10];
    data1.pointLabelColor = [UIColor blackColor];
    data1.pointLabelFormat = @"%.0f";
    
    data1.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
        
        return [GBLineChartDataItem dataItemWithY:[array1[item] floatValue]];
    };
    
    chart.lineChartDatas = @[data, data1];
    chart.showGradientArea = YES;
    chart.chartMarginLeft = 35;
    
    chart.startGradientColor = [[UIColor yellowColor] colorWithAlphaComponent:0.9];
    chart.endGradientColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    chart.yLabelBlockFormatter = ^NSString *(CGFloat value) {
      
        return [NSString stringWithFormat:@"%1.1f", value];
    };
    chart.showSmoothLines = YES;
    [chart strokeChart];
    _lineChart = chart;
```
好了，最后希望大大们下载使用，提出宝贵意见，一起学习进步~~~
---

### 2.圆环图的使用

**首先**，我们看一下效果图：
![圆环效果图.png](https://github.com/belin11/GBChart/blob/master/圆状图.png)

**其次**，实现原理也是比较简单的，底部是一个圆，上面同样位置现叠加一个有会值的圆，中间的文字引用第三方框架***[UICountingLabel](https://github.com/dataxpress/UICountingLabel) ***

使用起来也非常简单
```
    GBCircleChart *circleChart = [[GBCircleChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200) total:@100 current:@30 clockwise:YES shadow:YES shadowColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] displayCountingLabel:YES overrideLineWidth:@4];
    [self.view addSubview:circleChart];
    circleChart.strokeColorGradientStart = [UIColor blueColor];
    circleChart.strokeColor = [UIColor redColor];
//    circleChart.shadowColor = [UIColor blueColor];
    circleChart.countingLabel.formatBlock = ^NSString *(CGFloat value) {
      
        return [NSString stringWithFormat:@"%0.0f分\n我的成绩单", value];
    };
    [circleChart strokeChart];
    _circleChart = circleChart;
```


