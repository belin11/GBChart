//
//  GBLineChart.m
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBLineChart.h"
#import "GBLineChartData.h"

@interface GBLineChart () <CAAnimationDelegate>

@property(nonatomic) NSMutableArray *chartLineArrayArray;  // Array Array[CAShapeLayer] save the line layer
@property(nonatomic) NSMutableArray *chartPointArrayArray; // Array Array[CAShapeLayer] save the point layer

@property(nonatomic) NSMutableArray *linePathArrayArray; // Array of line path, one for each line.
@property(nonatomic) NSMutableArray *pointPathArrayArray;// Array of point path, one for each point.

@property (nonatomic) NSMutableArray *pointValueArrayArray;
@property (nonatomic) NSMutableArray *pointLabelArrayArray;
@property (nonatomic) NSMutableArray *yValueLabelArray;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;//渐变图形

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, assign) CGFloat xStep;
@property (nonatomic, assign) CGFloat yStep;

@property (nonatomic) CGFloat yValueMax;
@property (nonatomic) CGFloat yValueMin;
@property (nonatomic) NSInteger yLabelNum;

@property (nonatomic, strong) CAAnimation *strokeEndAnimation;

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

#pragma mark - Public Method
- (void)strokeChart {
    
    [self calcuateChart];
    [self setXLabel];
    if (_showYLabels) {
        [self setYLabel];
    }
    if (_showGradientArea) {
        [self setGradientLayer];
    }
    [self populateChartLines];
    
    if (_displayAnimated) {
        [self addAnimationIfNeeded];
    }
    [self createPointLabel];
 
    [self setNeedsDisplay];
}
#pragma mark - 更新图表
- (void)updateChartDatas:(NSArray *)data {
    
    [self removeAllLayers];
    [self removeAllSubviews];
    [self removeAllObjects];
    _lineChartDatas = data;
    [self calcuateChart];
    if (_showYLabels) {
        [self setYLabel];
    }
    if (_showGradientArea) {
        [self setGradientLayer];
    }
    [self populateChartLines];
    if (_displayAnimated) {
        [self addAnimationIfNeeded];
    }
    
    [self createPointLabel];
    [self setNeedsDisplay];
}

#pragma mark - 创建点Label
- (void)createPointLabel {
    
    for (int i = 0; i < _lineChartDatas.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        NSArray <NSValue *> *pointValueArray = _pointValueArrayArray[i];
        if (chartData.showPointLabel) {
            
            NSInteger item = 0;
            NSMutableArray *pointLabelArray = [NSMutableArray array];
            for (NSValue *value in pointValueArray) {
                UILabel *label = [UILabel new];
                label.font = chartData.pointLabelFont;
                label.textColor = chartData.pointLabelColor;
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:chartData.pointLabelFormat, chartData.dataGetter(item).y];
                CGPoint position = value.CGPointValue;
                CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}];
                label.frame = CGRectMake(position.x - size.width/2, position.y - size.height-chartData.inflexionPointWidth, size.width, size.height);
                [self addSubview:label];
                [pointLabelArray addObject:label];
                item++;
            }
            [self.pointLabelArrayArray addObject:pointLabelArray];
        }
    }
}
#pragma mark - 添加动画
- (void)addAnimationIfNeeded {
    
    for (int i = 0; i < _chartLineArrayArray.count; i++) {
        
        NSArray <CAShapeLayer *> *chartLineArr = _chartLineArrayArray[i];
        for (CAShapeLayer *line in chartLineArr) {
            [line addAnimation:self.strokeEndAnimation forKey:@"ss"];
        }
    }
    for (int i = 0; i < _chartPointArrayArray.count; i++) {
        NSArray <CAShapeLayer *> *chartPointArr = _chartPointArrayArray[i];
        for (CAShapeLayer *point in chartPointArr) {
            [point addAnimation:self.strokeEndAnimation forKey:@"11"];
        }
    }
}
#pragma mark - strokeEndAnimation
- (CAAnimation *)strokeEndAnimation {
    
    if (!_strokeEndAnimation) {
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 1;
        ani.delegate = self;
        _strokeEndAnimation= ani;
    }
    return _strokeEndAnimation;
}

