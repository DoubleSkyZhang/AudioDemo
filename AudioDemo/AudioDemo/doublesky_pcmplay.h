//
//  doublesky_pcmplay.h
//  pcmplay
//
//  Created by zz on 2020/5/16.
//  Copyright © 2020 zz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface doublesky_pcmplay : NSObject
- (instancetype)init;

- (void)push:(char*)buffer size:(int)size;

// 停止pcm播放
- (void)stop;
@end

NS_ASSUME_NONNULL_END
