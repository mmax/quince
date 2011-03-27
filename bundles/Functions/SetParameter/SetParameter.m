//
//  SetParameter.m
//  quince
//
//  Created by max on 9/9/10.
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

#import "SetParameter.h"


@implementation SetParameter


-(SetParameter *)init{
	
	if(self = [super init]){
		
		[NSBundle loadNibNamed:@"SetParameterWindow" owner:self];
	}
	return self;
}


-(void)perform{
	
	//NSLog(@"SetParameter:perform");
	[pamMenu removeAllItems];
	QuinceObject * q = [self objectForPurpose:@"source"];
	NSArray * keys = [q allKeysRecursively];
	for(NSString * s in keys)
		[pamMenu addItemWithTitle:s];
	
	[window makeKeyAndOrderFront:nil];
}

-(IBAction)ok:(id)sender{

	NSString * val = [valueField stringValue];
	NSString * key = [pamMenu titleOfSelectedItem];

	if([recursionBox state]==NSOnState)
		[self setParameter:key ofObject:[self objectForPurpose:@"source"] toValue:val];
	else{
		for(QuinceObject * sub in [[self objectForPurpose:@"source"]valueForKey:@"subObjects"])
			[sub setValue:val forKey:key];
	}
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[window orderOut:nil];
	[self done];
	
}

-(void)setParameter:(NSString *)key ofObject:(QuinceObject *)quince toValue:(NSString *)val{

	[quince setValue:val forKey:key];
	for(QuinceObject * sub in [quince valueForKey:@"subObjects"])
		[self setParameter:key ofObject:sub toValue:val];
	return;

}


-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
	[self done];
}
@end