#pragma mark - 获取Y最大值最小值
- (void)getYValueMaxAndYValueMin {
    
    if (_YLabelTitles) {
        _yValueMax = [_YLabelTitles.lastObject floatValue];
        _yValueMin = [_YLabelTitles.firstObject floatValue];
        _yLabelNum = _YLabelTitles.count;
    } else {
        
        for (int i = 0; i < _lineChartDatas.count; i++) {
            GBLineChartData *chartData = _lineChartDatas[i];
            for (int j = 0; j < chartData.itemCount; j++) {
                CGFloat yValue = chartData.dataGetter(j).y;
                _yValueMax = MAX(_yValueMax, yValue);
                _yValueMin = MIN(_yValueMin, yValue);
            }
        }
        _yLabelNum = 6;
    }
}

#pragma mark - 计算
- (void)calcuateChart {
    
    [self getYValueMaxAndYValueMin];

    _xStep = _chartCavanWidth/_XLabelTitles.count;
    _yStep = _chartCavanHeight/_yLabelNum;
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    for (int i = 0; i < _lineChartDatas.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        //点的数组
        NSMutableArray *pointValueArray = [NSMutableArray array];
        for (int item = 0; item < chartData.itemCount; item++) {
            CGFloat center_x = _chartMarginLeft + _xStep * item + _xStep/2;
            CGFloat yValue1 = chartData.dataGetter(item).y;
            if (yValue1 < _yValueMin || yValue1 > _yValueMax) {
                
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"值只能在最小值与最大值之间" userInfo:nil];
            }
            CGFloat center_y =  yAxisMax - (yValue1-_yValueMin)/(_yValueMax-_yValueMin) * (_chartCavanHeight-_yStep);
            NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(center_x, center_y)];
            [pointValueArray addObject:pointValue];
        }
        [_pointValueArrayArray addObject:pointValueArray];
        
        if (!_showSmoothLines) {
            NSMutableArray *linePathArray = [NSMutableArray array];
            for (int item = 0; item < chartData.itemCount-1; item++) {
                CGFloat x1 = _chartMarginLeft + _xStep * item + _xStep/2;
                CGFloat yValue1 = chartData.dataGetter(item).y;
                CGFloat y1 =  yAxisMax - (yValue1 - _yValueMin)/(_yValueMax-_yValueMin) * (_chartCavanHeight-_yStep);
                
                CGFloat x2 = _chartMarginLeft + _xStep * (item+1) + _xStep/2;
                CGFloat y2 = _chartCavanHeight + _chartMarginTop - (chartData.dataGetter(item+1).y-_yValueMin)/(_yValueMax - _yValueMin) * (_chartCavanHeight-_yStep);
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(x1, y1)];
                [path addLineToPoint:CGPointMake(x2, y2)];
                [linePathArray addObject:path];
            }
            [_linePathArrayArray addObject:linePathArray];
        }
       
        //点
        NSMutableArray *pointPathArray = [NSMutableArray array];
        for (int item = 0; item < chartData.itemCount; item++) {
            CGFloat center_x = _chartMarginLeft + _xStep * item + _xStep/2;
            CGFloat center_y =  yAxisMax - (chartData.dataGetter(item).y-_yValueMin)/(_yValueMax-_yValueMin) * (_chartCavanHeight-_yStep);
            UIBezierPath *path = [UIBezierPath bezierPath];
            if (chartData.lineChartPointStyle == GBLineChartPointStyleCircle) {//圆
                path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(center_x, center_y) radius:chartData.inflexionPointWidth/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
          
            } else if (chartData.lineChartPointStyle == GBLineChartPointStyleSquare) {//方形
                path = [UIBezierPath bezierPathWithRect:CGRectMake(center_x-chartData.inflexionPointWidth/2, center_y - chartData.inflexionPointWidth/2, chartData.inflexionPointWidth, chartData.inflexionPointWidth)];
            } else if (chartData.lineChartPointStyle == GBLineChartPointStyleTriangle) { //三角形
                path = [UIBezierPath bezierPath];
                CGFloat x1 = center_x;
                CGFloat y1 = center_y - chartData.inflexionPointWidth;
                CGFloat x2 = center_x - chartData.inflexionPointWidth * sinf(M_PI/3);
                CGFloat y2 = center_y + chartData.inflexionPointWidth * cosf(M_PI/3);
                CGFloat x3 = center_x + chartData.inflexionPointWidth * sinf(M_PI/3);
                CGFloat y3 = y2;
                [path moveToPoint:CGPointMake(x1, y1)];
                [path addLineToPoint:CGPointMake(x2, y2)];
                [path addLineToPoint:CGPointMake(x3, y3)];
                [path closePath];
            }
            [pointPathArray addObject:path];
        }
        [_pointPathArrayArray addObject:pointPathArray];
    }
    
    if (_showSmoothLines) {
        for (int i = 0; i < _pointValueArrayArray.count; i++) {
            NSMutableArray *pointValueArray = _pointValueArrayArray[i];
            CGPoint startPoint = [pointValueArray[0] CGPointValue];
            startPoint = CGPointMake(startPoint.x-_xStep, startPoint.y);
            CGPoint endPoint = [pointValueArray.lastObject CGPointValue];
            endPoint = CGPointMake(endPoint.x+_xStep, endPoint.y);
            [pointValueArray insertObject:[NSValue valueWithCGPoint:startPoint] atIndex:0];
            [pointValueArray addObject:[NSValue valueWithCGPoint:endPoint]];
            
            NSMutableArray *chartLinePathArray = [NSMutableArray array];
            for (int j = 0; j < pointValueArray.count-3; j++) {
                
                CGPoint p0 = [pointValueArray[j] CGPointValue];
                CGPoint p1 = [pointValueArray[j+1] CGPointValue];
                CGPoint p2 = [pointValueArray[j+2] CGPointValue];
                CGPoint p3 = [pointValueArray[j+3] CGPointValue];
                
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:p1];
                [self getControlPointx0:p0.x andy0:p0.y x1:p1.x andy1:p1.y x2:p2.x andy2:p2.y x3:p3.x andy3:p3.y path:path];
                [chartLinePathArray addObject:path];
            }
            
            [pointValueArray removeObjectAtIndex:0];
            [pointValueArray removeLastObject];
            [_linePathArrayArray addObject:chartLinePathArray];

        }
    }
}
#pragma mark - 布局折线
- (void)populateChartLines {
    
    for (int i = 0; i < _linePathArrayArray.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        NSMutableArray <UIBezierPath *> *linePathArray = _linePathArrayArray[i];
        NSMutableArray *chartLineArray = [NSMutableArray array];
        for (UIBezierPath *path in linePathArray) {
            CAShapeLayer *line = [CAShapeLayer layer];
            line.lineCap = kCALineCapButt;
            line.lineJoin = kCALineJoinMiter;
            line.lineWidth = chartData.lineWidth;
            line.strokeColor = [chartData.lineColor colorWithAlphaComponent:chartData.lineAlpha].CGColor;
            line.path = path.CGPath;
            line.fillColor = [UIColor clearColor].CGColor;
            [self.layer addSublayer:line];
            [chartLineArray addObject:line];
        }
        [_chartLineArrayArray addObject:chartLineArray];
    }
    
    for (int i = 0; i < _pointPathArrayArray.count; i++) {
        GBLineChartData *chartData = _lineChartDatas[i];
        NSMutableArray <UIBezierPath *> *pointPathArray = _pointPathArrayArray[i];
        NSMutableArray *pointLayerArr = [NSMutableArray array];
        for (UIBezierPath *path in pointPathArray) {
            CAShapeLayer *pointLayer = [CAShapeLayer layer];
            pointLayer.strokeColor = chartData.inflexionPointStrokeColor.CGColor;
            pointLayer.fillColor = chartData.inflexionPointFillColor.CGColor;
            pointLayer.path = path.CGPath;
            [self.layer addSublayer:pointLayer];
            [pointLayerArr addObject:pointLayer];
        }
        [_chartPointArrayArray addObject:pointLayerArr];
    }
}

