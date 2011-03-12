//
//  ImportMaxMSPCollForSingleParameter.h
//  quince
//
//  Created by max on 11/21/10.
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
#import <QuinceApi/DataFile.h>
#import <QuinceApi/QuinceDocument.h>

@interface ImportMaxMSPCollForSingleParameter : Function {

	IBOutlet NSPanel * window;
	IBOutlet NSTextField * parameterName;
	IBOutlet NSTextField * startValue;
	IBOutlet NSTextField * durationValue;
	IBOutlet NSTextField * volumeValue;
	IBOutlet NSTextField * frequencyValue;
	IBOutlet NSTextField * descriptionValue;
	IBOutlet NSTextField * nameValue;
	IBOutlet NSTextField * other1ParName;
	IBOutlet NSTextField * other1Value;
	IBOutlet NSTextField * other2ParName;
	IBOutlet NSTextField * other2Value;
	IBOutlet NSTextField * position;
	
	IBOutlet NSButton * startBox;
	IBOutlet NSButton * durationBox;
	IBOutlet NSButton * volumeBox;
	IBOutlet NSButton * frequencyBox;
	IBOutlet NSButton * descriptionBox;
	IBOutlet NSButton * nameBox;
	IBOutlet NSButton * other1Box;
	IBOutlet NSButton * other2Box;
	IBOutlet NSButton * successionBox;

}

-(IBAction) import:(id)sender;
-(IBAction) cancel:(id)sender;
-(void)setDefaultParametersForObject:(QuinceObject *)q;
@end
