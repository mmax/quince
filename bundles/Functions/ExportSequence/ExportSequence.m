//
//  ExportSequence.m
//  quince
//
//  Created by Maximilian Marcoll on 4/23/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
//

#import "ExportSequence.h"

@implementation ExportSequence

-(void)perform{
    
    QuinceObject * q = [self objectForPurpose:@"source"];
    NSDictionary * d = [q xmlDictionary];
    
    NSSavePanel* sp = [NSSavePanel savePanel];
    NSArray * types = [NSArray arrayWithObject:@"xml"];
    [sp setAllowedFileTypes:types];
	[sp setTitle:@"Save Sequence"];

    int status = [sp runModal];
	if(status==NSFileHandlingPanelOKButton){

		if(![d writeToURL:[sp URL] atomically:NO])
			[document presentAlertWithText:[NSString stringWithFormat:@"ExportSequence: save operation failed!"]];
	}
    
	[document displayProgress:NO];
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];

}

@end