#pragma mark - 移除
- (void)removeAllLayers {
    
    for (NSArray <CALayer *> *layers in self.chartPointArrayArray) {
        for (CALayer *layer in layers) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
    
    for (NSArray <CALayer *> *layers in self.chartLineArrayArray) {
        for (CALayer *layer in layers) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
    [_gradientLayer removeAllAnimations];
    [_gradientLayer removeFromSuperlayer];
}

- (void)removeAllSubviews {
    
    for (NSArray <UILabel *> *views in _pointLabelArrayArray) {
        for (UILabel *label in views) {
            [label removeFromSuperview];
        }
    }
    for (UILabel *label in _yValueLabelArray) {
        [label removeFromSuperview];
    }
}

- (void)removeAllObjects {
    
    [self.pointValueArrayArray removeAllObjects];
    [self.chartPointArrayArray removeAllObjects];
    [self.pointLabelArrayArray removeAllObjects];
    [self.chartLineArrayArray removeAllObjects];
    [self.linePathArrayArray removeAllObjects];
    [self.pointPathArrayArray removeAllObjects];
    [self.yValueLabelArray removeAllObjects];
}

#pragma mark - 创建坐标轴的label
- (void)setYLabel {
    //从下往上布局
    CGFloat divideSeperetor = (_yValueMax - _yValueMin)/(_yLabelNum-1);
    for (int i = 0; i < _yLabelNum; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForYLabelAtIndex:i]];
        label.font = _yLabelFont;
        label.textColor = _yLabelColor;
        NSString *value = [NSString stringWithFormat:_yLabelFormat, _yValueMin + divideSeperetor*i];
        if (_yLabelBlockFormatter) {
            value = _yLabelBlockFormatter(_yValueMin + divideSeperetor*i);
        }
        label.text = value;
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        [self.yValueLabelArray addObject:label];
    }
}

