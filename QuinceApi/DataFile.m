//
//  DataFile.m
//  MINT
//
//  Created by max on 6/16/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
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
