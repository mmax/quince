//
//  AudioFilePlayer.m
//  quince
//
//  Created by max on 5/11/10.
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

#import "AudioFilePlayer.h"


@implementation AudioFilePlayer


-(void)playQuince:(QuinceObject *)quince{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	//NSLog(@"playing: %@", [quince valueForKey:@"name"]);

	if(![quince mediaFile])
		return;
	
	const char * filePath = [[[quince mediaFile]valueForKey:@"filePath"]cStringUsingEncoding: NSASCIIStringEncoding];

    int length = [[[quince mediaFile]valueForKey:@"filePath"]length];
	

   // does not work with ä/ö/ü/ in the filePath anymore!!
    
    
	CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation ( NULL,(const UInt8 *) filePath,length /*strlen(filePath)*/, false);

    
	double start = [[quince valueForKey:@"mediaFileStart"]doubleValue];
	double duration = [[quince valueForKey:@"duration"]doubleValue];
	double dB = [[quince valueForKey:@"volume"]doubleValue];
	
	AQPlayerState aqData;                                   // 1
	
	OSStatus err = AudioFileOpenURL (audioFileURL, fsRdPerm,0,&aqData.mAudioFile);
	if(err) NSLog(@"failed to open file %s!", filePath );
	CFRelease (audioFileURL);                               // 7
	
	UInt32 dataFormatSize = sizeof (aqData.mDataFormat);    // 1
	
	AudioFileGetProperty (aqData.mAudioFile, kAudioFilePropertyDataFormat,&dataFormatSize,&aqData.mDataFormat);
	
	AudioQueueNewOutput(&aqData.mDataFormat,HandleOutputBuffer,&aqData,CFRunLoopGetCurrent(),kCFRunLoopCommonModes,0,&aqData.mQueue);
	UInt32 maxPacketSize;
	UInt32 propertySize = sizeof (maxPacketSize);
	AudioFileGetProperty ( aqData.mAudioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize,&maxPacketSize );
	
	DeriveBufferSize(aqData.mDataFormat,maxPacketSize,0.01,&aqData.bufferByteSize,&aqData.mNumPacketsToRead);
	
	bool isFormatVBR = (aqData.mDataFormat.mBytesPerPacket == 0 || aqData.mDataFormat.mFramesPerPacket == 0 );
	
	if (isFormatVBR) { 
		aqData.mPacketDescs = (AudioStreamPacketDescription*) malloc (aqData.mNumPacketsToRead * sizeof (AudioStreamPacketDescription));
	} 
	else{
		aqData.mPacketDescs = NULL;
	}
	
	int framesPerPacket = aqData.mDataFormat.mFramesPerPacket;
	int sampleRate = aqData.mDataFormat.mSampleRate;
	int channels = aqData.mDataFormat.mChannelsPerFrame;
	//NSLog(@"channels: %d", channels);
	double samples = framesPerPacket*channels;
	double secondsPerPacket = samples/sampleRate/channels;
	
	int startPacket = start/secondsPerPacket + 0.5;
	int lastPacket = (duration/secondsPerPacket + 0.5)+startPacket;
	aqData.lastPacket = lastPacket;
	//NSLog(@"playQuince: \nframesPerPacket: %d\nsampleRate: %d\nchannels: %d\nsecondsPerPacket: %f\nstart: %f\nstartPacket: %d\n", framesPerPacket, sampleRate, channels, secondsPerPacket, start, startPacket);
	aqData.mCurrentPacket = startPacket;//0; // offset here!!
	
	aqData.mIsRunning = true;
	aqData.player = self;
	
	for (int i = 0; i < kPlayerNumberBuffers; ++i) {
		AudioQueueAllocateBuffer ( aqData.mQueue, aqData.bufferByteSize, &aqData.mBuffers[i] );
		HandleOutputBuffer ( &aqData, aqData.mQueue, aqData.mBuffers[i] );
	}
	
	Float32 gain = pow(10, dB/20);
	// Optionally, allow user to override gain setting here
	//NSLog(@"setting volume...");
	err = AudioQueueSetParameter ( aqData.mQueue, kAudioQueueParam_Volume, gain);
	if(err != noErr) NSLog(@"%@: error setting queue parameter", [self className]);
	//NSLog(@"volume set");
	
	
	AudioTimeStamp time;
	//NSLog(@"created timeStamp");
	//AudioQueueGetCurrentTime(aqData.mQueue, NULL, &time, NULL);
	double relativeStartTime = [[quince valueForKey:@"start"]doubleValue] - [[self startTime] doubleValue];
	//NSLog(@"relativeStartTime ready");
	//NSLog(@"relativeStartTime: %f", relativeStartTime);
	time.mFlags = kAudioTimeStampSampleTimeValid;
	time.mSampleTime = relativeStartTime*44100 + sampleTimeBase + 1000;
	
	err = AudioQueueStart ( aqData.mQueue, &time ); // NULL -> start as soon as possible
	if(err != noErr) NSLog(@"%@: error starting queue", [self className]);
	
	//NSLog(@"queue started");
	
	do {
		CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0.25, false);
	}while (aqData.mIsRunning);
	
	CFRunLoopRunInMode (kCFRunLoopDefaultMode,1,false);
	AudioQueueDispose(aqData.mQueue,true);
	
	AudioFileClose (aqData.mAudioFile);            // 4
	
	free (aqData.mPacketDescs);                    // 5
	[pool release];
	//NSLog(@"playQuince: done");
}


@end
