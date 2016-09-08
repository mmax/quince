//
//  Player.m
//  quince
//
//  Created by max on 5/9/10.
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

#import <QuinceApi/Player.h>
#import <QuinceApi/QuinceDocument.h>



@implementation Player

@synthesize document, startTime;



-(Player *)init{

	if((self = [super init])){
		[self setStartTime:[NSNumber numberWithInt:0]];
		trackNodes = [[NSMutableArray alloc]init];
		isPlaying = NO;
        dictionary = [[NSMutableDictionary alloc]init];
        //pool = [[NSAutoreleasePool alloc]init];
		
	}
	return self;
}

-(void)dealloc{

    [dictionary release];
    [trackNodes release];
    //[pool release];
    [super dealloc];
}

-(void)setup{
	
	if(![self document] || isPlaying) return;
	
	
}



-(NSPanel *)window{
	return nil;
}

-(IBAction)ok:(id)sender{
	if([self window])
		[[self window]orderOut:nil];
}

-(void)play{
	//NSLog(@"play");
	[self setup];
	
	
}


-(void)stop{
}



-(BOOL)isPlaying{return isPlaying;}

-(void)setIsPlaying:(BOOL)b{
    isPlaying = b;
    [document setValue:[NSNumber numberWithBool:b] forKey:@"playbackStarted"];
    [document setValue:[NSNumber numberWithBool:!b] forKey:@"playbackStopped"];
}



//////////////////////////////////////////////////////////////////////////////////
// i reckon this is where player_plug-ins will implement their playback algorithms:
-(void)playQuince:(QuinceObject *)quince{

}

-(void)showWindow{
}

-(NSDictionary *)xmlDictionary{

	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	
	[dict setValue:[self className] forKey:@"name"];
	[dict setValue:[self settings] forKey:@"settings"];
	return [dict autorelease];
}

-(NSDictionary *)settings{

	return [NSDictionary dictionary];
}

-(void)setSettings:(NSDictionary *)settings{

}


-(void)mixDown{
	[document presentAlertWithText:@"not implemented"];
}

-(NSString *)getMixDownFilePath{
    
    NSSavePanel* sp = [NSSavePanel savePanel];
    NSArray * types = [NSArray arrayWithObject:@"aif"];
    [sp setAllowedFileTypes:types];
	//[sp setRequiredFileType:@"txt"];
	[sp setTitle:@"Save Audio File..."];
//#ifdef MAC_OS_X_VERSION_10_6
	[sp setNameFieldStringValue:@"filenamedoesntmatter.aif"];
//#endif
    
	
	long status = [sp runModal];
    
	if(status==NSFileHandlingPanelOKButton)
		return [[sp URL]path];
    
    return nil;
}

#pragma mark KVC

-(void)setValue:(id)aValue forKey:(NSString *)aKey{
	
	[self willChangeValueForKey:aKey];
	[self willChangeValueForKey:@"dictionary"];
	[dictionary setValue:aValue forKey:aKey];
	
	[self didChangeValueForKey:aKey];
	[self didChangeValueForKey:@"dictionary"];
	
}



-(id)valueForKey:(NSString *)key{

	if([key isEqualToString:@"dictionary"])
		return [self dictionary];
    return [dictionary valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
} 

-(void)removeObjectForKey:(NSString *)key{
	[self willChangeValueForKey:key];
	[dictionary removeObjectForKey:key];
	[self didChangeValueForKey:key];
}


-(NSDictionary *)dictionary{return dictionary;}
@end

