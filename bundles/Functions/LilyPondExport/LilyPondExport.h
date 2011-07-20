//
//  LilyPondExport.h
//  quince
//
//  Created by max on 3/27/10.
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

@interface LilyPondExport : Function {

	FILE * file;	
	IBOutlet NSArrayController * settingsArray;
	IBOutlet NSWindow * window;
	IBOutlet NSTextField * tempoField;
	IBOutlet NSButton * pitchesButton;
	IBOutlet NSButton * glissandoButton;    
	float outTempo;
	NSMutableArray * topKeys;
	NSMutableArray * bottomKeys;
	NSMutableString * lilly;
	NSString * path;
	QuinceObject * quince;
	NSMutableArray * events;
	NSMutableArray * grid;
	NSMutableArray * flatGrid;
	int voice;
	BOOL pitches;
    BOOL glissando;
	long initialEventsCount;
}

-(void)fillSettingsArray;
-(NSValue *)defaultIncludeForKey:(NSString *)key;
-(NSValue *)defaultPositionForKey:(NSString *)key;
-(IBAction)export:(id)sender;
-(void)sortKeys;
BOOL weWantKey(NSString * key);
-(void)generateCode;
-(void)writeHeader;
-(void)writeFooter;
-(void)setProgressWithEventsCount:(long)c;
-(NSString *)durationStringForMeasure:(int)measure times:(int)times;
-(int)fractionForMeasure:(int)measure;
-(void) createVoiceString;
-(NSString*) getTupletStartStringForMeasure:(int)measure;
-(NSString*) getTupletEndStringForMeasure:(int)measure;
-(void)fillGrid;
-(int) getIndexOfFirstEventAfterSecond:(int)second;
-(NSString *)createStringFor5RestsOfMeasure:(int)measure;
-(NSString *)createStringForRestOfMeasure:(int)measure count:(int)times;
-(NSString *)getPitchStringForEvent:(QuinceObject *)event;
-(NSString *)getPitchStringForEvent:(QuinceObject *) event glissandoStart:(BOOL)b;
-(int)getMeasureForTime:(double)start;
-(int)getLockIndexOfTime:(double)time inMeasure:(int)measure;
-(int)eventWithMeasure:(int)measure inSameSecondAfter:(double)time afterEvent:(int)index;
//-(int)createStringForEvent:(NSMutableArray *)seq start:(double)searchStart atEvent:(int)index withMeasure:(int)measure;
-(int) createStringForEventAtIndex:(int)index start:(double)searchStart withMeasure:(int)measure;
-(NSString *)glissandoTupletStartString;
-(NSString *)glissandoEndNoteForEvent:(QuinceObject *)event withMeasure:(int)measure times:(int)times;
-(NSString *) createInfoStringForEvent:(QuinceObject *)event;
-(void)quantizeMint:(QuinceObject *)candidate;
-(BOOL) numberInFlatGrid:(NSNumber *)c;
-(void)quantize;
double maxabs(double d);
-(NSString *)getStringValueOf:(id)value;
-(void)changeTempo;
@end
