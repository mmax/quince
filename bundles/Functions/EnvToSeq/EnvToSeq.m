//
//  EnvToSeq.m
//  quince
//
//  Created by max on 8/31/10.
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

#import "EnvToSeq.h"


@implementation EnvToSeq


-(EnvToSeq *)init{
	
	if(self = [super init]){
		//[NSBundle loadNibNamed:@"EnvToSeqWindow" owner:self];
        [[[NSBundle alloc]init] loadNibNamed:@"EnvToSeqWindow" owner:self topLevelObjects:nil];
	}
	return self;
}


-(IBAction)ok:(id)sender{

	defaultDuration = [defaultDurationTextField doubleValue];
	detectionPercentage = [detectionToleranceTextField doubleValue];
	windowSize =[windowSizeTextField doubleValue]*0.001;
	[window orderOut:nil];
	[self detect];
	[self done];
}

-(IBAction)cancel:(id)sender{
	[window orderOut:nil];
	[self done];
}

-(void)perform{
	
	[window makeKeyAndOrderFront:nil];
}


-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"source" forKey:@"purpose"];
	[dictA setValue:@"Envelope" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

-(void)detect{

	Envelope * env = (Envelope *)[self objectForPurpose:@"source"];
	if([env windowDuration]<windowSize){
		env = [env resampleCopyForWindowDuration:windowSize];
	}
	
	NSLog(@"%@", [env valueForKey:@"name"]);
	
	QuinceObject * mom = [self outputObjectOfType:@"QuinceObject"];//[document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
	double windowDuration = [env windowDuration];
	//NSArray * enVal = [env envelope];
    float * envelope = [env samples];
    long count = [env count];
    NSLog(@"count: %ld", count);
	float f;
	double start, a, b, factor = 100.0/detectionPercentage, progress=0;
	//NSLog(@"\ndetection: %d values to check\nenv _ windowDuration:%f \n\nfactor: %f", [enVal count], windowDuration, factor);
	[document setProgressTask:@"detecting..."];
	[document setProgress:progress];
	[document displayProgress:YES];
	QuinceObject * q;

	//for(int i=1; i<[enVal count];i++){
    for(int i=1; i<count;i++){
		f = i;
		progress = (f/count) * 100.0;
		[document setProgress:progress];
		a = envelope[i-1];//[[enVal objectAtIndex:i-1]doubleValue];
		b = envelope[i];//[[enVal objectAtIndex:i]doubleValue];
		//NSLog(@"a: %f, b:%f, a*factor = %f", a, b, a*factor);
		if(a*factor <= b){
			//NSLog(@"\t\t\t\tHIT!");
			start = i*windowDuration;
			q = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
			[q setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
			[q setValue:[NSNumber numberWithDouble:defaultDuration] forKey:@"duration"];
			[q setValue:[NSNumber numberWithDouble:20*log10(b)] forKey:@"volume"];
			[[mom controller]addSubObjectWithController:[q controller] withUpdate:NO];
			[q autorelease];
		}
	}
	
	[mom setValue:@"Env2Seq" forKey:@"name"];
	[[mom controller]update];
	[document displayProgress:NO];
}

-(BOOL)hasInterface{return YES;}

@end
