//
//  PitchContainer.m
//  quince
//
//  Created by max on 5/31/11.
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

#import "PitchContainer.h"


@implementation PitchContainer


-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return @"pitchF";
}

-(NSString *)keyForLocationOnYAxis{
    return @"pitchF";
}

-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToPitch:y];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertPitchToY:p];
}

-(NSNumber *)convertYToPitch:(NSNumber *)y {
	
	//float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	float p = ([y doubleValue]/ppy)+os;//[self minimumYValue] + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
	return [NSNumber numberWithFloat: p] ;
	
}

-(NSNumber *)convertPitchToY:(NSNumber *)f{
	
    //	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	double y = ([f doubleValue]-os)*ppy;//([f doubleValue]-[self minimumYValue])*ppy;// sizeY + 
	return [NSNumber numberWithFloat: y];
}


-(double)minimumYValue{return 16;}

-(double)maximumYValue{return 129;}


@end
