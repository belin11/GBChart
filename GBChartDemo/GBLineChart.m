//
//  GBLineChart.m
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBLineChart.h"

@interface GBLineChart ()

@property(nonatomic) NSMutableArray *chartLineArray;  // Array[CAShapeLayer]
@property(nonatomic) NSMutableArray *chartPointArray; // Array[CAShapeLayer] save the point layer

@property(nonatomic) NSMutableArray *linePath;       // Array of line path, one for each line.
@property(nonatomic) NSMutableArray *pointPath;//

@property (nonatomic, strong) NSMutableArray *pointValues;

@property (nonatomic, assign) CGFloat extraX;

@property (nonatomic, strong) NSMutableArray *pointLabels;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;//渐变图形

@property (nonatomic, strong) CAShapeLayer *maskLayer;//

@end

@implementation GBLineChart

#pragma mark - 初始化
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self configDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self configDefaultValues];
    }
    return self;
}

#pragma mark - setter方法
- (void)setLineChartDatas:(NSArray *)lineChartDatas {
    
    //把数据转化为坐标点
    _lineChartDatas = lineChartDatas;
    CGFloat eachSectionWidth = (_chartCavanWidth - _extraX)/(_XLabelTitles.count-1);
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    
    for (int i = 0; i < lineChartDatas.count; i++) {
        
        CGFloat x = _chartMarginLeft + _extraX + eachSectionWidth * i;
        NSLog(@"x = %f", x);
        CGFloat y = yAxisMax - [lineChartDatas[i] floatValue] / 100.0 * _chartCavanHeight;
        [self.pointValues addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    
    }
}

- (void)setXLabelTitles:(NSArray *)XLabelTitles {
    
    _XLabelTitles = XLabelTitles;
}

#pragma mark - Public Method
- (void)strokeChart {
    
    [self setXLabel];
    [self setYLabel];
    [self setLineLayers];
    [self setGradientLayer];
    [self setPointLayers];
    [self setPointLabels];
}

- (void)updateChartDatas:(NSArray *)data {
    
    for (CAShapeLayer *l in self.chartPointArray) {
        [l removeFromSuperlayer];
    }
    for (UILabel *l in self.pointLabels) {
        [l removeFromSuperview];
    }
    for (CAShapeLayer *l in self.chartLineArray) {
        [l removeFromSuperlayer];
    }
    [_maskLayer removeFromSuperlayer];
    [_gradientLayer removeFromSuperlayer];
    
    [self.pointValues removeAllObjects];
    [self.chartPointArray removeAllObjects];
    [self.pointLabels removeAllObjects];
    [self.chartLineArray removeAllObjects];
    self.lineChartDatas = data;
    [self strokeChart];
}

#pragma mark - 创建view和layer
- (void)setPointLayers {
    
    for (int i = 0; i < _pointValues.count; i++) {
        
        CGPoint point = [_pointValues[i] CGPointValue];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:3 startAngle:0 endAngle:2*M_PI clockwise:YES];
        path.lineWidth = 0.5;
        
        CAShapeLayer *pointLayer = [CAShapeLayer layer];
        pointLayer.path = path.CGPath;
        
        pointLayer.fillColor = [UIColor whiteColor].CGColor;
        pointLayer.strokeColor = [UIColor greenColor].CGColor;
        
        [self.layer addSublayer:pointLayer];
        [self.pointPath addObject:path];
        [self.chartPointArray addObject:pointLayer];
    }
}

- (void)setPointLabels {
    
    for (int i = 0; i < _pointValues.count; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForPointLabelAtIndex:i]];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor greenColor];
        label.text = _lineChartDatas[i];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [self.pointLabels addObject:label];
    }
}

- (void)setLineLayers {
    
    for (int i = 0; i < _pointValues.count-1; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint point1 = [_pointValues[i] CGPointValue];
        CGPoint point2 = [_pointValues[i+1] CGPointValue];
        [path moveToPoint:point1];
        [path addLineToPoint:point2];
        path.lineWidth = 0.5;
       
        //折线
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.fillColor = [UIColor clearColor].CGColor;
        lineLayer.strokeColor = [UIColor greenColor].CGColor;
        lineLayer.path = path.CGPath;
        [self.layer addSublayer:lineLayer];
        [self.chartLineArray addObject:lineLayer];
    }
}

