//
//  OscilPlayer.m
//  quince
//
//  Created by max on 6/30/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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

#import "OscilPlayer.h"


@implementation OscilPlayer

-(OscilPlayer *)init{
    
	if((self = [super init])){
		[self fillWFBuffers];
	}
	return self;
}

-(void)dealloc{

    free(sine);
    [super dealloc];
}

-(void)fillWFBuffers{

    sine = malloc(kOscilPlayerWaveTableSize  * sizeof(double));
    double frac = 360.0/kOscilPlayerWaveTableSize ;
    
    for(int i = 0;i<kOscilPlayerWaveTableSize ;i++)
        sine[i] = sin(frac * i);
}

-(void)playQuince:(QuinceObject *)quince{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	//NSLog(@"playing: %@", [quince valueForKey:@"name"]);
    
	if(![quince valueForKey:@"frequency"])
		return;
	
    
	double duration = [[quince valueForKey:@"duration"]doubleValue];
	double dB = [[quince valueForKey:@"volume"]doubleValue];
	
	AQPlayerState aqData;                                   // 1
	
	//UInt32 dataFormatSize = sizeof (aqData.mDataFormat);    // 1
	

	
		UInt32 maxPacketSize;
	//UInt32 propertySize = sizeof (maxPacketSize);
	
	
	
//	bool isFormatVBR = (aqData.mDataFormat.mBytesPerPacket == 0 || aqData.mDataFormat.mFramesPerPacket == 0 );
//	
//	if (isFormatVBR) { 
//		aqData.mPacketDescs = (AudioStreamPacketDescription*) malloc (aqData.mNumPacketsToRead * sizeof (AudioStreamPacketDescription));
//	} 
//	else{
//		aqData.mPacketDescs = NULL;
//	}
	
	int framesPerPacket = aqData.mDataFormat.mFramesPerPacket;
	int sampleRate = aqData.mDataFormat.mSampleRate;
	int channels = aqData.mDataFormat.mChannelsPerFrame;
	//NSLog(@"channels: %d", channels);
	double samples = framesPerPacket*channels;
	double secondsPerPacket = samples/sampleRate/channels;
	
	int startPacket = 0.5;
	int lastPacket = (duration/secondsPerPacket + 0.5)+startPacket;
	aqData.lastPacket = lastPacket;
	//NSLog(@"playQuince: \nframesPerPacket: %d\nsampleRate: %d\nchannels: %d\nsecondsPerPacket: %f\nstart: %f\nstartPacket: %d\n", framesPerPacket, sampleRate, channels, secondsPerPacket, start, startPacket);
	aqData.mCurrentPacket = startPacket;//0; // offset here!!
	
	aqData.mIsRunning = true;
	aqData.player = self;
    aqData.frequency = [[quince valueForKey:@"frequency"]doubleValue];
    aqData.index = 0;
	aqData.mDataFormat.mSampleRate = 44100;
    aqData.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aqData.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
    aqData.mDataFormat.mBytesPerPacket = 4;
    aqData.mDataFormat.mFramesPerPacket = 1;
    aqData.mDataFormat.mBytesPerFrame = 4;
    aqData.mDataFormat.mChannelsPerFrame = 2;
    aqData.mDataFormat.mBitsPerChannel = 16;
    aqData.mDataFormat.mReserved = 0;
    
    AudioQueueNewOutput(&aqData.mDataFormat,HandleOutputBuffer,&aqData,CFRunLoopGetCurrent(),kCFRunLoopCommonModes,0,&aqData.mQueue);
    DeriveBufferSize(aqData.mDataFormat,maxPacketSize,0.01,&aqData.bufferByteSize,&aqData.mNumPacketsToRead);
    
	for (int i = 0; i < kPlayerNumberBuffers; ++i) {
		AudioQueueAllocateBuffer ( aqData.mQueue, aqData.bufferByteSize, &aqData.mBuffers[i] );
		HandleOutputBuffer ( &aqData, aqData.mQueue, aqData.mBuffers[i] );
	}
	
	Float32 gain = pow(10, dB/20);
	// Optionally, allow user to override gain setting here
	//NSLog(@"setting volume...");
	OSStatus err = AudioQueueSetParameter ( aqData.mQueue, kAudioQueueParam_Volume, gain);
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
	
	//AudioFileClose (aqData.mAudioFile);            // 4
	
	free (aqData.mPacketDescs);                    // 5
	[pool release];
	//NSLog(@"playQuince: done");
}

//////////////////////////////////////////////////////////////////////////////////
//http://stackoverflow.com/questions/1361148/how-do-i-synthesize-sounds-with-coreaudio-on-iphone-mac

void HandleOutputBuffer (
						 void                *aData,
						 AudioQueueRef       inAQ,
						 AudioQueueBufferRef inBuffer
						 ) {
	
	//NSLog(@"HandleOutputBuffer");
    AQPlayerState *pAqData = (AQPlayerState *) aData;        // 1
    AQPlayerState * aqData = (AQPlayerState *) aData;
    //if (pAqData->mIsRunning == 0) return;                     // 2
    UInt32 numBytesReadFromFile;                              // 3
   // UInt32 numPackets = pAqData->mNumPacketsToRead;           // 4
	int index = aqData->index;
	Player * player = (Player *)pAqData->player;
    double dIncr = aqData->frequency / aqData->mDataFormat.mSampleRate;
    UInt16 sample = 0;
    
    void* pBuffer = inBuffer->mAudioData;
    UInt32 bytes = inBuffer->mAudioDataBytesCapacity;
    
    for(int i = 0;i<bytes;i+=4){
    
    
    }
    //    AudioFileReadPackets (
//						  pAqData->mAudioFile,
//						  false,
//						  &numBytesReadFromFile,
//						  pAqData->mPacketDescs, 
//						  pAqData->mCurrentPacket,
//						  &numPackets,
//						  inBuffer->mAudioData 
//						  );
//    if (numPackets > 0 && [player isPlaying]) {                                     // 5
//        inBuffer->mAudioDataByteSize = numBytesReadFromFile;  // 6
//		AudioQueueEnqueueBuffer ( 
//								 pAqData->mQueue,
//								 inBuffer,
//								 (pAqData->mPacketDescs ? numPackets : 0),
//								 pAqData->mPacketDescs
//								 );
//        pAqData->mCurrentPacket += numPackets;                // 7 
//		if(pAqData->mCurrentPacket >= pAqData->lastPacket){
//			AudioQueueStop (pAqData->mQueue,false);
//			pAqData->mIsRunning = false; 
//		}
//		//NSLog(@"HandleOutputBuffer: read %d packets", numPackets);
//    } else {
//        AudioQueueStop (pAqData->mQueue, true);
//		
//        pAqData->mIsRunning = false; 
//		//NSLog(@"HandleOutputBuffer: nothing read");
//    }
    
    if([player isPlaying]){
    
        
    }
}


@end
