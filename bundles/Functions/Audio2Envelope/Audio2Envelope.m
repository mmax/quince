//
//  Audio2Envelope.m
//  quince
//
//  Created by max on 3/5/10.
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

#import "Audio2Envelope.h"
#import <QuinceApi/AudioFile.h>
#import <QuinceApi/Envelope.h>


@implementation Audio2Envelope

-(Audio2Envelope *)init{

	if((self = [super init])){
		sr = 44100;
	}
   return self;
}	

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"source" forKey:@"purpose"];
	[dictA setValue:@"AudioFile" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}


-(BOOL)checkObject:(QuinceObject *)quince ofType:(NSString *)type{

	if([quince isOfType:type]){//[type isEqualToString:@"MintFile"]){

		path = [quince valueForKey:@"filePath"];

		AudioFileID file;// = [self openAudioFileAtPath:path];
		FSRef fileRef;
		OSStatus err = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &fileRef, NULL);
		
		if(err) {
			NSLog(@"SequenceFromAudioFile: Could not create FSRef from path");
			return NO;
		}
		err = AudioFileOpenURL (CFURLCreateFromFSRef(NULL,&fileRef), kAudioFileReadWritePermission, 0, &file);
		
		if(err){
			NSLog(@"could not open audiofile");
			return NO;
		}
		AudioFileClose(file);
	}
	
	return YES;
}
	
-(void)perform{
	//NSLog(@"%@: perform...", [self className]);
	if(![self checkObject:[self objectForPurpose:@"source"] ofType:@"QuinceObject"]){
	
		[document presentAlertWithText:
		 [NSString stringWithFormat:@"%@: check failed. can not operate on object %@", 
		  [self className], 
		  [[self objectForPurpose:@"source"]valueForKey:@"name"]]];
		return;
	}

	[document setIndeterminateProgressTask:
	 [NSString stringWithFormat:@"Reading Sound Data: %@", [[self objectForPurpose:@"source"]valueForKey:@"name"]]];		
	[document displayProgress:YES];	
	
	NSArray * data = [self readSoundData];
	Envelope * env = (Envelope *)[self outputObjectOfType:@"Envelope"];
	[env setValue:[NSNumber numberWithInt:kSamplesPerWindow] forKey:@"samplesPerWindow"];
	[env setValue:[NSNumber numberWithDouble:frameCount/ sr] forKey:@"duration"];
	[env setEnvelope:data];
	[env setValue:[NSNumber numberWithInt:sr] forKey:@"sampleRate"];
	NSArray * comp = [[[self objectForPurpose:@"source"]valueForKey:@"name"]componentsSeparatedByString:@"."];
	int index = [comp count] > 2 ? [comp count]-2 : 0;
	if(![self valueForKey:@"result"])
		[env setValue:[NSString stringWithFormat:@"%@_env", [comp objectAtIndex:index]] forKey:@"name"];
	[env setValue:[[self objectForPurpose:@"source"]valueForKey:@"name"] forKey:@"audioFileName"];
	[document displayProgress:NO];
	[self done];
}

-(NSArray *) readSoundData{ // look at http://www.cocoadev.com/index.pl?ExtAudioFile
	frameCount = 0;
	NSMutableArray * data = [[NSMutableArray alloc]init];
	ExtAudioFileRef inFile;
	OSStatus err;
	FSRef soundRef;
	int i, kSrcBufSize = kSamplesPerWindow;
	Float32 srcBuffer[kSrcBufSize];//, progress=0;
	int nChannels = 1;
	AudioFile * file = (AudioFile *)[self objectForPurpose:@"source"]; // is already typechecked, so the cast is ok!
	if(!file){
		[document presentAlertWithText:[NSString stringWithFormat:@"%@: ERROR: readSoundData:  no file!", [self className]]];
		return nil;
	}
		
	path = [file valueForKey:@"filePath"];

	err = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &soundRef, NULL);
	if(err) {
		[document presentAlertWithText:[NSString stringWithFormat:@"EnvelopeFromAudioFile: ERROR: invalid path: %@", path]]; //Could not create FSRef from path
		return nil;
	}
	//int samplesPerWindow = kSamplesPerWindow;
	err = ExtAudioFileOpenURL(CFURLCreateFromFSRef(NULL, &soundRef), &inFile);
	
