//
//  GlissandoChild.m
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


#import "GlissandoChild.h"


@implementation GlissandoChild

-(void)setController:(QuinceObjectController *)mc andBindWithKeysForLocationOnX:(NSString *)lx sizeOnX:(NSString *)sx locationOnY:(NSString *)ly{
   [self bind:[enclosingView keyForSizeOnYAxis] toObject:mc withKeyPath:[NSString stringWithFormat:@"selection.%@", [enclosingView keyForSizeOnYAxis]] options:nil];	
    [super setController:mc andBindWithKeysForLocationOnX:lx sizeOnX:sx locationOnY:ly];
   //[self bind:@"pitchRange" toObject:controller withKeyPath:[NSString stringWithFormat:@"selection.endFreq"] options:nil];	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////



-(void)setValue:(id)value forKey:(NSString *)key{
 
    if ([key isEqualToString:@"frequencyB"]) {
        
      //  [self setValue:[NSNumber numberWithDouble:[self fToMD:[value doubleValue]]] forKey:@"endPitch"];
        [self updateEnd];
    }
    [super setValue:value forKey:key];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateEnd{


}


-(NSPoint)pointForEndFreq{

    double x = [self bounds].origin.x + [self bounds].size.width;
    double y = [[enclosingView yForParameterValue:[self valueForKey:@"frequencyB"]]doubleValue] + [[enclosingView yDeltaForParameterValue:[controller valueForKeyPath:[NSString stringWithFormat:@"selection.frequencyBOffset"]]]doubleValue];
                
    
    return NSMakePoint(x, y);
}

-(NSPoint)pointForStartFreq{

    double x = [self bounds].origin.x, y= [self bounds].origin.y;
    
   return NSMakePoint(x, y);
}

@end
