//
//  QuinceAppDelegate.m
//  quince
//
//  Created by max on 8/15/11.
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

#import "QuinceAppDelegate.h"


@implementation QuinceAppDelegate


- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender{

    return NO;
	//
    id documentController = [NSDocumentController sharedDocumentController];
	
	// Reopen last document
	for (NSURL *url in [documentController recentDocumentURLs]) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
			//if([documentController openDocumentWithContentsOfURL:url display:YES error:nil])
            if([documentController openDocumentWithContentsOfURL:url display:YES completionHandler:<#^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error)completionHandler#>])
				return NO;
		}
	}
	return YES;
}


@end
