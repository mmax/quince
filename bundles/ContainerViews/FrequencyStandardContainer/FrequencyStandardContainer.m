//
//  FrequencyStandardContainer.m
//  quince
//
//  Created by max on 5/30/11.
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

#import "FrequencyStandardContainer.h"


@implementation FrequencyStandardContainer

-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) 
        [self setValue:[NSNumber numberWithFloat:(frame.size.height-5)/15020] forKey:@"pixelsPerUnitY"];
    
    return self;
}

-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return [NSString stringWithString:@"frequency"];
}

-(NSString *)keyForLocationOnYAxis{
    return [NSString stringWithString:@"frequency"];
}

-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToFrequency:y];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertFrequencyToY:p];
}

-(NSNumber *)convertYToFrequency:(NSNumber *)y {
	
	//float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	float f = 20 + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
	return [NSNumber numberWithFloat: f] ;
	
}

-(NSNumber *)convertFrequencyToY:(NSNumber *)f{
	
//	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	double y = ([f doubleValue]-20)*ppy;// sizeY + 
	return [NSNumber numberWithFloat: y];
}



@end
