//
//  ApplyEnvelope.m
//  quince
//
//  Created by max on 5/23/10.
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

#import "ApplyEnvelope.h"


@implementation ApplyEnvelope

-(ApplyEnvelope *)init{

	if(self = [super init]){
	
		[NSBundle loadNibNamed:@"ApplyEnvelopeWindow" owner:self];
	}
	return self;
}

-(void)perform{
	quince = [[self objectForPurpose:@"target"]retain];
	env = (Envelope *)[[self objectForPurpose:@"envelope"]retain];
	if(!env)NSLog(@"%@: ERROR: no envelope!", [self className]);
	if(!quince)NSLog(@"%@: ERROR: no quince!", [self className]);
	
	double envWindowDuration = [env windowDuration];
	if(envWindowDuration < 0.005)
		[window makeKeyAndOrderFront:nil];
	else
		[self setValue:[NSNumber numberWithDouble:envWindowDuration] forKey:@"windowDuration"];
}

-(IBAction)apply:(id)sender{
	
	double userWindowDuration;
	
	if([self valueForKey:@"windowDuration"])
		userWindowDuration= [[self valueForKey:@"windowDuration"]doubleValue];
	else {
		userWindowDuration = [windowDurationField doubleValue];
		[window orderOut:nil];
	}
	
	if(!env)NSLog(@"%@: ERROR: no envelope!", [self className]);
	if(!quince)NSLog(@"%@: ERROR: no quince!", [self className]);
	double duration = [[env duration]doubleValue];
	//NSArray * envArray = [self resampleEnvelopeForDuration:userWindowDuration];
	NSArray * envArray = [[env resampleCopyForWindowDuration:userWindowDuration]envelope];
	[document setIndeterminateProgressTask:@"setting volume values..."];
	[document displayProgress:YES];
	for(QuinceObject * m in [quince valueForKey:@"subObjects"]){
		
		double time = [[m valueForKey:@"start"]doubleValue];
		if(time < duration){
			int windowsPerSecond = 1.0/userWindowDuration;
			int index = time*windowsPerSecond;
			double envVal = [[envArray objectAtIndex:index]doubleValue];
			[m setValue:[NSNumber numberWithDouble:20*log10(envVal)] forKey:@"volume"];
		}
	}
	[document displayProgress:NO];
	//NSLog(@"%@: apply: ready for output...", [self className]);
	[self setOutputObjectToObjectWithPurpose:@"target"];
	[self done];
	[envArray release];
}

-(void)reset{

	if(env){[env release];env = nil;}
	if(quince){[quince release]; quince = nil;}
	[dictionary removeObjectForKey:@"windowDuration"];
	[super reset];
}


/* -(NSArray *)resampleEnvelopeForDuration:(double)userWindowDuration{
	
	[document setIndeterminateProgressTask:@"resampling the envelope..."];
	[document displayProgress:YES];
	int envSamplesPerWindow = [[env samplesPerWindow]intValue];
	int sampleRate = [[env sampleRate]intValue];
	double y;
	int userSamplesPerWindow = sampleRate*userWindowDuration/envSamplesPerWindow;
	
	NSMutableArray * envelope = [[NSMutableArray alloc]init];
	for(int i = 0;i<[[env envelope]count];i+=userSamplesPerWindow){
		y=-1;
		
		for(int x = 0;x<userSamplesPerWindow && i+x<[[env envelope]count];x++){
		
			double candidate = [[[env envelope]objectAtIndex:i+x]doubleValue];
			if (candidate > y) 
				y = candidate;
		}
		[envelope addObject:[NSNumber numberWithDouble:y]];
	}
	return [envelope autorelease];
}
 */

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"target" forKey:@"purpose"];
	[dictA setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"envelope" forKey:@"purpose"];
	[dictB setValue:@"Envelope" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}

@end
