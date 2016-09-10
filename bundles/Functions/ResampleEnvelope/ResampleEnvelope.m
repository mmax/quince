//
//  ResampleEnvelope.m
//  quince
//
//  Created by max on 6/20/10.
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

#import "ResampleEnvelope.h"


@implementation ResampleEnvelope

-(ResampleEnvelope *)init{

	if((self = [super init])){
		//[NSBundle loadNibNamed:@"ResampleEnvelopeWindow" owner:self];
        [[[NSBundle alloc]init] loadNibNamed:@"ResampleEnvelopeWindow" owner:self topLevelObjects:nil];
	}
	return self;
}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"envelope" forKey:@"purpose"];
	[dictA setValue:@"Envelope" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

-(void)perform{

	[window makeKeyAndOrderFront:nil];
}


-(IBAction)resample:(id)sender{

	Envelope * e = (Envelope *)[self objectForPurpose:@"envelope"];
	double duration = [textField doubleValue];
	[window orderOut:nil];
	[e resampleForWindowDuration: duration];
	
	[self setOutputObjectToObjectWithPurpose:@"envelope"];
	[self done];
}

-(IBAction)cancel:(id)sender{
	
	[window orderOut:nil];
	[self done];
}

-(BOOL)hasInterface{return YES;}

@end
