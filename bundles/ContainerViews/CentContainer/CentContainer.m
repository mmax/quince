//
//  CentContainer.m
//  quince
//
//  Created by max on 7/12/11.
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


#import "CentContainer.h"


@implementation CentContainer


-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) 
        [self setValue:[NSNumber numberWithFloat:(frame.size.height-kDefaultYAxisHeadRoom)/100] forKey:@"pixelsPerUnitY"];
    
    return self;
}

-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return @"cent";
}

-(NSString *)keyForLocationOnYAxis{
    return @"cent";
}

-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToCent:y];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertCentToY:p];
}


-(NSNumber *)convertYToCent:(NSNumber *)y {
	

	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    if(![self valueForKey:@"minYValue"])
        NSLog(@"CentContainer: no minYValue!");
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	float f = ([y doubleValue]/ppy)+os;
    //[self minimumYValue] + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
    //NSLog(@"CentCont: converting y:%@ to Cent, ppy:%f, c: %f, offset: %f", y, ppy, f, os);
	return [NSNumber numberWithFloat: f] ;
	
}

-(NSNumber *)convertCentToY:(NSNumber *)f{
	
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	double y = ([f doubleValue] - [[self valueForKey:@"minYValue"]doubleValue])*ppy;
    //([f doubleValue]-[self minimumYValue])*ppy;// sizeY + 
	return [NSNumber numberWithFloat: y];
}

-(double)minimumYValue{return -50.0;}

-(double)maximumYValue{return +50.0;}

@end
