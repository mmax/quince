//
//  Transpose.m
//  quince
//
//  Created by max on 7/8/11.
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


#import "Transpose.h"


@implementation Transpose

- (id)init
{
    self = [super init];
    if (self) {
        //[NSBundle loadNibNamed:@"TransposeWindow" owner:self];
        [[[NSBundle alloc]init] loadNibNamed:@"TransposeWindow" owner:self topLevelObjects:nil];
    }
    
    return self;
}

-(void)perform{
    [window makeKeyAndOrderFront:nil];
}

-(IBAction)TransposeInterval:(id)sender{

    int oct = [octaveField intValue];
    int st = [semiToneField intValue];
    int cent = [centField intValue];
    BOOL addST = [[semiTonePM titleOfSelectedItem]isEqualToString:@"+"];
    BOOL addCent = [[centPM titleOfSelectedItem]isEqualToString:@"+"];
    BOOL up = [[upDown titleOfSelectedItem]isEqualToString:@"up"];
    
    
    int transposeCent = 1200 * oct;
    if(addST)
        transposeCent += 100 * st;
    else
        transposeCent -= 100 * st;
    if(addCent)
        transposeCent += cent;
    else
        transposeCent -= cent;
    
    if(!up)
        transposeCent *= -1;
    
    double centFactor = pow(2.0, 1.0 / 1200.0);
    double factor = pow(centFactor, transposeCent);
    
    [self setValue:[NSNumber numberWithDouble: factor] forKey:@"transposeFactor"];
    [self go];
}

-(IBAction)TransposeFactor:(id)sender{
    
    double factor = [factorField doubleValue];
    [self setValue:[NSNumber numberWithDouble: factor] forKey:@"transposeFactor"];
    [self go];
}

-(IBAction)Cancel:(id)sender{
    [window orderOut:nil];
}

-(void)go{

    QuinceObject * source = [self objectForPurpose:@"source"];
    
    for(QuinceObject * q in [source valueForKey:@"subObjects"])
        [self transposeQuince:q];
    
    
    [self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
    [self Cancel:nil];
}


-(void)transposeQuince:(QuinceObject *)q{

    double factor = [[self valueForKey:@"transposeFactor"]doubleValue];
    double frequency = [[q valueForKey:@"frequency"]doubleValue] * factor;
    if(frequency>0)
        [q setValue:[NSNumber numberWithDouble:frequency] forKey:@"frequency"];
    
    if([q subObjectsCount]){
    
        for(QuinceObject * quince in [q valueForKey:@"subObjects"])
            [self transposeQuince:quince];
    }
}

-(BOOL)hasInterface{return YES;}

@end
