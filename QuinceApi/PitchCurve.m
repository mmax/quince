//
//  PitchCurve.m
//  quince
//
//  Created by max on 8/6/11.
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


#import "PitchCurve.h"
#import <QuinceApi/QuinceDocument.h>

@implementation PitchCurve


-(PitchCurve *)init{
    
	if((self = [super init])){
		[dictionary removeObjectForKey:@"nonStandardReadIn"];
		//[self setValue:[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1] forKey:@"color"];
	}
	return self;
}

-(QuinceObject *)initWithXMLDictionary:(NSDictionary *)xml{
    NSMutableDictionary * d = [NSMutableDictionary dictionaryWithDictionary:xml];
    
    if([xml valueForKey:@"nonStandardReadIn"]){
    
        [d removeObjectForKey:@"nonStandardReadIn"];
    }
//removeObjectForKey:@"nonStandardReadIn"];
	if((self = (PitchCurve *)[super initWithXMLDictionary:d])){ //?! dirty!
        
		//NSLog(@"Envelope: initWithXMLDictonary:");
        //retrieve envelope data
//		NSString * audioFileName = [xml valueForKey:@"audioFileName"];
//		AudioFile * af = (AudioFile *)[document objectWithValue:audioFileName forKey:@"name"];
//		if(![af isOfType:@"AudioFile"]){
//			[document presentAlertWithText:
//			 [NSString stringWithFormat:@"%@: Error trying to init with audioFile of incompatible type: %@", 
//			  [self className], [af type]]];
//		}
//		[self setValue:af forKey:@"source"];
//		[document performFunctionNamed:@"Audio2Envelope" onObject:self];
		if(![d valueForKey:@"color"])
			[self setValue:[NSColor colorWithDeviceRed:0.4 green:0.45 blue:.6 alpha:1] forKey:@"color"];
		else{
			
			[self setValue:[NSColor colorWithDeviceRed:[[[xml valueForKey:@"color"]objectAtIndex:0 ]floatValue] 
												 green:[[[xml valueForKey:@"color"]objectAtIndex:1 ]floatValue]  
												  blue:[[[xml valueForKey:@"color"]objectAtIndex:2 ]floatValue]  
												 alpha:[[[xml valueForKey:@"color"]objectAtIndex:3 ]floatValue]] 
					forKey:@"color"];
		}
//		
//		if([self valueForKey:@"windowDuration"] && [self valueForKey:@"resampled"]){
//			[[NSNotificationCenter defaultCenter]addObserver:self
//													selector:@selector(resampleAfterLoad:)
//														name:@"functionDone"
//													  object:[document functionNamed:@"Audio2Envelope"]];
//		}
        
	}
	return self;
}

-(NSArray *) pitchCurve{
    
	return [self valueForKey:@"curve"];
}

-(NSArray *) envelope{
    
	return [self pitchCurve];
}

-(void)setEnvelope:(NSArray *)array{
    
	[self setValue:array forKey:@"curve"];
}

-(void)setPitchCurve:(NSArray *)array{
    
	[self setValue:array forKey:@"curve"];
}

-(NSString *)audioFileName{
    
	return nil;
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
	
	NSArray * env = [self envelope];
	
	//NSLog(@"before Resampling: %d frames", [env count]);
	
	int envSamplesPerWindow = [[self samplesPerWindow]intValue];
	float progress=0, f, sampleRate = [[self sampleRate]floatValue];
	double candidate,y ;//y, max = -100000000;
	int x, userSamplesPerWindow = sampleRate*userWindowDuration/envSamplesPerWindow;
	
	NSMutableArray * newEnvelope = [[NSMutableArray alloc]init];
	
	//int frames = [env count]/userSamplesPerWindow;
	
	[document setProgress:progress];
	for(int i = 0;i<[env count];i+=userSamplesPerWindow){
		y=-1;
		f = i;
		progress = f/[env count]*100.0;//100.0/frames * i;
		candidate = 0;
		for(x = 0;x<userSamplesPerWindow && i+x<[env count];x++)
			candidate += [[env  objectAtIndex:i+x]doubleValue];
            
        y = candidate / x;
		[newEnvelope addObject:[NSNumber numberWithDouble:y]];
		
		[document setProgress:progress];
	}
	[document displayProgress:NO];

	[self setEnvelope:newEnvelope];
	double spw = sampleRate * userWindowDuration;
	[self setValue:[NSNumber numberWithDouble:spw] forKey:@"samplesPerWindow"];
  
	[self setValue:[NSNumber numberWithDouble:userWindowDuration] forKey:@"windowDuration"];
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"resampled"];
	[newEnvelope release];
	
}

-(double)windowDuration {
	double sr = [[self sampleRate]doubleValue];
	double spw = [[self samplesPerWindow]doubleValue];
	return spw/sr;
}

@end
