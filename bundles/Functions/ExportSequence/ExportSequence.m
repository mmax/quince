//
//  ExportSequence.m
//  quince
//
//  Created by Maximilian Marcoll on 4/23/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
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

#import "ExportSequence.h"

@implementation ExportSequence

-(void)perform{
    
    QuinceObject * q = [self objectForPurpose:@"source"];
    NSDictionary * d = [q xmlDictionary];
    
    NSSavePanel* sp = [NSSavePanel savePanel];
    NSArray * types = [NSArray arrayWithObject:@"xml"];
    [sp setAllowedFileTypes:types];
	[sp setTitle:@"Save Sequence"];

    long status = [sp runModal];
	if(status==NSFileHandlingPanelOKButton){

		if(![d writeToURL:[sp URL] atomically:NO])
			[document presentAlertWithText:[NSString stringWithFormat:@"ExportSequence: save operation failed!"]];
	}
    
	[document displayProgress:NO];
	
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];

}

@end
