//
//  ApplyValueList.m
//  quince
//
//  Created by max on 3/27/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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


#import "ApplyValueList.h"


@implementation ApplyValueList

-(ApplyValueList *)init{
	
	if(self = [super init]){
		//[NSBundle loadNibNamed:@"AVL_win" owner:self];
        [[[NSBundle alloc]init] loadNibNamed:@"AVL_win" owner:self topLevelObjects:nil];
	}
	return self;
}


-(void)perform{

	[pop removeAllItems];
	QuinceObject * tar = [self objectForPurpose:@"target"];
	NSArray * keys = [tar allKeysRecursively];
	for(NSString * s in keys){
		if(![s isEqualToString:@"date"] && ![s isEqualToString:@"offsetKeys"]&& ![s isEqualToString:@"subObjects"])
			[pop addItemWithTitle:s];
	}
	
	[[pop window] makeKeyAndOrderFront:nil];
	
}

-(IBAction)OK:(id)sender{

	DataFile * df = (DataFile *)[self objectForPurpose:@"list"];//
	NSArray * lines = [self linesFromString:[NSString stringWithContentsOfFile:[df filePath] encoding: NSASCIIStringEncoding error:nil]];
	QuinceObject * tar = [self objectForPurpose:@"target"];
	NSArray * subs = [tar valueForKey:@"subObjects"];
	int i;
	[tar sortChronologically];
	
	for(i=0;i<[subs count];i++){
	
		QuinceObject * q = [subs objectAtIndex:i];
		[q setValue:[lines objectAtIndex:i%[lines count]] forKey:[pop titleOfSelectedItem]];
	}
		
	[[pop window] orderOut:nil];
	[self setOutputObjectToObjectWithPurpose:@"target"];
	[self done];
	
}

-(NSArray *)linesFromString:(NSString *)string{

	unsigned long length = [string length];
	unsigned long paraStart = 0, paraEnd = 0, contentsEnd = 0;
	NSMutableArray *array = [NSMutableArray array];
	NSRange currentRange;
	while (paraEnd < length) {
		[string getParagraphStart:&paraStart end:&paraEnd
					  contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
		currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
		[array addObject:[string substringWithRange:currentRange]];
	}
	return array;
}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"target" forKey:@"purpose"];
	[dictA setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"list" forKey:@"purpose"];
	[dictB setValue:@"DataFile" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}


@end
