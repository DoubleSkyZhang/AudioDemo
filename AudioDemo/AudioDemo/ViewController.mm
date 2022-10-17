//
//  ViewController.m
//  AudioDemo
//
//  Created by zz on 2022/10/13.
//

#import "ViewController.h"
#import "NoiseViewController.h"
#import "EQViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [btn addTarget:self action:@selector(click1:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"去噪" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    [btn2 addTarget:self action:@selector(click2:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"均衡器" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
}

- (void)click1:(UIButton*)btn
{
    NoiseViewController* vc = [NoiseViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)click2:(UIButton*)btn
{
    EQViewController* vc = [[EQViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}
@end
