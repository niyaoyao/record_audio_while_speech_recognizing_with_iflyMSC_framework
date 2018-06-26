//
//  DRAudioRecorder.m
//  DRAudioRecorder
//
//  Created by niyao on 6/25/18.
//  Copyright © 2018 dourui. All rights reserved.
//

#import "DRAudioRecorder.h"

@interface DRAudioRecorder () <IFlyPcmRecorderDelegate>

@property (nonatomic, strong) IFlyPcmRecorder *pcmRecorder;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSMutableData *pcmData;
@property (nonatomic, strong) NSMutableData *audioData;

@end


@implementation DRAudioRecorder

- (id)initWithFilePath:(NSString *)path sampleRate:(long)sample {
    if (self = [super init]) {
        NSData *audioData = [NSData dataWithContentsOfFile:path];
        [self writeWaveHead:audioData sampleRate:sample];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        self = [self initWithFilePath:[[self class] saveURLWithFileName:@"test" extension:@"pcm"].path sampleRate:16000];
    }
    return self;
}

- (void)setupRecorder {
    //Initialize recorder
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }

    
    [_pcmRecorder setSample:@"16000"];
    [_pcmRecorder setSaveAudioPath: [[self class] saveURLWithFileName:@"test" extension:@"pcm"].path];
}


+ (NSURL *)saveURLWithFileName:(NSString *)fileName extension:(NSString *)extension {
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsURL = [paths lastObject];
    NSString *component = [NSString stringWithFormat:@"%@.%@", fileName, extension];
    return [documentsURL URLByAppendingPathComponent:component]; //[[documentsURL URLByAppendingPathComponent:@"video"] URLByAppendingPathComponent:component];
}

- (BOOL)start {
    // set the category of AVAudioSession
    [IFlyAudioSession initRecordingAudioSession];
    BOOL success = [_pcmRecorder start];
    _pcmRecorder.delegate = self;
    return success;
}

- (BOOL)stop {
    [_pcmRecorder stop];
    BOOL success = [self saveWaveFileWithAudioData:self.audioData];
    if (success) {
        self.audioData = nil;
    }
    return success;
}

- (BOOL)saveWaveFileWithAudioData:(NSData *)audioData {
    long sampleRate = 16000;
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    NSMutableData *wavData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [wavData appendData:audioData];
    
#if DEBUG
    NSLog(@"Wave Date Length: %lu", (unsigned long)[wavData length]);
#endif
    BOOL success = [wavData writeToFile:[DRAudioRecorder saveURLWithFileName:self.fileName extension:@"wav"].path
              atomically:YES];
    return success;
}

- (void)onIFlyRecorderBuffer:(const void *)buffer bufferSize:(int)size {
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    [self.audioData appendData:audioBuffer];
    NSLog(@"Audio Buffer: %@", audioBuffer);
    if ([self.delegate respondsToSelector:@selector(recorderDidProcessAudioData:)]) {
        [self.delegate recorderDidProcessAudioData:audioBuffer];
    }
}

- (void)onIFlyRecorderError:(IFlyPcmRecorder *)recoder theError:(int)error {

}

/**
 *
 *  write WAV head for audio data
 *
 */
- (void)writeWaveHead:(NSData *)audioData sampleRate:(long)sampleRate{
    Byte waveHead[44];
    waveHead[0] = 'R';
    waveHead[1] = 'I';
    waveHead[2] = 'F';
    waveHead[3] = 'F';
    
    long totalDatalength = [audioData length] + 44;
    waveHead[4] = (Byte)(totalDatalength & 0xff);
    waveHead[5] = (Byte)((totalDatalength >> 8) & 0xff);
    waveHead[6] = (Byte)((totalDatalength >> 16) & 0xff);
    waveHead[7] = (Byte)((totalDatalength >> 24) & 0xff);
    
    waveHead[8] = 'W';
    waveHead[9] = 'A';
    waveHead[10] = 'V';
    waveHead[11] = 'E';
    
    waveHead[12] = 'f';
    waveHead[13] = 'm';
    waveHead[14] = 't';
    waveHead[15] = ' ';
    
    waveHead[16] = 16;  //size of 'fmt '
    waveHead[17] = 0;
    waveHead[18] = 0;
    waveHead[19] = 0;
    
    waveHead[20] = 1;   //format
    waveHead[21] = 0;
    
    waveHead[22] = 1;   //chanel
    waveHead[23] = 0;
    
    waveHead[24] = (Byte)(sampleRate & 0xff);
    waveHead[25] = (Byte)((sampleRate >> 8) & 0xff);
    waveHead[26] = (Byte)((sampleRate >> 16) & 0xff);
    waveHead[27] = (Byte)((sampleRate >> 24) & 0xff);
    
    long byteRate = sampleRate * 2 * (16 >> 3);;
    waveHead[28] = (Byte)(byteRate & 0xff);
    waveHead[29] = (Byte)((byteRate >> 8) & 0xff);
    waveHead[30] = (Byte)((byteRate >> 16) & 0xff);
    waveHead[31] = (Byte)((byteRate >> 24) & 0xff);
    
    waveHead[32] = 2*(16 >> 3);
    waveHead[33] = 0;
    
    waveHead[34] = 16;
    waveHead[35] = 0;
    
    waveHead[36] = 'd';
    waveHead[37] = 'a';
    waveHead[38] = 't';
    waveHead[39] = 'a';
    
    long totalAudiolength = [audioData length];
    
    waveHead[40] = (Byte)(totalAudiolength & 0xff);
    waveHead[41] = (Byte)((totalAudiolength >> 8) & 0xff);
    waveHead[42] = (Byte)((totalAudiolength >> 16) & 0xff);
    waveHead[43] = (Byte)((totalAudiolength >> 24) & 0xff);
    
    self.pcmData = [[NSMutableData alloc]initWithBytes:&waveHead length:sizeof(waveHead)];
    [self.pcmData appendData:audioData];
    
    NSError *err = nil;
    self.player = [[AVAudioPlayer alloc]initWithData:self.pcmData error:&err];
    if (err)
    {
        NSLog(@"%@",err.localizedDescription);
    }
    self.player.delegate = self;
    [self.player prepareToPlay];
    
}

- (void)play
{
    [self writeWaveHead:self.audioData sampleRate:16000];
    if (self.player.isPlaying)
    {
        NSLog(@"pcmPlayer isPlaying");
        return;
    }
    
    
    self.player.volume=1;
    if ([self.pcmData length] > 44)
    {
        self.player.meteringEnabled = YES;
        NSLog(@"Audio Duration:%f",self.player.duration);
        
        BOOL ret = [self.player play];
        NSLog(@"play ret=%d",ret);
    }
    else
    {
//        self.isPlaying = NO;
        NSLog(@"empty audio data");
    }
    
}

- (void)stopPlay {
    if (self.player.isPlaying) {
        [self.player stop];
        self.player.currentTime = 0;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"in pcmPlayer audioPlayerDidFinishPlaying");
    
}

- (NSString *)fileName {
    return _fileName == nil ? @"test" : _fileName;
}

- (NSMutableData *)audioData {
    if (!_audioData) {
        _audioData = [[NSMutableData alloc] init];
    }
    return _audioData;
}

@end
