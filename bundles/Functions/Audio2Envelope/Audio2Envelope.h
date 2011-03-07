//
//  Audio2Envelope.h
//  quince
//
//  Created by max on 3/5/10.
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
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <QuinceApi/QuinceDocument.h>

//#define kSamplesPerWindow 350
#define kSamplesPerWindow 1
@class Sequence, AudioFile;

@interface Audio2Envelope : Function {

	float sr;
	NSString * path;
	long frameCount;
}

-(BOOL)checkObject:(QuinceObject *)quince ofType:(NSString *)type;
-(NSArray *)readSoundData;
-(double)envelopeWindowDuration; // in s
float getMax(Float32 * buf, int N);
float maxabs(float x);

//-(QuinceObject *)imageFromData:(NSArray *)data;
//-(void)addSubObjectsFromData:(NSArray *)data toObject:(QuinceObject *)seq;
//-(Sequence *)createSeqFromData:(NSArray *)data;
@end
