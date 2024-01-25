//
//  ViewController3.m
//  ZHWaveform_Example
//
//  Created by Alvaro Marcos on 23/1/24.
//  Copyright © 2024 wow250250. All rights reserved.
//

#import <ZHWaveform_Example-Swift.h>
#import "ViewController3.h"

@interface ViewController3 ()

@property (strong, nonatomic) ZHWaveformView *waveform;
@property (strong, nonatomic) UISlider *slider;

@end

@implementation ViewController3

- (void)loadView {
    [super loadView];
    
    [self setupWaveformView];
}

- (void)setupWaveformView {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSURL *fileURL = [thisBundle URLForResource:@"Apart" withExtension:@"mp3"];
    
    self.waveform = [[ZHWaveformView alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 44) fileURL:fileURL];
    
    self.waveform.beginningPartColor = [UIColor systemBlueColor];
    self.waveform.wavesColor = [UIColor lightGrayColor];
    self.waveform.trackScale = 0.4;
    
    [self.view addSubview:self.waveform];
    
    const CGFloat sliderHeight = self.waveform.frame.size.height;
    const CGFloat sliderWidthDelta = 10;
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(self.waveform.frame.origin.x - sliderWidthDelta/2, self.waveform.frame.origin.y + self.waveform.frame.size.height/2 - sliderHeight/2, self.waveform.frame.size.width + sliderWidthDelta, sliderHeight)];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    
    UIImage *thumbImage = [self circleImageWithColor:[UIColor systemBlueColor] size:CGSizeMake(10, 10)];
    [self.slider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [self.view addSubview:self.slider];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSLog(@"%f", sender.value);
    [_waveform setStartCroppedIndexWithIndex:sender.value];
}

- (UIImage *)circleImageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
