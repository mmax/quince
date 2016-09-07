//
//  Envelope.m
//  quince
//
//  Created by max on 5/6/10.
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

#import "Envelope.h"
#import <QuinceApi/AudioFile.h>
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/QuinceObject.h>

@implementation Envelope

@synthesize samples, count;

-(Envelope *)init{

	if((self = [super init])){
		[self setValue:[NSNumber numberWithBool:YES] forKey:@"nonStandardReadIn"];
		[self setValue:[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1] forKey:@"color"];
	}
	return self;
}

-(QuinceObject *)copy{
    Envelope * q = (Envelope *)[self copyWithZone:nil];
    
    long i;
    
    float * s = malloc(count * sizeof(float));
    if(!s){
        [document presentAlertWithText:@"could not allocate memory for samples"];
        return nil;
    }
    
    for ( i =0; i<count;i++){
        s[i] = samples[i];
    }
    [q setSamples:s];
    [q setCount:count];
    return q;
}

-(QuinceObject *)initWithXMLDictionary:(NSDictionary *)xml{

	if((self = (Envelope *)[super initWithXMLDictionary:xml])){ //?! dirty!
		//NSLog(@"Envelope: initWithXMLDictonary:");
	//retrieve envelope data
		NSString * audioFileName = [xml valueForKey:@"audioFileName"];
        if(audioFileName){
            AudioFile * af = (AudioFile *)[document objectWithValue:audioFileName forKey:@"name"];
            if(![af isOfType:@"AudioFile"]){
                return nil;
                [document presentAlertWithText:
                 [NSString stringWithFormat:@"%@: Error trying to init with audioFile of incompatible type: %@", 
                  [self className], [af type]]];
            }
            [self setValue:af forKey:@"source"];
            [document performFunctionNamed:@"Audio2Envelope" onObject:self];
        }
		if(![xml valueForKey:@"color"])
			[self setValue:[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1] forKey:@"color"];
		else{
			
			[self setValue:[NSColor colorWithDeviceRed:[[[xml valueForKey:@"color"]objectAtIndex:0 ]floatValue] 
												 green:[[[xml valueForKey:@"color"]objectAtIndex:1 ]floatValue]  
												  blue:[[[xml valueForKey:@"color"]objectAtIndex:2 ]floatValue]  
												 alpha:[[[xml valueForKey:@"color"]objectAtIndex:3 ]floatValue]] 
					forKey:@"color"];
		}
		
		if([self valueForKey:@"windowDuration"] && [self valueForKey:@"resampled"]){
			[[NSNotificationCenter defaultCenter]addObserver:self
													selector:@selector(resampleAfterLoad:)
														name:@"functionDone"
													  object:[document functionNamed:@"Audio2Envelope"]];
		}

	}
	return self;
}

-(NSArray *) envelope{
    if([self isChild])
        return [(Envelope *)[self superObject] envelope];
    
	return [self valueForKey:@"envelope"];
}

-(void)setEnvelope:(NSArray *)array{

	[self setValue:array forKey:@"envelope"];
}

-(NSNumber *)sampleRate{
    if([self isChild])
        return [(Envelope *)[self superObject]sampleRate];
    
	return [self valueForKey:@"sampleRate"];
}

-(NSNumber *)duration {
    if([self isChild])
        return [(Envelope *)[self superObject]duration];
	return [self valueForKey:@"duration"];
}

-(NSNumber *)samplesPerWindow{
    if([self isChild])
        return [(Envelope *)[self superObject]samplesPerWindow];
	return [self valueForKey:@"samplesPerWindow"];
}

-(NSString *)audioFileName{
    if([self isChild])
        return [(Envelope *)[self superObject]audioFileName];
	return [self valueForKey:@"audioFileName"];
}

