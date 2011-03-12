//
//  DataFile.m
//  quince
//
//  Created by max on 3/5/10.
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

#import "DataFile.h"


@implementation DataFile

-(NSString *)getPath{
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	if([self fileTypes])
		[openPanel setAllowedFileTypes:[self fileTypes]];//[NSArray arrayWithObjects:@"aif", @"aiff", @"aifc", @"wav", @"wave", nil]];
	if([openPanel runModal] == NSOKButton){
		NSString * path = [NSString stringWithString:[[openPanel filenames] objectAtIndex:0]];
		[self setValue:path forKey:@"filePath"];
		[self setValue:[[self valueForKey:@"filePath"]lastPathComponent] forKey:@"name"];
		return path;
	}
	return nil;
}

-(BOOL)openFile{

	if([self getPath])
		return YES;
	return NO;
}

-(NSArray *)fileTypes{
	return nil;
}

-(NSString *)filePath{

	return [self valueForKey:@"filePath"];
}

@end
