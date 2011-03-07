//
//  RemoveParameter.m
//  quince
//
//  Created by max on 7/22/10.
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

#import "RemoveParameter.h"


@implementation RemoveParameter

-(RemoveParameter *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"RemoveParameterWindow" owner:self];
	}
	return self;
}


-(void)perform{

	[pop removeAllItems];
	QuinceObject * source = [self objectForPurpose:@"source"];
	NSArray * keys = [source allKeysRecursively];
	for(NSString * s in keys)
		[pop addItemWithTitle:s];
	
	[window makeKeyAndOrderFront:nil];
}

-(IBAction)removeParameter:(id)sender{
	
	NSString * key = [pop titleOfSelectedItem];
	[window orderOut:nil];
	
	QuinceObject * source = [self objectForPurpose:@"source"];
	[source recursivelyRemoveObjectForKey:key];
	[document updateObjectInspector]; // just in case....

}

-(IBAction) cancel:(id)sender{
	
	[window orderOut:nil];
}

@end
