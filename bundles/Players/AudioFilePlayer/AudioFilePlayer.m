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

OSStatus playbackCallback(void *inRefCon,
                          AudioUnitRenderActionFlags *ioActionFlags,
                          const AudioTimeStamp *inTimeStamp,
                          UInt32 inBusNumber,
                          UInt32 inNumberFrames,
                          AudioBufferList *ioData) {
    
    
    
    //get a copy of the objectiveC class "self" we need this to get the next sample to fill the buffer
    //	RemoteIOPlayer *remoteIOplayer = (RemoteIOPlayer *)inRefCon;
    
    Player * quincePlayer = (Player *)inRefCon;
    
    MusicSequence seq = [quincePlayer sequence];
    MusicPlayer player = [quincePlayer player];
    MusicTimeStamp time;
    
    //loop through all the buffers that need to be filled
    for (int i = 0 ; i < ioData->mNumberBuffers; i++){
        //get the buffer to be filled
        AudioBuffer buffer = ioData->mBuffers[i];
        
        //if needed we can get the number of bytes that will fill the buffer using
        // int numberOfSamples = ioData->mBuffers[i].mDataByteSize;
        
        //get the buffer and point to it as an UInt32 (as we will be filling it with 32 bit samples)
        //if we wanted we could grab it as a 16 bit and put in the samples for left and right seperately
        //but the loop below would be for(j = 0; j < inNumberFrames * 2; j++) as each frame is a 32 bit number
        UInt32 *frameBuffer = buffer.mData;
        
        //loop through the buffer and fill the frames
        for (int j = 0; j < inNumberFrames; j++){
            // get NextPacket returns a 32 bit value, one frame.
            frameBuffer[j] = 0;//[[remoteIOplayer inMemoryAudioFile] getNextPacket];
        }
    }
    MusicPlayerGetTime(player, &time);
    
    Float64 seconds;
    
    MusicSequenceGetSecondsForBeats(seq, time, &seconds);
    float sec = seconds;
    //NSLog(@"%f", sec);
    NSNumber * t = [[NSNumber alloc] initWithFloat:sec];
    if([quincePlayer isPlaying])
        [[quincePlayer document] performSelectorOnMainThread:@selector(setCursorTime:) withObject:t waitUntilDone:NO]; //[[quincePlayer document]setCursorTime:t];
    [t release];
    //NSLog(@"huhu!");
    //dodgy return :)
    return noErr;
}


void sequenceUserCallback (
                           void                      *inClientData,
                           MusicSequence             inSequence,
                           MusicTrack                inTrack,
                           MusicTimeStamp            inEventTime,
                           const MusicEventUserData  *inEventData,
                           MusicTimeStamp            inStartSliceBeat,
                           MusicTimeStamp            inEndSliceBeat
                           ){
    NSAutoreleasePool * scbp = [[NSAutoreleasePool alloc]init];
    PlayerMusicEventUserData uData = *(PlayerMusicEventUserData *)inEventData;
    Player * player = (Player *)inClientData;
    
    /* AUNode				mixerNode;	// the mixer to connect an AU to
     AUNode				selfNode;	// the node associated with the AU
     AUGraph				subGraph;	// the subgraph holding the mixer and all AUs for the track
     
     QuinceObject * quince;
     
     MintPlayerEventStruct event;
     event.sequence = inSequence;
     event.track = inTrack;
     event.timeStamp = inEventTime;
     event.quince = uData.quince;
     */
    if(inStartSliceBeat!=inEndSliceBeat) // on MusicPlayerSetTime() they are equal
        [NSThread detachNewThreadSelector:@selector(playQuince:) toTarget:player withObject:uData.quince];
    //[player playQuince:uData.quince];
    
    //NSLog(@"%@", [uData.quince valueForKey:@"name"]);
    
    [scbp release];
}

