//
//  RemoveGlissDown.m
//  quince
//
//  Created by Maximilian Marcoll on 5/21/13.
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


#import "RemoveGlissDown.h"

@implementation RemoveGlissDown


-(void)perform{
	
	QuinceObject * q, * mother = [self objectForPurpose:@"source"];
    QuinceObject * result = [self outputObjectOfType:@"QuinceObject"];

	[mother sortChronologically];
    
    for(QuinceObject * sub in [mother valueForKey:@"subObjects"]){
        if([[sub valueForKey:@"glissandoDirection"]intValue] == 1 || ![sub valueForKey:@"glissandoDirection"]){
            q = [sub copyWithZone:nil];
            [[result controller] addSubObjectWithController:[q controller] withUpdate:NO];
        }
    }
        
    [[result controller] update];
	[[result controller] setValue:[NSString stringWithFormat:@"%@_RmvGlssDwn", [mother valueForKey:@"name"]] forKeyPath:@"selection.name"];  
	
    
	[self done];
}


@end
