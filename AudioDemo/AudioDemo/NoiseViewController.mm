//
//  NoiseViewController.m
//  AudioDemo
//
//  Created by zz on 2022/10/13.
//

#import "NoiseViewController.h"

#import "doublesky_pcmplay.h"
#include "IIRFilter.hpp"

@interface NoiseViewController () {
    doublesky_pcmplay* play;
    bool use; // 是否开启滤波
}
@end

@implementation NoiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UISwitch* s = [[UISwitch alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [s addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:s];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(s.frame), CGRectGetMinY(s.frame), 150, 50)];
    lab.textColor = [UIColor blackColor];
    lab.text = @"是否去噪";
    [self.view addSubview:lab];
    
    play = [[doublesky_pcmplay alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"noise.wav" ofType:nil];
    assert(path);

    FILE* fp = fopen([path UTF8String], "r");
    assert(fseek(fp, 44, SEEK_SET) == 0);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        short buffer[1024];

        double b[10] = {0.0444, 0.2032, 0.5253, 0.9303, 1.2212, 1.2212, 0.9303, 0.5253, 0.2032, 0.0444};
        double a[10] = {1.0000, 0.4937, 1.6890, 0.8726, 1.0066, 0.4520, 0.2419, 0.0736, 0.0174, 0.0020};
        IIRFilter filter(10, b, a);

        double flt_input[1024];
        double flt_output[1024];
        float pcm[1024];
        while (fread(buffer, 1, 2048, fp) > 0)
        {
            memset(flt_input, 0, sizeof(flt_input));
            for (int i = 0; i < 1024; ++i)
            {
                // s16转float
                float tmp = 1.0*buffer[i]/32768;
                flt_input[i] = tmp;
            }

            // 滤波
            filter.process(flt_input, flt_output, 1024);
            for (int i = 0; i < 1024; ++i)
                pcm[i] = flt_output[i];
                
            [play push:use ? (char*)pcm : (char*)flt_input size:use ? sizeof(pcm) : sizeof(flt_input)];
            memset(buffer, 0, sizeof(buffer));
        }
    });
}

- (void)tap:(UISwitch*)s
{
    use = s.on;
}
@end
