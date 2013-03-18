//
//  ColorByKey.m
//  quince
//
//  Created by max on 6/16/10.
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

#import "ColorByKey.h"


@implementation ColorByKey


-(ColorByKey *)init{
	
	if(self = [super init]){
		
		[NSBundle loadNibNamed:@"ColorByKey" owner:self];
	}
	return self;
}

-(BOOL)hasInterface{return YES;}

-(void)perform{

	QuinceObject * quince = [self objectForPurpose:@"source"];
	NSArray * keys = [quince allKeys];
	[keyPopUp removeAllItems];
	for(NSString * s in keys)
		[keyPopUp addItemWithTitle:s];
	[window makeKeyAndOrderFront:nil];
}

-(IBAction)color:(id)sender{
	[window orderOut:nil];
	QuinceObject * quince = [self objectForPurpose:@"source"];
	NSMutableArray * colors = [[NSMutableArray alloc]init];
	NSString * key = [keyPopUp titleOfSelectedItem];
	[quince sortByKey:key ascending:YES];
	NSArray * objects = [quince arrayWithValuesForKey:key];
	
	float alpha=1, hue;
	int x = [objects count]+1;
	
	for(int i=0;i<x;i++){
		hue = 1.0/x*i;
		[colors addObject:[NSColor colorWithDeviceHue:hue saturation:1 brightness:.85 alpha:alpha]];
	}
		
	NSArray * subs = [quince valueForKey:@"subObjects"];
	for(QuinceObject * m in subs){
	
		int index = [objects indexOfObject:[m valueForKey:key]];
		[[m controller]setValue: [colors objectAtIndex:index] forKey:@"color"];
	}
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
	[colors release];
}

@end
