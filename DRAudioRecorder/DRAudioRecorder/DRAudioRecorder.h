//
//  DRAudioRecorder.h
//  DRAudioRecorder
//
//  Created by niyao on 6/25/18.
//  Copyright © 2018 dourui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlyMSC/IFlyMSC.h"

@protocol DRAudioRecorderDelegate <NSObject>

@optional
- (void)recorderDidProcessAudioData:(NSData *)audioData;
- (void)recorderDidProcessError:(NSError *)error;

@end


typedef NS_ENUM(NSInteger, DRAudioRecorderStatus) {
    DRAudioRecorderStatusInitailized,
    DRAudioRecorderStatusStart,
    DRAudioRecorderStatusRecording,
    DRAudioRecorderStatusStopped,
};

@class IFlyPcmRecorder;

@interface DRAudioRecorder : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, weak) id<DRAudioRecorderDelegate> delegate;

- (void)setupRecorder;
- (BOOL)start;
- (BOOL)stop;

- (void)play;
- (void)stopPlay;

@end