//    kExtAudioFileProperty_FileLengthFrames
    
    SInt64 totalFrameCount;
    UInt32 tfcs = sizeof(totalFrameCount);
    
    err = ExtAudioFileGetProperty(inFile, kExtAudioFileProperty_FileLengthFrames, &tfcs, &totalFrameCount);
	UInt32 propSize;
	
	AudioStreamBasicDescription clientFormat;
	propSize = sizeof(clientFormat);
	
	err = ExtAudioFileGetProperty(inFile, kExtAudioFileProperty_FileDataFormat, &propSize, &clientFormat);
	//_ThrowExceptionIfErr(@"kExtAudioFileProperty_FileDataFormat", err);
	
	
	// If you need to alloc a buffer, you'll need to alloc filelength*channels*rateRatio bytes
	//double rateRatio = kGraphSampleRate / clientFormat.mSampleRate;
	
	
	clientFormat.mSampleRate = sr;
	//clientFormat.SetCanonical(1, true);

	// copied from setCanonical....
	clientFormat.mFormatID = kAudioFormatLinearPCM;
	int sampleSize = sizeof(Float32);
	clientFormat.mFormatFlags = kAudioFormatFlagsCanonical;
	clientFormat.mBitsPerChannel = 8 * sampleSize;
	clientFormat.mChannelsPerFrame = nChannels;
	clientFormat.mFramesPerPacket = 1;
	clientFormat.mBytesPerPacket = clientFormat.mBytesPerFrame = nChannels * sampleSize;
	
	
	
	propSize = sizeof(clientFormat);
	err = ExtAudioFileSetProperty(inFile, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
	//_ThrowExceptionIfErr(@"kExtAudioFileProperty_ClientDataFormat", err);
	
	UInt32 numPackets = kSrcBufSize;//kSegmentSize; // Frames to read (might be filelength (in frames) to read the whole file)
	UInt32 samples = numPackets;//<<1; // 2 channels (samples) per frame
	
	AudioBufferList bufList;
	bufList.mNumberBuffers = 1;
	bufList.mBuffers[0].mNumberChannels = 1; // Always 2 channels in this example
	bufList.mBuffers[0].mData = srcBuffer; // data is a pointer (float*) so our sample buffer
	bufList.mBuffers[0].mDataByteSize = samples * sizeof(Float32);
	
	UInt32 loadedPackets = numPackets;
    float progress = 0, old = 0;
    [document setProgressTask:@"reading frames..."];
    [document displayProgress:YES];
	while(1){
		err = ExtAudioFileRead(inFile, &loadedPackets, &bufList);
		if (err)
			NSLog(@"error while reading soundFile: %@", path);
			
		if(err || !loadedPackets)
			break;

		/* int N=0;
				for(i=0;i<loadedPackets;i+= N) {
					N = loadedPackets < kSamplesPerWindow ? loadedPackets : samplesPerWindow;
					//NSLog(@"N: %d", N);
					float max = getMax( &(srcBuffer[i]), N);
					[data addObject:[NSNumber numberWithDouble:max]];
					frameCount +=N;
				} */
		for(i=0;i<loadedPackets;i++){
			[data addObject:[NSNumber numberWithFloat:fabs(srcBuffer[i])]];
            frameCount++;
		}
        progress = (100.0/totalFrameCount)*frameCount;
        if(progress >= old+.2){
            old = progress;
            [document setProgress:progress];
        }
        

	}
	
	ExtAudioFileDispose(inFile);

	return [data autorelease];
}


float getMax(Float32 * buf, int N){

	float max = -23;
	for(int i=0;i<N;i++){
		float candidate = maxabs(buf[i]);
		if(candidate > max)
			max = candidate;
	}
	return max;
}

float maxabs(float x){
	return x<0?x*(-1):x;
}


-(NSString *)outputType{return @"Envelope";}
			 
	/* NSMutableArray * data = [[NSMutableArray alloc]init];
		ExtAudioFileRef inFile;
		OSStatus err;
		FSRef soundRef;
	//	int frameCount, sampleCount, size = sizeof(SInt64);
	//	AudioStreamBasicDescription inputFormat;
		int i, kSrcBufSize = 11025;
		Float32 srcBuffer[kSrcBufSize];//, progress=0;
		
		MintFile * file = (MintFile *)[self objectForPurpose:@"source"]; // is already typechecked, so the cast is ok!
		path = [file valueForKey:@"filePath"];
		
		err = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &soundRef, NULL);
		if(err) {
			[document presentAlertWithText:@"SequenceFromAudioFile: ERROR: invalid path"]; //Could not create FSRef from path
			return nil;
		}
		
		err = ExtAudioFileOpenURL(CFURLCreateFromFSRef(NULL, &soundRef), &inFile);
		
		
		
		AudioBufferList bufList;
		bufList.mNumberBuffers = 1;
		bufList.mBuffers[0].mNumberChannels = 1;
		bufList.mBuffers[0].mDataByteSize = kSrcBufSize*sizeof(Float32);
		bufList.mBuffers[0].mData = srcBuffer;
		
		UInt32 numFrames = 11025;
		err =  ExtAudioFileRead (inFile,&numFrames, &bufList);
		for(i=0;i<numFrames;i++) {
			NSLog(@"%f", srcBuffer[i]);
			[data addObject:[NSNumber numberWithDouble:srcBuffer[i]]];	//data[a] = srcBuffer[i];
		}
		return data; */

  
  