- (void)setYLabel {
    //从下往上
    NSArray *title = @[@"0",@"20", @"40",@"60",@"80",@"100"];
    for (int i = 0; i < title.count; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForYLabelAtIndex:i]];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor grayColor];
        label.text = title[i];
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
    }
}

- (void)setXLabel{
    
    //从左到右
    for (int i = 0; i < _XLabelTitles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForXLabelAtIndex:i]];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor grayColor];
        label.text = _XLabelTitles[i];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
}

- (void)setGradientLayer {
    
    NSValue *value = self.pointValues.firstObject;
    CGPoint point1 = value.CGPointValue;
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    point1 = CGPointMake(point1.x, yAxisMax);
    
    CGPoint point2 = [self.pointValues.lastObject CGPointValue];
    point2 = CGPointMake(point2.x, yAxisMax);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    
    for (int i = 0 ; i < _pointValues.count; i++) {
        
        [path addLineToPoint:[_pointValues[i] CGPointValue]];
    }
    
    [path addLineToPoint:point2];
    [path closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskLayer.strokeColor = [UIColor clearColor].CGColor;
    maskLayer.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.4].CGColor;
    _maskLayer = maskLayer;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
    gradientLayer.colors = @[(__bridge id)[[UIColor greenColor] colorWithAlphaComponent:0.8].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.locations = @[@0, @0.9];
    gradientLayer.mask = maskLayer;
    _gradientLayer = gradientLayer;
}

#pragma mark - frame
- (CGRect)frameForPointLabelAtIndex:(NSInteger)index {
    
    CGFloat w = 30;
    CGFloat h = 12;
    NSValue *value = _pointValues[index];
    CGFloat x = value.CGPointValue.x - w/2;
    CGFloat y = value.CGPointValue.y - h - 4;
    return CGRectMake(x, y, w, h);
}

- (CGRect)frameForYLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat eachSectionHeight = _chartCavanHeight / 5;
    CGFloat w = 18;
    CGFloat h = 10;
    CGFloat x = _chartMarginLeft - w - 4;
    CGFloat y = yAxisMax - h/2 - index * eachSectionHeight;
    
    return CGRectMake(x, y, w, h);
}
- (CGRect)frameForXLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat eachSectionWidth = (_chartCavanWidth - _extraX)/(_XLabelTitles.count-1);
    CGFloat w = 25;
    CGFloat h = 10;
    CGFloat x = _chartMarginLeft + (_extraX - w/2) + index * eachSectionWidth;
    CGFloat y = 5 + yAxisMax;
    return CGRectMake(x, y, w, h);
}

#pragma mark - 设置默认属性
- (void)configDefaultValues {
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.chartLineArray = [NSMutableArray new];
    self.chartPointArray = [NSMutableArray new];
    self.pointPath = [NSMutableArray new];
    self.linePath = [NSMutableArray new];
    self.pointLabels = [NSMutableArray new];
    self.pointValues = [NSMutableArray new];
    self.userInteractionEnabled = YES;
    
    _extraX = 10;
    _chartMarginLeft = 25.0;
    _chartMarginRight = 25.0;
    _chartMarginTop = 25.0;
    _chartMarginBottom = 25.0;
    
    
    _chartCavanWidth = self.frame.size.width - _chartMarginLeft - _chartMarginRight;
    _chartCavanHeight = self.frame.size.height - _chartMarginBottom - _chartMarginTop;
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat xAxisMax = _chartCavanWidth + _chartMarginRight;
    //画坐标轴
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 1);
    CGContextMoveToPoint(ctx, _chartMarginLeft, 0);
    CGContextAddLineToPoint(ctx, _chartMarginLeft, yAxisMax);
//    CGContextMoveToPoint(ctx, _chartMarginLeft, yAxisMax);
    CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax);
    CGContextStrokePath(ctx);
    
    //绘制横线
//    ctx = UIGraphicsGetCurrentContext();
    CGFloat eachSectionHeight = _chartCavanHeight / 5;
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGFloat dash[] = {3,3};
    CGContextSetLineDash(ctx, 0.0, dash, 2);
    for (int i = 0; i < 5; i++) {
        
        CGContextMoveToPoint(ctx, _chartMarginLeft, yAxisMax - eachSectionHeight * (i+1));
        CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax - eachSectionHeight * (i+1));
        CGContextStrokePath(ctx);
    }
    
}


@end
