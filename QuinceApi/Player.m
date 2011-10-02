//
//  Player.m
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

#import <QuinceApi/Player.h>
#import <QuinceApi/QuinceDocument.h>



@implementation Player

@synthesize document, startTime;



-(Player *)init{

	if((self = [super init])){
		[self setStartTime:[NSNumber numberWithInt:0]];
		trackNodes = [[NSMutableArray alloc]init];
		isPlaying = NO;
        dictionary = [[NSMutableDictionary alloc]init];
		
	}
	return self;
}

-(void)dealloc{

    [dictionary release];
    [trackNodes release];
    [super dealloc];
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
	if(err != noErr) NSLog(@"%@: error creating defaultOutput node: %ld", [self className], err);
		
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

-(NSPanel *)window{
	return nil;
}

-(IBAction)ok:(id)sender{
	if([self window])
		[[self window]orderOut:nil];
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

-(BOOL)isPlaying{return isPlaying;}

-(void)setIsPlaying:(BOOL)b{
    isPlaying = b;
    [document setValue:[NSNumber numberWithBool:b] forKey:@"playbackStarted"];
    [document setValue:[NSNumber numberWithBool:!b] forKey:@"playbackStopped"];
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


//////////////////////////////////////////////////////////////////////////////////
// i reckon this is where player_plug-ins will implement their playback algorithms:
-(void)playQuince:(QuinceObject *)quince{

}

-(void)showWindow{
}

-(NSDictionary *)xmlDictionary{

	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	
	[dict setValue:[self className] forKey:@"name"];
	[dict setValue:[self settings] forKey:@"settings"];
	return [dict autorelease];
}

-(NSDictionary *)settings{

	return [NSDictionary dictionary];
}

-(void)setSettings:(NSDictionary *)settings{

}


-(void)mixDown{
	[document presentAlertWithText:@"not implemented"];
}


#pragma mark KVC

-(void)setValue:(id)aValue forKey:(NSString *)aKey{
	
	[self willChangeValueForKey:aKey];
	[self willChangeValueForKey:@"dictionary"];
	[dictionary setValue:aValue forKey:aKey];
	
	[self didChangeValueForKey:aKey];
	[self didChangeValueForKey:@"dictionary"];
	
}



-(id)valueForKey:(NSString *)key{

	if([key isEqualToString:@"dictionary"])
		return [self dictionary];
    return [dictionary valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
} 

-(void)removeObjectForKey:(NSString *)key{
	[self willChangeValueForKey:key];
	[dictionary removeObjectForKey:key];
	[self didChangeValueForKey:key];
}


-(NSDictionary *)dictionary{return dictionary;}
@end


 /* -(void)setup{
    
    if(![self document] || isPlaying) return;
    
    OSStatus err;
    NewAUGraph(&graph);
    AudioComponentDescription cd;
    
    AUNode mixerNode = [self createOutputAndMixer];
    
    if(!mixerNode){
	    NSLog(@"%@: setup: basic setup failed!", [self className]);
	    return;
    }
    
    // create a sequence
    NewMusicSequence(&sequence); // error checking?!?!
    MusicSequenceSetAUGraph(sequence, graph); // connect the AUGraph
    err = MusicSequenceSetUserCallback (sequence, sequenceUserCallback, NULL);
    if(err != noErr) NSLog(@"%@: error adding sequenceUserCallback", [self className]);
    
    NSMutableArray * quinceList = [document playbackObjectList];
    
    // create tracks, add events, and create AU-Sub-Graphs for each track
    UInt32 stripIndex = 0;
    NSLog(@"%@",quinceList);
    
    for(NSArray * strip in quinceList){
	    MusicTrack track;
	    MusicSequenceNewTrack(sequence, &track);
	    for(QuinceObject * quince in strip){
		    err = [self createEventForMint: quince inTrack:track];
		    // act in case of error?!
	    }
	    
	    AUGraph subGraph;
	    AUNode subGraphNode;
	    err = AUGraphNewNodeSubGraph(graph, &subGraphNode);
	    if(err != noErr) NSLog(@"%@: error adding subGraphNode", [self className]);
	    
	    err = AUGraphGetNodeInfoSubGraph(graph, subGraphNode, &subGraph);
	    if(err != noErr) NSLog(@"%@: error getting subGraph from subGraphNode", [self className]);
	    
	    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	    cd.componentFlags = 0;
	    cd.componentFlagsMask = 0;
	    cd.componentType = kAudioUnitType_Output;
	    cd.componentSubType = kAudioUnitSubType_GenericOutput;
	    
	    AUNode trackPlayerNode;
	    err = AUGraphAddNode(subGraph, &cd, &trackPlayerNode);
	    if(err != noErr)NSLog(@"%@: error adding generic output node as trackPlayerNode!", [self className]);
	    
	    err = AUGraphConnectNodeInput(graph, subGraphNode, 0, mixerNode, stripIndex);	
	    if(err != noErr)NSLog(@"%@: error connecting subGraphNode to the mixer!", [self className]);
	    
	    [trackNodes addObject:[NSData dataWithBytesNoCopy:&trackPlayerNode length:sizeof(AUNode)]];
	    MusicTrackSetDestNode(track, trackPlayerNode);
	    
	    stripIndex++;
    }
    
    AUGraphOpen(graph);
    AUGraphInitialize(graph);
    
    for(NSData * d in trackNodes){
	    
	    AUNode trackPlayerNode = *(AUNode *)[d bytes];
	    AURenderCallbackStruct callbackStruct;
	    callbackStruct.inputProc = playbackCallback;
	    
	    //set the reference to "self" this becomes *inRefCon in the playback callback
	    callbackStruct.inputProcRefCon = self;
	    
	    AudioUnit trackPlayerUnit;
	    err = AUGraphNodeInfo(graph, trackPlayerNode, NULL, &trackPlayerUnit);
	    if(err)NSLog(@"%@: error getting trackPlayerUnit...", [self className]);
	    
	    err = AudioUnitSetProperty(trackPlayerUnit, 
								   kAudioUnitProperty_SetRenderCallback, 
								   kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct));
	    if(err)NSLog(@"%@: error setting playbackCallback", [self className]);
	    
    }
    
    AUGraphStart(graph);
 }

  */

/* -(AUNode)createOutputAndMixer{

	OSStatus err;
	AudioComponentDescription cd;

	//create the default output unit
	AUNode outputNode;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;
	
	// add it to the graph
	err = AUGraphAddNode(graph, &cd, &outputNode);
	if(err != noErr){
		NSLog(@"%@: error creating defaultOutput node: %d", [self className], err);
		return -1;
	}
	
	// create a mixer unit
	AUNode mixerNode;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	cd.componentType = kAudioUnitType_Mixer;
	cd.componentSubType = kAudioUnitSubType_StereoMixer;
	
	//add it to the graph
	err = AUGraphAddNode(graph, &cd, &mixerNode);	
	if(err != noErr){
		NSLog(@"%@: error adding mixerNode", [self className]);
		return -1;
	}

	// connect them
	err = AUGraphConnectNodeInput(graph, mixerNode, 0, outputNode, 0); 	
	if(err != noErr){
		NSLog(@"%@: error connecting mixeNode", [self className]);
		return -1;
	}

	return mixerNode;
}
 */


//		AudioUnit trackPlayerUnit;
//		
//		err = AUGraphNodeInfo(graph, trackPlayerNode, NULL, &trackPlayerUnit);
//		if(err != noErr)NSLog(@"%@: error getting trackPlayerUnit...", [self className]);
//		


//
//		

//	

//err = AUGraphNodeInfo(graph, OutputNode, NULL, &outputUnit);
//	if(err != noErr)
//		NSLog(@"%@: error getting defaultOutputUnit", [self className]);
//	
//	AudioStreamBasicDescription audioFormat;
//	
//	audioFormat.mSampleRate			= 44100.00;
//	audioFormat.mFormatID			= kAudioFormatLinearPCM;
//	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
//	audioFormat.mFramesPerPacket	= 1;
//	audioFormat.mChannelsPerFrame	= 2;
//	audioFormat.mBitsPerChannel		= 16;
//	audioFormat.mBytesPerPacket		= 4;
//	audioFormat.mBytesPerFrame		= 4;
//	
//	//Apply format
//	err = AudioUnitSetProperty(outputUnit, 
//							   kAudioUnitProperty_StreamFormat, 
//							   kAudioUnitScope_Input, 
//							   0, 
//							   &audioFormat, 
//							   sizeof(audioFormat));
//	if(err != noErr)
//		NSLog(@"%@: error setting audioFormat", [self className]);
//	
//AURenderCallbackStruct callbackStruct;
//	callbackStruct.inputProc = playbackCallback;
//	//set the reference to "self" this becomes *inRefCon in the playback callback
//	//
//	//callbackStruct.inputProcRefCon = self;
//	
//	//err = AudioUnitSetProperty(trackPlayerUnit, 
//	//								   kAudioUnitProperty_SetRenderCallback, 
//	//								   kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct));
//	
//	err = AudioUnitSetProperty(outputUnit, 
//							   kAudioUnitProperty_SetRenderCallback, 
//							   kAudioUnitScope_Global, 
//							   0, 
//							   &callbackStruct, 
//							   sizeof(callbackStruct));
//	
//	if(err != noErr)NSLog(@"%@: error setting playbackCallback: %d", [self className], err);
//	


// register callback function on the AUs

/* for(NSData * data in trackNodes){
 
 AUNode trackPlayerNode = *(AUNode *)[data bytes];
 AudioUnit trackPlayerUnit;
 err = AUGraphNodeInfo(graph, trackPlayerNode, NULL, &trackPlayerUnit);
 if(err)NSLog(@"%@: error getting trackPlayerUnit...", [self className]);
 AURenderCallbackStruct callbackStruct;
 callbackStruct.inputProc = playbackCallback;
 //set the reference to "self" this becomes *inRefCon in the playback callback
 callbackStruct.inputProcRefCon = self;
 
 err = AudioUnitSetProperty(trackPlayerUnit, 
 kAudioUnitProperty_SetRenderCallback, 
 kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct));
 if(err)NSLog(@"%@: error setting playbackCallback", [self className]);
 }
 */	
/*
 AURenderCallbackStruct callbackStruct;
 callbackStruct.inputProc = playbackCallback;
 //set the reference to "self" this becomes *inRefCon in the playback callback
 callbackStruct.inputProcRefCon = self;
 
 AudioUnitSetProperty(trackPlayerUnit, //error!?!?!?!
 kAudioUnitProperty_SetRenderCallback, 
 kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct));
 
 
 */	



/*
-(void)startClock{

	//clock = malloc(sizeof(CAClockRef));	
	CAClockNew(	0,&clock);
	CAClockTime time;
	time.format = kCAClockTimeFormat_Seconds;
	CAClockSeconds sec = [[self startTime]doubleValue]; // set by cursor_position 
	time.time.seconds = sec; 
	CAClockSetCurrentTime(clock, &time);	
	CAClockStart(clock);
}

-(void)stopClock{
	
	CAClockStop(clock);
	[self setIsPlaying:NO];
	CAClockDispose(clock);
	//free(clock); //necessary?
}

-(void)play{

	if(![self document] || isPlaying)
		return;
	
	NSMutableArray * quinceList = [document playbackObjectList];

	[self startClock];
	[self setIsPlaying:YES];
	
	// actually we need one thread per strip, with it's own list
	[NSThread detachNewThreadSelector:@selector(playbackLoop:) toTarget:self withObject:quinceList];	
}

-(void)stop{
	[self stopClock];
	NSLog(@"done");
}

-(void)playbackLoop:(NSMutableArray *)list{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	CAClockTime time;

	while([list count]&& [self isPlaying]){
		CAClockGetCurrentTime(clock, kCAClockTimeFormat_Seconds, &time);
		//[NSThread detachNewThreadSelector:@selector(setCursorTime:) toTarget:[self document] withObject:[NSNumber numberWithDouble:time.time.seconds]];
		[document setCursorTime:[NSNumber numberWithDouble:time.time.seconds]];
			// perform drawing on another thread
		while ([list count] && (time.time.seconds >= [[[list objectAtIndex:0]valueForKey:@"start"]doubleValue])) {
			[NSThread detachNewThreadSelector:@selector(playQuince:) toTarget:self withObject:[list objectAtIndex:0]];//[self playQuince:[list objectAtIndex:0]];
			[list removeObjectAtIndex:0];
		}
	}
	
	if([self isPlaying])
		[self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];

	[pool release];
}

*/