/* -(NSArray *)readSoundData{

	int i=0, channelCount, a=0;
	
//	double * data;
	NSMutableArray * data = [[NSMutableArray alloc]init];
	ExtAudioFileRef inFile;
	OSStatus err;
	FSRef soundRef;
	//SInt64 frameCount;
	SInt64 frameCount, sampleCount;
	UInt32 size = sizeof(SInt64);
	AudioStreamBasicDescription inputFormat;
	UInt32 kSrcBufSize = 100000;//32768;
	float srcBuffer[kSrcBufSize], progress=0;
	
	MintFile * file = (MintFile *)[self objectForPurpose:@"source"]; // is already typechecked, so the cast is ok!
	path = [file valueForKey:@"filePath"];
	
	err = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &soundRef, NULL);
	if(err) {
		[document presentAlertWithText:@"SequenceFromAudioFile: ERROR: invalid path"]; //Could not create FSRef from path
		return nil;
	}
	
	err = ExtAudioFileOpenURL(CFURLCreateFromFSRef(NULL, &soundRef), &inFile);//ExtAudioFileOpen (&soundRef, &inFile);
	
	err = ExtAudioFileGetProperty(inFile, kExtAudioFileProperty_FileLengthFrames, &size, &frameCount);
	if(err) {
		[document presentAlertWithText:@"SequenceFromAudioFile: ERROR: getting length did not succeed!\n"];
		return nil;
	}//else frameCount = length;
	
	size = sizeof(inputFormat);
	err = ExtAudioFileGetProperty(inFile, kExtAudioFileProperty_FileDataFormat, &size, &inputFormat);
	if(err) {
		[document presentAlertWithText:@"SequenceFromAudioFile: ERROR: can not read FileDataFormat\n"];
		return nil;
	}
	
	channelCount = inputFormat.mChannelsPerFrame;
	sr = inputFormat.mSampleRate;
	sampleCount = frameCount * channelCount;
	//data = malloc(sizeof(double)*sampleCount);
	
	//NSLog(@"%@", [NSString stringWithFormat:@"%s", inputFormat.mFormatID]);
	if(inputFormat.mFormatID == kAudioFormatLinearPCM)
		NSLog(@"linear pcm");
		
	// W H Y   A G A I N ? ?
	
	err = ExtAudioFileGetProperty(inFile, kExtAudioFileProperty_FileDataFormat, &size, &inputFormat);
	
	/////////////////////// also: check for error!
	
	// get and set the client format:
	 inputFormat.mFormatID = kAudioFormatLinearPCM;
		inputFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
		inputFormat.mBytesPerPacket = 8;	
		inputFormat.mFramesPerPacket = 1;	
		inputFormat.mBytesPerFrame = 8;	
		//inputFormat.mChannelsPerFrame = 1;	
	inputFormat.mBitsPerChannel = sizeof (float) * 8;	
	
	size = sizeof(inputFormat);
	err = ExtAudioFileSetProperty(inFile, kExtAudioFileProperty_ClientDataFormat, size, &inputFormat);
	//NSLog(@"channels: %d, framesPerPacket: %d", channelCount, framesPerPacket);
	// again: check for error!
	
	[document setProgressTask:@"Reading Sound Data..."];		
	[document displayProgress:YES];	
	
	// do the read and write - the conversion is done on and by the write call
	while (1) {	
		AudioBufferList fillBufList;
		fillBufList.mNumberBuffers = 1;
		fillBufList.mBuffers[0].mNumberChannels = 1;//channelCount;//inputFormat.mChannelsPerFrame;
		fillBufList.mBuffers[0].mDataByteSize = kSrcBufSize;
		fillBufList.mBuffers[0].mData = srcBuffer;
		
		UInt32 numFrames = (kSrcBufSize / inputFormat.mBytesPerPacket) * inputFormat.mFramesPerPacket;
		
		err = ExtAudioFileRead (inFile, &numFrames, &fillBufList); 
		//	numFrames: on input: frames to read, 
		//	on output: count of frames actually read!
		if (err || !numFrames) break;
		NSLog(@"\tread %d frames...", numFrames);
		for(i=0;i<numFrames;i++, a++) {
			NSLog(@"%f", srcBuffer[i]);
			[data addObject:[NSNumber numberWithDouble:srcBuffer[i]]];	//data[a] = srcBuffer[i];
			NSLog(@"%@", [data lastObject]);
		}
		
		progress = a/(double)frameCount*50; 
		//NSLog(@"%f", progress);
		[document setProgress:progress];
	}
	
	ExtAudioFileDispose(inFile);
	//[document displayProgress:NO];
	//NSLog(@"%@", data);
	return data;
}
 */
