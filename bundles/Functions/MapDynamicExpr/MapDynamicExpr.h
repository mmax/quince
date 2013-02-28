//
//  MapDynamicExpr.h
//  quince
//
//  Created by max on 9/2/10.
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

@interface MapDynamicExpr : Function {

	IBOutlet NSPanel * window;
	
	IBOutlet NSTextField * ffffField;
	IBOutlet NSTextField * fffField;
	IBOutlet NSTextField * ffField;
	IBOutlet NSTextField * fField;
	IBOutlet NSTextField * mfField;
	IBOutlet NSTextField * mpField;
	IBOutlet NSTextField * pField;
	IBOutlet NSTextField * ppField;
	IBOutlet NSTextField * pppField;
	IBOutlet NSTextField * ppppField;
	
	IBOutlet NSButton * ffffCheckBox;
	IBOutlet NSButton * fffCheckBox;
	IBOutlet NSButton * ffCheckBox;
	IBOutlet NSButton * fCheckBox;
	IBOutlet NSButton * mfCheckBox;
	IBOutlet NSButton * mpCheckBox;
	IBOutlet NSButton * pCheckBox;
	IBOutlet NSButton * ppCheckBox;
	IBOutlet NSButton * pppCheckBox;
	IBOutlet NSButton * ppppCheckBox;
	IBOutlet NSButton * pppppCheckBox;
	
	IBOutlet NSSlider * slider;
    IBOutlet NSSlider * offsetSlider;
	
	NSMutableArray * activeFields;
	NSMutableArray * activeBoxes;
}

-(IBAction)map:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)all:(id)sender;
-(IBAction)none:(id)sender;	
-(void)mapQuince:(QuinceObject *)q;
-(IBAction)changeDistribution:(id)sender;

@end
