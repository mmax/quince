//
//  GlissandoContainer.m
//  quince
//
//  Created by max on 7/15/11.
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

#import "GlissandoContainer.h"


@implementation GlissandoContainer

-(NSString *)defaultChildViewClassName{return @"GlissandoChild";}

-(id)initWithFrame:(NSRect)frame{	
	if ((self = [super initWithFrame:frame])) 
        [self setValue:[NSNumber numberWithFloat:(frame.size.height-kDefaultYAxisHeadRoom)/115] forKey:@"pixelsPerUnitY"];
    //    NSLog(@"%f", frame.size.height);
    
    return self;
}


-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly{

    if(![[mc content]valueForKey:@"frequency"]){
        [mc createFreqEntry];
    }

    
    if([[mc content]valueForKey:@"frequency"] && ![[mc content]valueForKey:@"frequencyB"]){
        [mc createFreqBEntry];
    }
    
    return [super createChildViewForQuinceObjectController:mc andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];
}


-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return [NSString stringWithString:@"pitch"];
}

-(NSString *)keyForLocationOnYAxis{
    return [NSString stringWithString:@"pitch"];
}

-(NSString *)keyForSizeOnYAxis{return @"pitchRange";}


-(NSNumber *)parameterValueForY:(NSNumber *)y{
	return [self convertYToPitch:y];
}

-(NSNumber *)yForParameterValue:(NSNumber *)p{
	return [self convertPitchToY:p];
}

-(NSNumber *)convertYToPitch:(NSNumber *)y {
	
	//float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	float p = [self minimumYValue] + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
	return [NSNumber numberWithFloat: p] ;
	
}

-(NSNumber *)convertPitchToY:(NSNumber *)f{
	
    //	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
	double y = ([f doubleValue]-[self minimumYValue])*ppy;// sizeY + 
	return [NSNumber numberWithFloat: y];
}

//-(NSNumber *)yDeltaForParameterValue:(NSNumber *)p{
//	return [self convertPitchToYDelta:p];
//}

//-(NSNumber *)parameterValueForDeltaY:(NSNumber *)y{
//
//    return [self convertDeltaYToDeltaPitch:y];
//}



//-(NSNumber *)convertPitchToYDelta:(NSNumber *)p{
//    NSNumber * y = [NSNumber numberWithFloat: [p doubleValue]*[[self valueForKey:@"pixelsPerUnitY"]doubleValue]];	
//   // NSLog(@"convertPitchToYDelta: p: %@, y: %@", p, y);
//	return y;
//}

-(double)minimumYValue{return 16;}

-(double)maximumYValue{return 130;}

-(BOOL)allowsVerticalResize{return YES;}

@end