-(double)envelopeWindowDuration{ // in s
	//return 1.0 / sr;
	NSLog(@"EnvelopeFromAudioFile: envelopeWindowDuration, thought this were obsolete?!");
	return 0.01;
}

////////////////////////////////////////////////////////////////////////////////////////////

-(void)addSubObjectsFromData:(NSArray *)data toObject:(QuinceObject *)seq{
	[document setProgressTask:@"Creating Sequence..."];
	[document setProgress:0];
	[document displayProgress:YES];
	
	QuinceObject *sub;
	double val, max, start, duration = [self envelopeWindowDuration];
	long i,a, samplesInWindow = sr * duration;
	a=0;	
	
	for(i=0; i<[data count];i+=a){
		for(max=0, a=0;a<samplesInWindow && (a+i)<[data count];a++){ // by maximum
			val = maxabs([[data objectAtIndex:a+i]doubleValue]);
			if(val > max)
				max = val;
		}
		/* for(max=0, a=0;a<samplesInWindow && (a+i)<[data count];a++) // by average		
		 max+=[[data objectAtIndex:a+i]doubleValue];
		 
		 max/=samplesInWindow;
		 max= maxabs(max);
		 */
		
		sub = [document newObjectOfClassNamed:@"Sequence"];
		start = duration*(i/samplesInWindow);//a should not be part of this! it's ONE item per window!
		
		val = 20*log10(max);
		[sub setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
		[sub setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];
		if (val < -90)val = -90;
		[sub setValue:[NSNumber numberWithDouble:val] forKey:@"volume"];
		//[seq addSubObject:sub withUpdate:NO];
		[[seq controller] addSubObjectWithController: [sub controller] withUpdate:NO];
		[document setProgress:i/(double)[data count]*100];
	}
	[document displayProgress:NO];
	[seq updateDuration];
}

-(QuinceObject *)imageFromData:(NSArray *)data{
	sr = 44100;
	QuinceObject *quince = [document newObjectOfClassNamed:@"QuinceObject"];
	double val, max, progress, duration = [self envelopeWindowDuration];
	long i,a, samplesInWindow , w=0, y=100;
	samplesInWindow= sr * duration;
	NSLog(@"samplesInWindow: %d", samplesInWindow);
	long windowCount = [data count] / samplesInWindow + 1;
	NSBezierPath *p = [[NSBezierPath alloc]init];									
	a=0;
	NSImage * image = [[NSImage alloc] initWithSize:NSMakeSize(windowCount,  y)];
	[image lockFocus];
	[document setProgressTask:@"Writing Image Data..."];		
	
	[[NSGraphicsContext currentContext]setShouldAntialias:NO];
	
	[p moveToPoint:NSMakePoint(0, 0)];
	for(i=0; i<[data count];i+=a){
		for(max=0, a=0;a<samplesInWindow && (a+i)<[data count];a++){ // by maximum
			val = maxabs([[data objectAtIndex:a+i]doubleValue]);
			
			if(val > max)
				max = val;
		}
		
		
		/* for(max=0, a=0;a<samplesInWindow && (a+i)<[data count];a++) // by average		
		 max+=[[data objectAtIndex:a+i]doubleValue];
		 max/=samplesInWindow;
		 max= maxabs(max); */
		//
		
		/* val = 20*log10(max);
		 if(val<(-90))
		 val = -90;
		 val = val * (1.0/90.0) + 1; */
		val = max;
		
		//NSLog(@"i: %d, val: %f", i, val);
		[p lineToPoint:NSMakePoint(w, val*y)];
		w++;
		progress = w/(double)windowCount*50 + 50; 
		//NSLog(@"%f", progress);
		[document setProgress:progress];
	}
	[p lineToPoint:NSMakePoint(w-1, 0)];
	[p lineToPoint:NSMakePoint(0, 0)];
	[p closePath];
	[[NSColor blackColor]set];
	[p stroke];
	[p fill];
	[p release];
	//	[NSBezierPath strokeRect:NSMakeRect(0, 0, w-1, y)];
	[image unlockFocus];
	
	[quince setValue:image forKey:@"image"];
	[quince setValue:[NSNumber numberWithDouble:[self envelopeWindowDuration]] forKey:@"envelopeWindowDuration"];
	[document setIndeterminateProgressTask:@"Writing Image Data to File..."];
	NSData * d = [image TIFFRepresentation];
	[d writeToFile:@"/Users/max/Desktop/envelope.tiff" atomically:NO];
	
	[document displayProgress:NO];	
	[image release];
	return quince;
}








@end