- (void)setXLabel{
    
    //从左到右
    for (int i = 0; i < _XLabelTitles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForXLabelAtIndex:i]];
        label.font = _xLabelFont;
        label.textColor = _xLabelColor;
        label.text = _XLabelTitles[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.transform = CGAffineTransformMakeRotation(_XLabelRotationAngle);
        [self addSubview:label];
    }
}

#pragma mark - 创建渐变图层
- (void)setGradientLayer {
    
    for (int i = 0; i < _pointValueArrayArray.count; i++) {
        
        NSMutableArray *pointValueArray = _pointValueArrayArray[i];
        CGPoint startPoint = [pointValueArray[0] CGPointValue];
        startPoint = CGPointMake(startPoint.x-_xStep, startPoint.y);
        CGPoint endPoint = [pointValueArray.lastObject CGPointValue];
        endPoint = CGPointMake(endPoint.x+_xStep, endPoint.y);
        [pointValueArray insertObject:[NSValue valueWithCGPoint:startPoint] atIndex:0];
        [pointValueArray addObject:[NSValue valueWithCGPoint:endPoint]];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (_showSmoothLines) {
            
            for (int j = 0; j < pointValueArray.count - 3;j++) {
                CGPoint p0 = [pointValueArray[j] CGPointValue];
                CGPoint p1 = [pointValueArray[j+1] CGPointValue];
                CGPoint p2 = [pointValueArray[j+2] CGPointValue];
                CGPoint p3 = [pointValueArray[j+3] CGPointValue];
                if (j == 0) {
                    [path moveToPoint:p1];
                }
                [self getControlPointx0:p0.x andy0:p0.y x1:p1.x andy1:p1.y x2:p2.x andy2:p2.y x3:p3.x andy3:p3.y path:path];
            }
            
        } else {
            for (int j = 0 ; j < pointValueArray.count; j++) {
                if (j == 0) {
                    [path moveToPoint:[pointValueArray[j] CGPointValue]];
                }
                [path addLineToPoint:[pointValueArray[j] CGPointValue]];
            }
        }
     
        [pointValueArray removeObjectAtIndex:0];
        [pointValueArray removeLastObject];
        
        CGPoint point1 = [pointValueArray.firstObject CGPointValue];
        CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
        point1 = CGPointMake(point1.x, yAxisMax);
        
        CGPoint point2 = [pointValueArray.lastObject CGPointValue];
        point2 = CGPointMake(point2.x, yAxisMax);
        [path addLineToPoint:point2];
        [path addLineToPoint:point1];
        [path closePath];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
        gradientLayer.colors = @[(__bridge id)_startGradientColor.CGColor, (__bridge id)_endGradientColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
        gradientLayer.mask = maskLayer;
        gradientLayer.zPosition = -10;
        _gradientLayer = gradientLayer;
        
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 1.5;
        [gradientLayer addAnimation:ani forKey:nil];
    }
}

#pragma mark - YLabel Frame XLabel Frame
- (CGRect)frameForYLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat w = _chartMarginLeft-4;
    _yLabelHeight = _chartCavanHeight / _yLabelNum;
    CGFloat x = 0;
    CGFloat y = yAxisMax - index* _yLabelHeight - _yLabelHeight/2;
    return CGRectMake(x, y, w, _yLabelHeight);
}
- (CGRect)frameForXLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    _xLabelWidth = _chartCavanWidth/_XLabelTitles.count;
    CGFloat h = _chartMarginBottom;
    CGFloat  x = _chartMarginLeft + index * _xLabelWidth;
    CGFloat y = yAxisMax;
    return CGRectMake(x, y, _xLabelWidth, h);
}

