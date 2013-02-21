//
//  CreateGridSequence.h
//  quince
//
//  Created by max on 3/25/10.
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
#import <QuinceApi/ContainerView.h>
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/ChildView.h>
#import "GridCreationView.h"

@interface CreateGridSequence : Function {

	IBOutlet GridCreationView * gridView;
	IBOutlet NSWindow * window;
	
	IBOutlet NSTextField * newMeasureTextField;
	IBOutlet NSPopUpButton * newMeasureIndexPopUp;

	IBOutlet NSButton * checkBox1;
	IBOutlet NSButton * checkBox2;
	IBOutlet NSButton * checkBox3;
	IBOutlet NSButton * checkBox4;
	IBOutlet NSButton * checkBox5;
	IBOutlet NSButton * checkBox6;
	IBOutlet NSButton * checkBox7;
	IBOutlet NSButton * checkBox8;
	
	IBOutlet NSButton * repeatBox;
    
    
    IBOutlet NSTextField * temperedCentField;
    IBOutlet NSTextField * temperedAField;
    
}

-(IBAction)changeMeasure:(id)sender;
-(IBAction)toggleMeasure:(id)sender;
-(IBAction)doneTime:(id)sender;
-(IBAction)donePitchTempered:(id)sender;

-(IBAction)cancelTime:(id)sender;
-(void)cancel;
-(NSString *)descriptionStringwithMeasures:(NSArray *)measures;
-(BOOL)newLock:(NSNumber *)lock inGrid:(QuinceObject *)quince;
@end