-(void)setup{
    
    if(![self document] || isPlaying) return;
    
    OSStatus err;
    NewAUGraph(&graph);
#ifdef MAC_OS_X_VERSION_10_6
    AudioComponentDescription cd;
#endif
    
#ifndef MAC_OS_X_VERSION_10_6
    ComponentDescription cd;
#endif
    
    AUNode outputNode;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;
    
    // add it to the graph
    err = AUGraphAddNode(graph, &cd, &outputNode);
    if(err != noErr) NSLog(@"%@: error creating defaultOutput node: %d", [self className], (int)err);
    
    // create a sequence
    NewMusicSequence(&sequence); // error checking?!?!
    MusicSequenceSetAUGraph(sequence, graph); // connect the AUGraph
    err = MusicSequenceSetUserCallback (sequence, sequenceUserCallback, self);
    if(err != noErr) NSLog(@"%@: error adding sequenceUserCallback", [self className]);
    
    flatQuinceList = [document playbackObjectList];
    // create tracks, add events, and create AU-Sub-Graphs for each track
    //NSLog(@"%@: setup: %@", [self className], quinceList);
    
    // create tracks & add events
    
    MusicTrack track;
    MusicSequenceNewTrack(sequence, &track);
    
    //for(NSArray * strip in quinceList){
    
    for(QuinceObject * quince in flatQuinceList){
        //[quince log];
        err = [self createEventForQuince: quince inTrack:track];
        if(err != noErr) NSLog(@"%@: error adding event", [self className]);
    }
    MusicTrackSetDestNode(track, outputNode);
    //}
    
    err = AUGraphOpen(graph);
    if(err != noErr) NSLog(@"%@: error opening graph ", [self className]);
    err = AUGraphInitialize(graph);
    if(err != noErr) NSLog(@"%@: error initializing graph", [self className]);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    
    //set the reference to "self" this becomes *inRefCon in the playback callback
    callbackStruct.inputProcRefCon = self;
    
    AudioUnit outputUnit;
    err = AUGraphNodeInfo(graph, outputNode, NULL, &outputUnit);
    if(err)NSLog(@"%@: error getting outputUnit...", [self className]);
    
    err = AudioUnitSetProperty(outputUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct));
    if(err)NSLog(@"%@: error setting playbackCallback", [self className]);
    
    //AUGraphStart(graph);
}

-(OSStatus) createEventForQuince: (QuinceObject *) quince inTrack:(MusicTrack) track{
    
    PlayerMusicEventUserData data;
    data.length = sizeof(PlayerMusicEventUserData);
    data.quince = quince;
    OSStatus err = noErr;
    [self checkQuince:quince];
    
    MusicTimeStamp timeStamp;
    Float64 seconds = [[quince valueForKey:@"start"]doubleValue];//+[[quince valueForKey:@"startOffset"]doubleValue];
    MusicSequenceGetBeatsForSeconds(sequence, seconds, &timeStamp);
    if(![[quince valueForKey:@"muted"]boolValue]){
        err = MusicTrackNewUserEvent(track, timeStamp, (MusicEventUserData *)&data);
        //http://lists.apple.com/archives/Coreaudio-api/2006/Feb/msg00147.html
        if(err != noErr) NSLog(@"%@: error adding event to track", [self className]);
    }
    //NSLog(@"createEventForMint:inTrack: added event: %@ at %f", [quince valueForKey:@"name"], s);
    return err;
}

-(void)checkQuince:(QuinceObject *)quince{ // if the startTime is positioned IN a QuinceObject,
    // change that object's start, duration and audioFileStart values accordingly
    
    double quinceStart = [[quince valueForKey:@"start"]doubleValue];//+[[quince valueForKey:@"startOffset"]doubleValue];;
    double playerStart= [[self startTime]doubleValue];
    if(quinceStart > playerStart)
        return;
    
    double duration = [[quince valueForKey:@"duration"]doubleValue];
    
    if (quinceStart+duration > playerStart) {
        [quince setValue:[NSNumber numberWithDouble:playerStart] forKey:@"start"];
        double diff = playerStart - quinceStart;
        [quince setValue:[NSNumber numberWithDouble:duration - diff] forKey:@"duration"];
        //[quince setValue:[quince mediaFileStart] forKey:@"mediaFileStart"];
        double mediaFileStart = [[quince valueForKey:@"mediaFileStart"]doubleValue];
        [quince setValue:[NSNumber numberWithDouble:mediaFileStart + diff] forKey:@"mediaFileStart"];
    }
}