-(NSDictionary *)xmlDictionary{

//	return [super xmlDictionary];
	
	NSMutableDictionary * dict = [super xmlDictionary];
	[dict removeObjectForKey:@"envelope"];
	[dict removeObjectForKey:@"source"];
	

	NSColor * c = [self valueForKey:@"color"];
	if(c){
		NSMutableArray * rgb = [[NSMutableArray alloc]init];
		[rgb addObject:[NSNumber numberWithFloat:[c redComponent]]];
		[rgb addObject:[NSNumber numberWithFloat:[c greenComponent]]];
		[rgb addObject:[NSNumber numberWithFloat:[c blueComponent]]];
		[rgb addObject:[NSNumber numberWithFloat:[c alphaComponent]]];
		[dict setValue:rgb forKey:@"color"];
	 }

	
	return dict;
	
}

-(void)resampleForWindowDuration:(double)userWindowDuration{
	
	[document setProgressTask:@"resampling envelope..."];
	[document displayProgress:YES];
	
	//NSArray * env = [self envelope];
    NSLog(@"Envelope: before resample: count: %ld", [self count]);
    if(samples == NULL || count == 0) return;
	//NSLog(@"before Resampling: %d frames", [env count]);
	
    float * newSamples = malloc(sizeof(float)*count);
    if(!newSamples){
        [document presentAlertWithText:@"could not allocate memory for samples"];
        return;
    }
    
	int envSamplesPerWindow = [[self samplesPerWindow]intValue];
	float progress=0, f, sampleRate = [[self sampleRate]floatValue];
	float candidate, y, max = -100000000;
	int userSamplesPerWindow = sampleRate*userWindowDuration/envSamplesPerWindow;
	long newSize = 0;
	//NSMutableArray * newEnvelope = [[NSMutableArray alloc]init];
	
	//int frames = [env count]/userSamplesPerWindow;
	
	[document setProgress:progress];
	for(int i = 0;i<count;i+=userSamplesPerWindow){
		y=-1;
		f = i;
		progress = f/count*100.0;//100.0/frames * i;
		
		for(int x = 0;x<userSamplesPerWindow && i+x<count;x++){
			
			candidate = samples[i+x];
			if (candidate > y) 
				y = candidate;
		}
		if(y>max)max=y;
		newSamples[newSize++] = y;//[newEnvelope addObject:[NSNumber numberWithDouble:y]];
		
		[document setProgress:progress];
	}
	[document displayProgress:NO];
	//NSLog(@"after Resampling: %d frames", [newEnvelope count]);
	//NSLog(@"max: %f", max);
	//NSLog(@"%@", newEnvelope);
	//[self setEnvelope:newEnvelope];
	double spw = sampleRate * userWindowDuration;
	[self setValue:[NSNumber numberWithDouble:spw] forKey:@"samplesPerWindow"];
    free(samples);
    samples = newSamples;
    count = newSize;
    NSLog(@"Envelope: after resample: new count: %ld", count);
//	
	//double dur = [newEnvelope count] * userWindowDuration;
	//NSLog(@"after resampling: %d frames, frameDur : %f, envelope duration: %f", [newEnvelope count], userWindowDuration, dur);
	
	[self setValue:[NSNumber numberWithDouble:userWindowDuration] forKey:@"windowDuration"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"resampled"];
    [self setValue:[NSNumber numberWithInt:0] forKey:@"clone"];
	//[newEnvelope release];
	
}

-(Envelope *)resampleCopyForWindowDuration:(double)windowDuration{

	Envelope * e = [self copy];
    NSLog(@"Envelope: after copy: new count: %ld", [e count]);

	[e resampleForWindowDuration:windowDuration];
	return e;
}

-(void)resampleAfterLoad:(NSNotification *)not{

	[self resampleForWindowDuration:[[self valueForKey:@"windowDuration"]doubleValue]];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"functionDone" object:[document functionNamed:@"EnvelopeFromAudioFile"]];
}

-(double)windowDuration {
	double sr = [[self sampleRate]doubleValue];
	double spw = [[self samplesPerWindow]doubleValue];
	return spw/sr;
}


-(void)dealloc{
	if(samples)
        free(samples);
    
	[dictionary release];
	[super dealloc];	
}

@end
