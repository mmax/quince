//
//  ExportDescriptionListing.m
//  quince
//
//  Created by max on 10/20/10.
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

#import "ExportDescriptionListing.h"


@implementation ExportDescriptionListing


-(void)perform{


	NSSavePanel* sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"txt"];
	[sp setTitle:@"Save Description Listing"];
#ifdef MAC_OS_X_VERSION_10_6
	[sp setNameFieldStringValue:@"filenamedoesntmatter.txt"];
#endif

	
	int status = [sp runModal];
	NSError * error;
	if(status==NSFileHandlingPanelOKButton){
		//NSString * path = [[sp URL]path];

		NSString * list = [self generateListing];
		if(![list writeToURL:[sp URL] atomically:NO encoding:NSASCIIStringEncoding error:&error])
			[document presentAlertWithText:[NSString stringWithFormat:@"ExportDescriptionListing: save operation failed: %@", error]];
	}
	[document displayProgress:NO];
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
	
}

-(NSString *)generateListing{

	QuinceObject * quince = [[self objectForPurpose:@"source"]copy];
	[quince sortByKey:@"description" ascending:YES];
	NSArray * subs = [quince valueForKey:@"subObjects"];
	
	NSMutableArray * des = [[NSMutableArray alloc]init];
	for(QuinceObject * q in subs){
		NSString * s = [q valueForKey:@"description"];
		
		if(![quince isString:s inArrayOfStrings:des])
			[des addObject:s];

	}
	
	NSMutableString * list = [[NSMutableString alloc]init];
	for(NSString * s in des)
		[list appendFormat:@"%@\n", s];
	
	[quince release];
	[des release];
	return [list autorelease];
	
}

		 
		 

@end