-(void)play{
    //NSLog(@"play");
    [self setup];
    
    NewMusicPlayer(&player);
    
    MusicPlayerSetSequence(player, sequence);
    Float64 seconds = [[self startTime]doubleValue];
    MusicTimeStamp timeStamp;
    MusicSequenceGetBeatsForSeconds(sequence, seconds, &timeStamp);
    //MusicPlayerPreroll(player);
    
    
    //NSLog(@"player:play: now starting MusicPlayer...");
    MusicPlayerStart(player);
    MusicPlayerSetTime(player, timeStamp);
    
    [self getSampleTimeBase];
    [self setIsPlaying:YES];
    //NSLog(@"player: play done");
}


-(void)stop{
    //NSLog(@"stop");
    MusicPlayerStop(player);
    [self setIsPlaying:NO];
    AUGraphStop(graph);
    Boolean b;
    MusicPlayerIsPlaying(player, &b);
    if(b)NSLog(@"still playing, shouldn't be..");
    [document setCursorTime:[document valueForKey:@"playbackStartTime"]];
}

-(void)getSampleTimeBase{
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= 44100.00;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 2;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 4;
    audioFormat.mBytesPerFrame		= 4;
    
    AudioQueueRef q;
    AudioQueueNewOutput(&audioFormat,HandleOutputBuffer,NULL,CFRunLoopGetCurrent(),kCFRunLoopCommonModes,0,&q);
    AudioTimeStamp sampleBase;
    AudioQueueDeviceGetCurrentTime(q, &sampleBase);
    
    //double smp = sampleBase.mSampleTime;
    sampleTimeBase = sampleBase.mSampleTime;
    //NSLog(@"getSampleTimeBase: %f", smp);
    AudioQueueDispose(q, NO);
}

-(MusicSequence)sequence{return sequence;}
-(MusicPlayer)player{return player;}


//////////////////////////////////////////////////////////////////////////////////


void HandleOutputBuffer (
                         void                *aqData,
                         AudioQueueRef       inAQ,
                         AudioQueueBufferRef inBuffer
                         ) {
    
    //NSLog(@"HandleOutputBuffer");
    AQPlayerState *pAqData = (AQPlayerState *) aqData;        // 1
    //if (pAqData->mIsRunning == 0) return;                     // 2
    UInt32 numBytesReadFromFile;                              // 3
    UInt32 numPackets = pAqData->mNumPacketsToRead;           // 4
    
    Player * player = (Player *)pAqData->player;
    
    AudioFileReadPackets (
                          pAqData->mAudioFile,
                          false,
                          &numBytesReadFromFile,
                          pAqData->mPacketDescs,
                          pAqData->mCurrentPacket,
                          &numPackets,
                          inBuffer->mAudioData
                          );
    if (numPackets > 0 && [player isPlaying]) {                                     // 5
        inBuffer->mAudioDataByteSize = numBytesReadFromFile;  // 6
        AudioQueueEnqueueBuffer (
                                 pAqData->mQueue,
                                 inBuffer,
                                 (pAqData->mPacketDescs ? numPackets : 0),
                                 pAqData->mPacketDescs
                                 );
        pAqData->mCurrentPacket += numPackets;                // 7
        if(pAqData->mCurrentPacket >= pAqData->lastPacket){
            AudioQueueStop (pAqData->mQueue,false);
            pAqData->mIsRunning = false;
        }
        //NSLog(@"HandleOutputBuffer: read %d packets", numPackets);
    } else {
        AudioQueueStop (pAqData->mQueue, true);
        
        pAqData->mIsRunning = false;
        //NSLog(@"HandleOutputBuffer: nothing read");
    }
}

//////////////////////////////////////////////////////////////////////////////////


void DeriveBufferSize (
                       AudioStreamBasicDescription  ASBDesc,                            // 1
                       UInt32                      maxPacketSize,                       // 2
                       Float64                     seconds,                             // 3
                       UInt32                      *outBufferSize,                      // 4
                       UInt32                      *outNumPacketsToRead                 // 5
) {
    static const int maxBufferSize = 0x50000;                        // 6
    static const int minBufferSize = 0x4000;                         // 7
    
    if (ASBDesc.mFramesPerPacket != 0) {                             // 8
        Float64 numPacketsForTime =
        ASBDesc.mSampleRate / ASBDesc.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {                                                         // 9
        *outBufferSize =
        maxBufferSize > maxPacketSize ?
        maxBufferSize : maxPacketSize;
    }
    
    if (                                                             // 10
        *outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize
        )
        *outBufferSize = maxBufferSize;
    else {                                                           // 11
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12
}


@end
