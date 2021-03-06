//
//  JoinByFrequency.h
//  quince
//
//  Created by max on 11/18/10.
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
#import <Cocoa/Cocoa.h>
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceDocument.h>


@interface JoinByFrequency : Function {
	
	IBOutlet NSTextField * percentageField;
    IBOutlet NSTextField * timeGapField;
	IBOutlet NSPanel * window;
    NSArray * subs;
	float maxCent;
    float maxTimeGap;
	QuinceObject * mom;
	QuinceObject * source;
    int inIndex, outIndex;
    
	
}

-(IBAction)cancel:(id)sender;
-(IBAction)go:(id)sender;

//-(void)joinNextFrom:(int)index into:(QuinceObject *)j;
-(void)joinQuinceAtInIndexIntoQuinceAtOutIndex;
-(void)join;
-(BOOL)_check;

@end
