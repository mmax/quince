//
//  EventInterceptView.h
//  quince
//
//  Created by max on 4/10/10.
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


@class StripController;

@interface EventInterceptView : NSView {
	BOOL active;
	float	cursorX;
	StripController * stripController;
	NSMutableArray * volumeGuides; // array containing dictionaries with path, colour, string, point (value)
    NSMutableDictionary * dictionary;
}

@property (assign) StripController * stripController;
-(void) setActive:(BOOL)b;

-(void)drawCursorForX:(double)x;
-(void)computeGuides;
-(void)computeVolumeGuides;
-(void)computeFrequencyGuides;
-(void)computePitchGuides;
-(void)computeCentGuides;
-(void)drawGuidesInRect:(NSRect) r;
-(void)setValue:(id)aValue forKey:(NSString *)aKey;
-(id)valueForKey:(NSString *)key;
-(id)valueForKeyPath:(NSString *)keyPath;
-(void)removeObjectForKey:(NSString *)key;
-(NSMutableDictionary *)dictionary;
-(void)prepareGuides;
-(void)removeGuideTextFields;
@end
