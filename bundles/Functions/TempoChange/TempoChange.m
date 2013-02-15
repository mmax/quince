//
//  TempoChange.m
//  quince
//
//  Created by max on 9/3/10.
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

#import "TempoChange.h"


@implementation TempoChange

-(TempoChange *)init{
	
	if((self = [super init])){
		[NSBundle loadNibNamed:@"TempoChangeWindow" owner:self];
	}
	return self;
}


-(void)perform{

	QuinceObject * q = [self objectForPurpose:@"source"];
	float tempo = [[q valueForKey:@"tempo"]floatValue];
	if(!tempo)
		tempo = 60;
	[sourceTempoField setFloatValue:tempo];
	[targetTempoField setFloatValue:120];
	
	[window makeKeyAndOrderFront:nil];
}

-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
	[self done];
}

-(IBAction)changeTempo:(id)sender{

	double targetTempo = [targetTempoField doubleValue];
	double sourceTempo = [sourceTempoField doubleValue];
	
	double factor = sourceTempo / targetTempo;

    if ([preserveTimingCheckBox state] == NSOnState) {
        factor = targetTempo / sourceTempo;
    }
	
	QuinceObject * source = [self objectForPurpose:@"source"];
	QuinceObject * c = [self outputObjectOfType:[source type]];
	
	for(QuinceObject * q in [source valueForKey:@"subObjects"]){
		QuinceObject * copy = [[document controllerForCopyOfQuinceObjectController:[q controller] inPool:NO]content];
		[self changeTempoOfQuince:copy byFactor:factor];
		[[c controller]addSubObjectWithController:[copy controller] withUpdate:NO];
	}
	
	[c setValue:[NSString stringWithFormat:@"%@_t%@", [source valueForKey:@"name"], [targetTempoField stringValue]] forKey:@"name"];
	[c setValue:[NSNumber numberWithDouble:targetTempo] forKey:@"tempo"];
	[[c controller ]update];
	[window orderOut:nil];
	[self done];
}

-(void)changeTempoOfQuince:(QuinceObject *)q byFactor:(double)factor{
	
	for(QuinceObject * sub in [q valueForKey:@"subObjects"])
		[self changeTempoOfQuince:sub byFactor:factor];

	double start = [[q valueForKey:@"start"]doubleValue]*factor;
	double duration = [[q valueForKey:@"duration"]doubleValue]*factor;
	[q setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
	[q setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];	
}

@end
