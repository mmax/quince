//
//  ImportMaxMSPCollForSingleParameter.m
//  quince
//
//  Created by max on 11/21/10.
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

#import "ImportMaxMSPCollForSingleParameter.h"


@implementation ImportMaxMSPCollForSingleParameter


-(ImportMaxMSPCollForSingleParameter *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"ILFSP_window" owner:self];
	}
	return self;
}

-(void)perform{

	[window makeKeyAndOrderFront:nil];
}


-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
}

-(IBAction)import:(id)sender{

	DataFile * df = [document openNewDataFile];
	NSScanner * scanner;
	QuinceObject * mom = [self outputObjectOfType:@"QuinceObject"];
	
	float start=0, f;
	
	NSString * fileContents = [NSString stringWithContentsOfFile:[df filePath] encoding: NSASCIIStringEncoding error:nil];
	scanner = [NSScanner scannerWithString: fileContents];
	//[scanner setCharactersToBeSkipped:cs];
	
	while(1){		
		[scanner scanUpToString:@", " intoString:nil];
		[scanner scanString:@", " intoString:nil];
		
		for(int i=1;i<[position intValue];i++)
			if(![scanner scanFloat:&f]){
				[scanner scanString:@" " intoString:nil];
				//NSLog(@"ImportMaxMSPCollForSingleParameter: error skipping float");
				break;
			}
		
		if(![scanner scanFloat:&f]){
			//NSLog(@"ImportMaxMSPCollForSingleParameter: error scanning float");
			break;
		}
		
		
		QuinceObject * q = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
		[self setDefaultParametersForObject:q];
		[q setValue:[NSNumber numberWithFloat: f] forKey:[parameterName stringValue]];
		
		if([successionBox state]==NSOnState && [durationBox state]==NSOnState && [startBox state]==NSOffState){
			[q setValue:[NSNumber numberWithDouble:start*[durationValue doubleValue]] forKey:@"start"];
			start++;
		}
		
		[[mom controller] addSubObjectWithController:[q controller] withUpdate:NO];
	}
	[[mom controller]update];

	[window orderOut:nil];
	[self done];
}



-(void)setDefaultParametersForObject:(QuinceObject *)q{
	
	if([startBox state]==NSOnState)
		[q setValue:[NSNumber numberWithDouble:[startValue doubleValue]] forKey:@"start"];
	if([durationBox state]==NSOnState)
		[q setValue:[NSNumber numberWithDouble:[durationValue doubleValue]] forKey:@"duration"];
	if([volumeBox state]==NSOnState)
		[q setValue:[NSNumber numberWithDouble:[volumeValue doubleValue]] forKey:@"volume"];
	if([frequencyBox state]==NSOnState)
		[q setValue:[NSNumber numberWithDouble:[frequencyValue doubleValue]] forKey:@"frequency"];
	if([descriptionBox state]==NSOnState)
		[q setValue:[descriptionValue stringValue] forKey:@"description"];
	if([nameBox state]==NSOnState)
		[q setValue:[nameValue stringValue] forKey:@"name"];
	if([other1Box state]==NSOnState)
		[q setValue:[other1Value stringValue] forKey:[other1ParName stringValue]];
	if([other2Box state]==NSOnState)
		[q setValue:[other2Value stringValue] forKey:[other2ParName stringValue]];
}

-(BOOL)needsInput{return NO;}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"purpose"];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"type"];
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

-(BOOL)hasInterface{return YES;}

@end
