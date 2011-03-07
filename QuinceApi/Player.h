//
//  Player.h
//  quince
//
//  Created by max on 5/9/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//
//
//	If you have any questions contact quince@maximilianmarcoll.de
//
//	This file is part of quince.
//
//	quince is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	quince is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with quince.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>


#import <AudioToolbox/AudioToolbox.h>
#import <QuinceApi/QuinceObject.h>
#include <AudioUnit/AudioUnit.h>
//#include <AudioUnit/AudioComponent.h>
//#import <CoreAudio/CoreAudio.h>
//#import <CoreAudio/CoreAudioClock.h>

#define kPlayerNumberBuffers 3  

typedef struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2
    AudioQueueRef                 mQueue;                         // 3
    AudioQueueBufferRef           mBuffers[kPlayerNumberBuffers];       // 4
    AudioFileID                   mAudioFile;                     // 5
    UInt32                        bufferByteSize;                 // 6
    SInt64                        mCurrentPacket;                 // 7
    UInt32                        mNumPacketsToRead;              // 8
    AudioStreamPacketDescription  *mPacketDescs;                  // 9
    bool                          mIsRunning;					// 10
	UInt64						  lastPacket;
	void *						  player;
} AQPlayerState;


typedef struct PlayerMusicEventUserData{

	UInt32 length;
	QuinceObject * quince;	
} PlayerMusicEventUserData;

#ifndef MAC_OS_X_VERSION_10_6

enum {
	kAudioFileReadPermission      = 0x01,
	kAudioFileWritePermission     = 0x02,
	kAudioFileReadWritePermission = 0x03
};

#endif

OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData);

void sequenceUserCallback (
						   void                      *inClientData,
						   MusicSequence             inSequence,
						   MusicTrack                inTrack,
						   MusicTimeStamp            inEventTime,
						   const MusicEventUserData  *inEventData,
						   MusicTimeStamp            inStartSliceBeat,
						   MusicTimeStamp            inEndSliceBeat
						   );

OSStatus MintPlayerAURenderCallback (
							void                        *inRefCon,
							AudioUnitRenderActionFlags  *ioActionFlags,
							const AudioTimeStamp        *inTimeStamp,
							UInt32                      inBusNumber,
							UInt32                      inNumberFrames,
							AudioBufferList             *ioData
							);



@class QuinceDocument, QuinceObject;

@interface Player : NSObject {
	
	//CAClockRef clock;
	BOOL isPlaying;
	//NSNumber * startTime;
	AUGraph graph;
	MusicSequence sequence;
	MusicPlayer player;
	NSMutableArray * trackNodes;
	Float64 sampleTimeBase;
	
	QuinceDocument * document;
	NSNumber * startTime;
	
	NSMutableArray * flatQuinceList;
}

@property (assign) QuinceDocument * document;
@property (retain) NSNumber * startTime;

-(void)setup;
-(OSStatus)createEventForQuince:(QuinceObject *)quince inTrack:(MusicTrack)track;
-(void)checkQuince:(QuinceObject *)quince;
-(BOOL)isPlaying;
-(void)setIsPlaying:(BOOL)b;
-(MusicSequence)sequence;
-(MusicPlayer)player;
-(void)play;
-(void)stop;
-(void)getSampleTimeBase;
-(void)playQuince:(QuinceObject *)quince;
-(NSPanel *)window;
-(void)showWindow;
-(void)setSettings:(NSDictionary *)settings;
-(NSDictionary *)settings;
-(NSDictionary *)xmlDictionary;
-(void)mixDown;

-(IBAction)ok:(id)sender;

void DeriveBufferSize (
					   AudioStreamBasicDescription ASBDesc,                            // 1
					   UInt32                      maxPacketSize,                       // 2
					   Float64                     seconds,                             // 3
					   UInt32                      *outBufferSize,                      // 4
					   UInt32                      *outNumPacketsToRead                 // 5
					   );

void HandleOutputBuffer (
								void                *aqData,
								AudioQueueRef       inAQ,
								AudioQueueBufferRef inBuffer
								);

@end