- (CGFloat)getMaxXLabelWidth {
    
    CGFloat width = _chartCavanWidth/_XLabelTitles.count;
    for (NSString *text in _XLabelTitles) {
        CGFloat tempW = [text sizeWithAttributes:@{NSFontAttributeName : _xLabelFont}].width;
        width = MAX(width, tempW);
    }
    return ceil(width);
}

- (void)getControlPointx0:(CGFloat)x0 andy0:(CGFloat)y0
                       x1:(CGFloat)x1 andy1:(CGFloat)y1
                       x2:(CGFloat)x2 andy2:(CGFloat)y2
                       x3:(CGFloat)x3 andy3:(CGFloat)y3
                     path:(UIBezierPath*) path{
    CGFloat smooth_value = 0.6;
    CGFloat ctrl1_x;
    CGFloat ctrl1_y;
    CGFloat ctrl2_x;
    CGFloat ctrl2_y;
    CGFloat xc1 = (x0 + x1) /2.0;
    CGFloat yc1 = (y0 + y1) /2.0;
    CGFloat xc2 = (x1 + x2) /2.0;
    CGFloat yc2 = (y1 + y2) /2.0;
    CGFloat xc3 = (x2 + x3) /2.0;
    CGFloat yc3 = (y2 + y3) /2.0;
    CGFloat len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
    CGFloat len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
    CGFloat len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
    CGFloat k1 = len1 / (len1 + len2);
    CGFloat k2 = len2 / (len2 + len3);
    CGFloat xm1 = xc1 + (xc2 - xc1) * k1;
    CGFloat ym1 = yc1 + (yc2 - yc1) * k1;
    CGFloat xm2 = xc2 + (xc3 - xc2) * k2;
    CGFloat ym2 = yc2 + (yc3 - yc2) * k2;
    ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
    ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
    ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
    ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
    [path addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake(ctrl1_x, ctrl1_y) controlPoint2:CGPointMake(ctrl2_x, ctrl2_y)];
}

