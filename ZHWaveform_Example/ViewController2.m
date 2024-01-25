//
//  ViewController2.m
//  ZHWaveform_Example
//
//  Created by Alvaro Marcos on 23/1/24.
//  Copyright © 2024 wow250250. All rights reserved.
//

#import <ZHWaveform_Example-Swift.h>
#import "ViewController2.h"

const BOOL showLeftControl = YES;
const BOOL showRightControl = YES;

@interface ViewController2 () <ZHCroppedDelegate, ZHWaveformViewDelegate>

@property (strong, nonatomic) ZHWaveformView *waveform;

@end

@implementation ViewController2

- (void)loadView {
    [super loadView];
    
    [self setupWaveformView];
}

- (void)setupWaveformView {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSURL *fileURL = [thisBundle URLForResource:@"Apart" withExtension:@"mp3"];
    
    self.waveform = [[ZHWaveformView alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 44) fileURL:fileURL];
    
    self.waveform.beginningPartColor = [UIColor blackColor];
    self.waveform.endPartColor = [UIColor blackColor];
    self.waveform.wavesColor = [UIColor lightGrayColor];
    self.waveform.trackScale = 0.4;
    
    self.waveform.waveformDelegate = self;
    self.waveform.croppedDelegate = self;
    
    [self.view addSubview:self.waveform];
}

#pragma mark - ZHWaveformViewDelegate Methods

- (UIView *)waveformViewWithStartCropped:(ZHWaveformView *)waveformView {
    if (showLeftControl) {
        UIView *start = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        start.backgroundColor = [UIColor blackColor];
        start.layer.cornerRadius = 5;
        return start;
    }
    return nil;
}

- (UIView *)waveformViewWithEndCropped:(ZHWaveformView *)waveformView {
    if (showRightControl) {
        UIView *start = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        start.backgroundColor = [UIColor blackColor];
        start.layer.cornerRadius = 5;
        return start;
    }
    return nil;
}

- (void)waveformViewWithStartCropped:(UIView *)startCropped progress:(CGFloat)rate {
    NSLog(@"Left rate: %f", rate);
}

- (void)waveformViewWithEndCropped:(UIView *)endCropped progress:(CGFloat)rate {
    NSLog(@"Right rate: %f", rate);
}

@end
