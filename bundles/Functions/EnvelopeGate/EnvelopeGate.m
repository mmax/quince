//
//  EnvelopeGate.m
//  quince
//
//  Created by max on 6/21/10.
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

#import "EnvelopeGate.h"


@implementation EnvelopeGate

-(EnvelopeGate *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"EnvelopeGateWindow" owner:self];
	}
	return self;
}

-(void)perform{

	[window makeKeyAndOrderFront:nil];
}


-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
}

-(IBAction)gate:(id)sender{
	
	double threshold = [textField doubleValue];
	[window orderOut:nil];
	Envelope * envOrig = (Envelope*)[self objectForPurpose:@"envelope"];
    Envelope * env = [[document controllerForCopyOfQuinceObjectController:[envOrig controller] inPool:YES]content];//(Envelope *)[self outputObjectOfType:@"Envelope"];
    
    
    
	NSArray * envArray = [envOrig envelope];
	NSMutableArray * newEnv = [[NSMutableArray alloc]init];
	for(NSNumber * frame in envArray){
		double val = 0.00001;
		if (20.0*log10([frame doubleValue]) > threshold) {
			val = [frame doubleValue];
		}
		[newEnv addObject:[NSNumber numberWithDouble:val]];
	}
	[env setEnvelope:newEnv];
//    [env setValue: [envOrig valueForKey:@"sampleRate"] forKey:@"sampleRate"];
//    [env setValue: [envOrig valueForKey:@"duration"] forKey:@"duration"];    
//    [env setValue: [envOrig valueForKey:@"samplesPerWindow"] forKey:@"samplesPerWindow"];        
//    [env setValue: [envOrig valueForKey:@"audioFileName"] forKey:@"audioFileName"];        
    
	[newEnv release];
	//[self setOutputObjectToObjectWithPurpose:@"envelope"];
    [[env controller] setValue:[NSString stringWithFormat:@"%@_EnvGt", [env valueForKey:@"name"]] forKeyPath:@"selection.name"];
    [self setValue:env forKey:@"output"];
	[self done];

}


-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"envelope" forKey:@"purpose"];
	[dictA setValue:@"Envelope" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

@end
