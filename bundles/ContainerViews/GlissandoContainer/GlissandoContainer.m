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



-(ChildView *)createChildViewForQuinceObjectController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly{

    if(![[mc content]valueForKey:@"frequency"]){
        //NSLog(@"GlissandoContainer: no frequency parameter, creating entry...");
        [mc createFreqEntry];
    }

    
    if([[mc content]valueForKey:@"frequency"] && ![[mc content]valueForKey:@"frequencyB"]){
        //NSLog(@"GlissandoContainer: no frequencyB parameter, creating entry...");
        [mc createFreqBEntry];
    }
    id result = [super createChildViewForQuinceObjectController:mc andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];
    return  result;
}


-(BOOL)allowsNewSubObjectsToRepresentAudioFiles{return YES;}


-(NSString *)parameterOnY{
	return [NSString stringWithString:@"pitchF"];
}

-(NSString *)keyForLocationOnYAxis{
    return [NSString stringWithString:@"pitchF"];
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
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	float p = ([y doubleValue]/ppy)+os;//[self minimumYValue] + ([y doubleValue] / ppy);//((sizeY - [y doubleValue]) / ppy);
    //NSLog(@"p:%f", p);
	return [NSNumber numberWithFloat: p] ;
	
}

-(NSNumber *)convertPitchToY:(NSNumber *)f{
	
    //	float sizeY = [self frame].size.height-[[self valueForKey:@"yAxisHeadRoom"]floatValue];
	double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
    double os = [[self valueForKey:@"minYValue"]doubleValue];
	double y = ([f doubleValue]-os)*ppy;// + ppy * [[self valueForKey:@"cent"]doubleValue]/100.0;//([f doubleValue]-[self minimumYValue])*ppy;// sizeY + 
    //NSLog(@"f:%f, y: %f", [f doubleValue], y);
	return [NSNumber numberWithFloat: y];
}


//-(void)moveSelectionByX:(float)x andY:(float)y{
//	
//	//NSRect before = [self unionRectForSelection];
//	ChildView * child;
//    double ppy = [[self valueForKey:@"pixelsPerUnitY"]doubleValue];
//    
//    if(y!=0 && fabs(y)<ppy)
//        y = ppy * y>0?1:-1;
//    
//	for(child in selection){
//		[child moveX:x];
//		[child moveY:y];
//	}
//	[contentController update];
//	
//	//NSRect after = [self unionRectForSelection]; 
//	//[self setNeedsDisplayInRect:NSUnionRect(before, after)];
//} 

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

-(double)maximumYValue{return 129;}

-(BOOL)allowsVerticalResize{return YES;}

@end
