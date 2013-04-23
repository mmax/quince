//
//  ImportSequence.m
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

#import "ImportSequence.h"

@implementation ImportSequence

-(void)perform{

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xml", @"txt", nil]];
    
	if([openPanel runModal] == NSOKButton){
        NSArray * us = [openPanel URLs];
        NSURL * u = [us objectAtIndex:0];

        NSDictionary * d = [NSDictionary dictionaryWithContentsOfURL:u];

        
//        QuinceObject * q = [self outputObjectOfType:@"QuinceObject"];
//        [q initWithXMLDictionary:d];      

        QuinceObjectController * mc = [document controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO];
        [mc initContentWithXMLDictionary:d];
        [document addObjectToObjectPool:[mc content]];
    }

    [self done];


}
    
-(BOOL)needsInput{return NO;} 
    
    
-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"purpose"];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"type"];
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}



@end
