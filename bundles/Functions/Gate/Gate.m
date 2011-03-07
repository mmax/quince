//
//  Gate.m
//  quince
//
//  Created by max on 10/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

#import "Gate.h"


@implementation Gate


-(Gate *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"GateWindow" owner:self];
	}
	return self;
}



-(void)perform{

	
	[window makeKeyAndOrderFront:nil];

}

-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
}

-(IBAction)doGate:(id)sender{

	QuinceObject * result = [self outputObjectOfType:@"QuinceObject"];
	
	BOOL inverted = [invertButton state] == NSOnState ? YES : NO;
	float threshold = [threshField floatValue];
	
	QuinceObject * q = [self objectForPurpose:@"source"];
	//NSMutableSet * remove = [[NSMutableSet alloc]init];
	
	for(QuinceObject * sub in [q valueForKey:@"subObjects"]){
	
		if(inverted){
			if ([[sub valueForKey:@"volume"]floatValue]<threshold)
				[result addSubObject:sub withUpdate:NO];
				//[remove addObject:sub];

		}
		else{
			
			if ([[sub valueForKey:@"volume"]floatValue]>threshold)
				[result addSubObject:sub withUpdate:NO];
				//[remove addObject:sub];
		}
	
	}
	
	[[result controller] update];
	[[result controller] setValue:[NSString stringWithFormat:@"%@_gated", [q valueForKey:@"name"]] forKeyPath:@"selection.name"];
	
	/* for(QuinceObject * sub in remove){
		
			[[q controller] removeSubObjectWithController:[sub controller] withUpdate:NO];
		} */

	
	//[self setOutputObjectToObjectWithPurpose:@"source"];
	[window orderOut:nil];
	
	[self done];

}


@end