#pragma mark - 设置默认属性
- (void)configDefaultValues {
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.chartLineArrayArray = [NSMutableArray new];
    self.chartPointArrayArray = [NSMutableArray new];
    self.pointPathArrayArray = [NSMutableArray new];
    self.linePathArrayArray = [NSMutableArray new];
    self.pointLabelArrayArray = [NSMutableArray new];
    self.pointValueArrayArray = [NSMutableArray new];
    self.yValueLabelArray = [NSMutableArray new];

    _displayAnimated = YES;
    _showCoordinateAxis = YES;
    _showYLabels = YES;
    _coordinateAxisLineWidth = 1;
    _coordinateAxisColor = [UIColor blackColor];
    
    _showYGridsLine = YES;
    _yGridsLineColor = [UIColor grayColor];
    _yGridsLineWidth = 1;
    
    _chartMarginLeft = 25.0;
    _chartMarginRight = 25.0;
    _chartMarginTop = 25.0;
    _chartMarginBottom = 25.0;
    
    _xLabelColor = [UIColor blackColor];
    _xLabelFont = [UIFont systemFontOfSize:10];
    _yLabelFont = [UIFont systemFontOfSize:10];
    _yLabelColor = [UIColor blackColor];
    
    _yLabelFormat = @"%1.0f";
    
    _chartCavanWidth = self.frame.size.width - _chartMarginLeft - _chartMarginRight;
    _chartCavanHeight = self.frame.size.height - _chartMarginBottom - _chartMarginTop;
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat xAxisMax = _chartCavanWidth + _chartMarginLeft;
    
    if (_showCoordinateAxis) {
        
        //画坐标轴
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(ctx, _coordinateAxisColor.CGColor);
        CGContextSetLineWidth(ctx, _coordinateAxisLineWidth);
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft-3, _chartMarginTop+5);
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft+3, _chartMarginTop+5);
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax-5, yAxisMax-3);
        CGContextMoveToPoint(ctx, xAxisMax, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax-5, yAxisMax+3);
        
        //绘制分割点
        for (int i = 0; i < _XLabelTitles.count; i++) {
            CGFloat yStep = _chartCavanWidth/_XLabelTitles.count;
            CGFloat x = _chartMarginLeft + i * yStep + yStep/2;
            CGFloat y = _chartCavanHeight + _chartMarginTop;
            CGContextMoveToPoint(ctx, x, y-3);
            CGContextAddLineToPoint(ctx, x, y);
        }
        
        for (int i = 0; i < _yLabelNum; i++) {
            
            CGFloat yStep = _chartCavanHeight/_yLabelNum;
            CGFloat x = _chartMarginLeft;
            CGFloat y = _chartMarginTop + yStep * i + yStep;
            CGContextMoveToPoint(ctx, x+3, y);
            CGContextAddLineToPoint(ctx, x-2, y);
        }
        CGContextStrokePath(ctx);
        }
    
    if (_showYGridsLine) {
        //绘制横线
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGFloat eachSectionHeight = (_chartCavanHeight - _yLabelHeight) / (_yLabelNum-1);
        CGContextSetStrokeColorWithColor(ctx, _yGridsLineColor.CGColor);
        CGContextSetLineWidth(ctx, _yGridsLineWidth);
        CGFloat dash[] = {3,3};
        CGContextSetLineDash(ctx, 0.0, dash, 2);
        for (int i = 0; i < 5; i++) {
            
            CGContextMoveToPoint(ctx, _chartMarginLeft, yAxisMax - eachSectionHeight * (i+1));
            CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax - eachSectionHeight * (i+1));
            CGContextStrokePath(ctx);
        }
    }
}
@end
