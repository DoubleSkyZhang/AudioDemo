//
//  doublesky_pcmplay.m
//  pcmplay
//
//  Created by zz on 2020/5/16.
//  Copyright © 2020 zz. All rights reserved.
//

#import "doublesky_pcmplay.h"
#import <AudioToolbox/AudioQueue.h>

#include <queue>
#include <mutex>

#define doublesky_pcmsize 4096
#define bufferCount 3
#define QUEUE_MAX 10

using namespace std;
typedef pair<shared_ptr<char>, int> Pair;
@interface doublesky_pcmplay()
{
    AudioStreamBasicDescription des;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef buffer[bufferCount];
    
    queue<Pair> q;
    mutex m;
    condition_variable cond;
}
@end

@implementation doublesky_pcmplay
- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    des.mSampleRate = 44100;
    des.mFormatID = kAudioFormatLinearPCM;
    des.mFormatFlags = kAudioFormatFlagIsFloat;
    des.mFramesPerPacket = 1;
    des.mChannelsPerFrame = 1;
    des.mBitsPerChannel = 32;
    des.mBytesPerPacket = 4;
    des.mBytesPerFrame = 4;
    OSStatus ret = -1;
    
    ret = AudioQueueNewOutput(&des, &playcallback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &audioQueue);
    if (ret != noErr)
        return nil;
    
    int alloc_count = 0;
    for (int i = 0; i < bufferCount; ++i)
    {
        ret = AudioQueueAllocateBuffer(audioQueue, doublesky_pcmsize, &buffer[i]);
        if (ret != noErr)
            break;
        
        buffer[i]->mAudioDataByteSize = doublesky_pcmsize;
        memset(buffer[i]->mAudioData, 0, doublesky_pcmsize);
        AudioQueueEnqueueBuffer(audioQueue, buffer[i], 0, NULL);
        alloc_count = i+1;
    }

    if (ret != noErr)
    {
        for (int i = 0; i < alloc_count; ++i)
            AudioQueueFreeBuffer(audioQueue, buffer[i]);
        
        return nil;
    }
    
    ret = AudioQueueStart(audioQueue, NULL);
    
    return self;
}

static void playcallback(void * __nullable inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    doublesky_pcmplay *player = (__bridge doublesky_pcmplay*)(inUserData);

    player->m.lock();
    if (player->q.empty())
    {
        inBuffer->mAudioDataByteSize = doublesky_pcmsize;
        memset(inBuffer->mAudioData, 0, inBuffer->mAudioDataByteSize);
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        player->cond.notify_one();
    }
    else
    {
        auto& tmp = player->q.front();
        inBuffer->mAudioDataByteSize = tmp.second;
        memcpy(inBuffer->mAudioData, tmp.first.get(), tmp.second);
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        player->q.pop();
        if (player->q.size() < QUEUE_MAX)
            player->cond.notify_one();
    }
    player->m.unlock();
}

- (void)push:(char*)buffer size:(int)size
{
    unique_lock<mutex> lock(m);
    if (q.size() > QUEUE_MAX)
        cond.wait(lock);
    
    char* p = (char*)calloc(1, size);
    memcpy(p, buffer, size);
    shared_ptr<char> ptr(p);
    q.emplace(ptr, size);
}

- (void)stop
{
    NSLog(@"zz pcm clear start");
    
    int err = -1;
    err = AudioQueueStop(audioQueue, YES);
    assert(!err);
    
    err = AudioQueueReset(audioQueue);
    assert(!err);
    
    for (int i = 0; i < bufferCount; ++i)
        AudioQueueFreeBuffer(audioQueue, buffer[i]);
    
    err = AudioQueueDispose(audioQueue, YES);
    assert(!err);
    audioQueue = NULL;
    NSLog(@"zz pcm clear end");
}

- (void)dealloc
{
    NSLog(@"zz pcm play dealloc");
//    [self clear];
}
@end
