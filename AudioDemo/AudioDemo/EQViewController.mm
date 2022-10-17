//
//  EQViewController.m
//  AudioDemo
//
//  Created by zz on 2022/10/13.
//

#import "EQViewController.h"

#import "doublesky_pcmplay.h"
#include "IIRFilter.hpp"
#include "ZUIIRFilter.h"

@interface EQViewController ()
{
    doublesky_pcmplay* play;
    
    float lp_gain, bp_gain, hp_gain;
}

@end

@implementation EQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    play = [[doublesky_pcmplay alloc] init];
    lp_gain = 1.0;
    bp_gain = 1.0;
    hp_gain = 1.0;
    
    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 100, 50)];
    label1.text = @"低频";
    label1.textColor = UIColor.blackColor;
    [self.view addSubview:label1];
    
    UISlider* slider1 = [[UISlider alloc] initWithFrame:CGRectMake(150, 200, 200, 50)];
    [slider1 addTarget:self action:@selector(slider1:) forControlEvents:UIControlEventValueChanged];
    slider1.maximumValue = 10;
    slider1.minimumValue = -10;
    slider1.value = 1.0;
    [self.view addSubview:slider1];
    
    UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 100, 50)];
    label2.text = @"中频";
    label2.textColor = UIColor.blackColor;
    [self.view addSubview:label2];
    
    UISlider* slider2 = [[UISlider alloc] initWithFrame:CGRectMake(150, 300, 200, 50)];
    [slider2 addTarget:self action:@selector(slider2:) forControlEvents:UIControlEventValueChanged];
    slider2.maximumValue = 10;
    slider2.minimumValue = -10;
    slider2.value = 1.0;
    [self.view addSubview:slider2];
    
    
    UILabel* label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 100, 50)];
    label3.text = @"高频";
    label3.textColor = UIColor.blackColor;
    [self.view addSubview:label3];
    
    UISlider* slider3 = [[UISlider alloc] initWithFrame:CGRectMake(150, 400, 200, 50)];
    [slider3 addTarget:self action:@selector(slider3:) forControlEvents:UIControlEventValueChanged];
    slider3.maximumValue = 10;
    slider3.minimumValue = -10;
    slider3.value = 1.0;
    [self.view addSubview:slider3];
}

// 正常形式的低通滤波器系数
static const int LP_LEN = 6;
static double LP_B[LP_LEN] = {0.00112266916511878,    -0.00335804481007404,    0.00223539333478608,    0.00223539333478608,    -0.00335804481007404,    0.00112266916511878};
static double LP_A[LP_LEN] = {1, -4.89871336422332,    9.59996411771510,    -9.40745163011783,    4.60986753597724,    -0.903666623971535};


static const int BP_LEN = 11;
static double BP_B[BP_LEN] = {0.0147870348410641,    -0.0896713907921595,    0.239728170511116,    -0.357933513532618,    0.281432905082980,    -1.31335252371870e-17,    -0.281432905082980,    0.357933513532618,    -0.239728170511116,    0.0896713907921597,    -0.0147870348410641};
static double BP_A[BP_LEN] = {1, -8.24143236474598,    30.6837048158386,    -67.9994348029134,    99.3786343355872,    -100.107651076046,    70.4028934601109,    -34.1345683881885,    10.9193043553503,    -2.08073159058107,    0.179281256060903};

// 正常形式的高通滤波器系数
static const int HP_LEN = 6;
static double HP_B[HP_LEN] = {0.512554073443323,    -2.49431022188030,    4.92200130950305,    -4.92200130950306,    2.49431022188030,    -0.512554073443323};
static double HP_A[HP_LEN] = {1, -3.56799305163320,    5.31535809874652,    -4.09208228010496,    1.61958624530545,    -0.262711533863224};

- (void)viewDidAppear:(BOOL)animated
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"yueyawan.wav" ofType:nil];
    assert(path);

    FILE* fp = fopen([path UTF8String], "r");
    assert(fseek(fp, 2000*1024, SEEK_SET) == 0);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        short buffer[1024];
        
        double lp_b[] = {0.001022665306224, -0.003060528423526,    0.002037874026803, 0.002037874026803, -0.003060528423526, 0.001022665306224};
        double lp_a[] = {1, -4.908131525267887,    9.636731750510943, -9.461286192249139,    4.644905385226541, -0.912219396401456};
//        IIRFilter lp(6, lp_b, lp_a);
        IIRFilter lp(LP_LEN, LP_B, LP_A);
        
        double bp_b[] = {0.015864987156285,   -0.077990121585581, 0.179121841977260, -0.268402915620828, 0.302812416923588, -0.268402915620828, 0.179121841977261, -0.077990121585581, 0.015864987156285};
        double bp_a[] = {1.0, -6.759797888777129, 20.087949695454927, -34.298472274625951, 36.818907408909986, -25.453005153048046, 11.066985742227541, -2.767332124830601, 0.304764672475314};
//        IIRFilter bp(9, bp_b, bp_a);
        IIRFilter bp(BP_LEN, BP_B, BP_A);
        
        double hp_b[] = {0.419119326456145,   -2.000246972329265,    3.909532031269019,  -3.909532031269018,   2.000246972329262,   -0.419119326456144};
        double hp_a[] = {1.0000,   -3.116568700686397,   4.218699353207745,  -3.017625707855211,    1.129243305294398,   -0.175659593065123};
//        IIRFilter hp(6, hp_b, hp_a);
        IIRFilter hp(HP_LEN, HP_B, HP_A);
        
        double flt_input[1024];
        double lp_output[1024];
        double bp_output[1024];
        double hp_output[1024];
        double result[1024];
        float pcm[1024];
        
//        ZUIIRFilter zu(bp_b, bp_a, 9, 1024*sizeof(double));
        while (fread(buffer, 1, 2048, fp) > 0)
        {
            memset(flt_input, 0, sizeof(flt_input));
            for (int i = 0; i < 1024; ++i)
            {
                // s16转float
                double tmp = 1.0*buffer[i]/32768;
                flt_input[i] = tmp;
            }
            
            // 滤波
            lp.process(flt_input, lp_output, 1024);
            bp.process(flt_input, bp_output, 1024);
            hp.process(flt_input, hp_output, 1024);
            
//            zu.process(flt_input, bp_output, 1024);
            for (int i = 0; i < 1024; ++i)
            {
                result[i] = lp_output[i]*lp_gain + bp_output[i]*bp_gain + hp_output[i]*hp_gain;
                if (result[i] > 1.0)
                    result[i] = 1.0;
                else if (result[i] < -1.0)
                    result[i] = -1.0;
                
                pcm[i] = result[i];
            }
            
            [play push:(char*)pcm size:sizeof(pcm)];
            memset(buffer, 0, sizeof(buffer));
        }
    });
}

- (void)slider1:(UISlider*)s
{
    NSLog(@"low %f", s.value);
    lp_gain = pow(10, s.value/20);
}

- (void)slider2:(UISlider*)s
{
    NSLog(@"middle %f", s.value);
    bp_gain = pow(10, s.value/20);
}

- (void)slider3:(UISlider*)s
{
    NSLog(@"high %f", s.value);
    hp_gain = pow(10, s.value/20);
}
@end
