//
//  CsoundPlayer.m
//  quince
//
//  Created by max on 8/26/10.
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

#import "CsoundPlayer.h"


@implementation CsoundPlayer

-(CsoundPlayer *)init{

	if((self = [super init])){
		[NSBundle loadNibNamed:@"CsoundPlayerWindow" owner:self];
		[self Clicks:nil];
		[scoreView setRichText:NO];

		/* NSTextContainer *   container = [scoreView textContainer];
				[container setWidthTracksTextView: NO];
				NSSize size = [container containerSize];
				size.width = 100000000;//.0e5;
				[container setContainerSize: size];
				NSScrollView *	scroller = [scoreView enclosingScrollView];
				[scroller setHasHorizontalScroller: YES];
				NSRect frame = [scoreView frame];
				frame.size.width = 3000.0;
				[scoreView setFrame: frame];
		 */		
		[[scoreView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	}
	return self;
}

/*-(void)fetchCommonParametersForControllers:(NSArray *)controllers{
    [document setIndeterminateProgressTask:@"fetching common parameters..."];
	QuinceObjectController * c = [document controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO];
	for(QuinceObjectController * q in controllers)
		[c addSubObjectWithController:q withUpdate:NO];
	[c update];
	if(commonParameters)[commonParameters release];
	commonParameters = [[NSMutableArray arrayWithArray:[[c content]allKeysRecursively]]retain];
	

}*/

-(void)dealloc{

	//if(commonParameters)[commonParameters release];
	if(csound){
		csoundStop(csound);
		csoundReset(csound);
		csoundDestroy(csound);
	}
	[super dealloc];
}

-(void)prepare{
    [document setIndeterminateProgressTask:@"preparing objects..."];
	flatQuinceList = [document playbackObjectList];
	/*NSMutableArray * flatQuinceControllerList = [[[NSMutableArray alloc]init]autorelease];
	for(QuinceObject * q in flatQuinceList)
		[flatQuinceControllerList addObject:[q controller]];
	
	[self fetchCommonParametersForControllers:flatQuinceControllerList];*/
    
    [self fetchCommonParametersForArrayOfQuinces:flatQuinceList];
    
	//[self removeExcludedKeysFromArray:[self valueForKey:@"commonParameters"]];
	
}

-(void)fetchCommonParametersForArrayOfQuinces:(NSArray *)a{
    
    [document setProgressTask:@"fetching common parameters..."];
    [self removeObjectForKey:@"commonParameters"];
    QuinceObject * quince = [a lastObject]; // need ANY quince to use it's methods
    NSMutableArray * common = [[[NSMutableArray alloc]init] autorelease];
    int i=0;
    float f = 100.0/[a count];
    NSArray * ek = [self excludedParameters];
    
    for(QuinceObject * q in a){
        [document setProgress:f*i++];
        
        for(NSString * s in [q allKeys]){
            if(![quince isString:s inArrayOfStrings:ek] && 
               ![quince isString:s inArrayOfStrings:common] &&
               [self doAllObjectsInArray:a haveAValueForKey:s]){
                        
                [common addObject:s];
            }
        }
    }
    [self setValue:common forKey:@"commonParameters"];
}

-(BOOL)doAllObjectsInArray:(NSArray *)a haveAValueForKey:(NSString *)key{
    
    for(QuinceObject * q in a){
    
        if(![q valueForKey:key])
            return NO;
    }
    return YES;
}

-(void)setup{

	if(![self document] || isPlaying) return;

    [document setIndeterminateProgressTask:@"setup..."];
    [document displayProgress:YES];
	
    [self prepare];
    
    [document setIndeterminateProgressTask:@"creating instance of csound..."];
    //NSLog(@"%@", commonParameters);
	
	if(!csound)
		csound = csoundCreate(self);
	

	[self writeCSD]; 
}


-(void)play{
	[self setup];
    
    [document setIndeterminateProgressTask:@"setting up csound..."];
    [document displayProgress:YES];
    
	[self setIsPlaying:YES];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setCursor) userInfo:nil repeats:YES];
	char * command[5];
	command[0] = "./dummy";
	command[1] = "-do";
	command[2] = "dac";
	command[3] = "-+rtaudio=PortAudio";
	command[4] = "/tmp/quince.csd";
	int argc = 5;
	
	CSUserData * ud; 
	ud = (CSUserData *)malloc(sizeof(CSUserData)); 
	ud->csound = csound;
	ud->result = csoundCompile(csound, argc, command);
	ud->player = self;
	
	csoundSetScoreOffsetSeconds(csound, [[document valueForKey:@"playbackStartTime"]doubleValue]);
	csoundCreateThread(csThread,(void*)ud); 
    [document displayProgress:NO];

//	while(!csoundPerform(csound));
	
}

-(void) csoundThreadRoutine:(CsoundPlayer *)sp {
	//NSLog(@"csoundThreatRoutine?");
	//csoundPerform([sp csound]);
}


uintptr_t csThread(void *data)  { 
	//NSLog(@"csThread?");
	CSUserData* udata = (CSUserData*)data; 
	if(!udata->result) { 
		udata->result = csoundPerform(udata->csound);
		udata->csound = nil;
		if(udata->result){
			CsoundPlayer *cs = (CsoundPlayer *)udata->player;
			//NSLog(@"\nSTOOOP\n");
			[cs stop];
		}
	}       
	return 1; 
}

static void * csoundCallback(CSOUND * csound,int attr, const char *format, va_list valist) {
	//NSLog(@"callback?");
	return 0;
}

-(void)stop{
    [document setIndeterminateProgressTask:@"stopping csound..."];
    [document displayProgress:YES];
    NSLog(@"CSoundPlayer: STOPPING______________________");
	[timer invalidate];	
	csoundStop(csound);	
	[document setCursorTime:[document valueForKey:@"playbackStartTime"]];
    NSLog(@"CSoundPlayer:stopped");
	[self setIsPlaying:NO];
	
	csoundReset(csound);
	NSLog(@"CSoundPlayer:reset");
    [document displayProgress:NO];
	//csoundDestroy(csound);
}


-(void)setCursor{
	if(csound)
		[document setCursorTime:[NSNumber numberWithDouble:csoundGetScoreTime(csound)]];
}

-(NSArray *)excludedParameters{

	return [NSArray arrayWithObjects:@"type", @"nonStandardReadIn", @"resampled", @"sampleRate", @"samplesPerWindow", @"windowDuration", @"offsetKeys", @"id", @"date", @"color", @"subObjects", @"startOffset", @"volumeOffset", @"start", @"volume", @"duration", @"compatible", @"superObject", nil];
}

-(BOOL)excludedParametersInclude:(NSString *)pam{

	for(NSString * s in [self excludedParameters]){
	
		if ([s isEqualToString:pam])
			return YES;
	}
	return NO;
}

-(void)removeExcludedKeysFromArray:(NSMutableArray*)pams{

    [document setIndeterminateProgressTask:@"removing excluded keys..."];
	
    BOOL flag = NO;
	for(NSString *s in pams){
		if ([s isEqualToString:@"mediaFileName"]){
			[pams removeObject:s];
			flag  =YES;
			break;
		}
	}
	if(flag) [pams addObject:@"mediaFileName"];
	
	for(NSString * s in pams){
		if([self excludedParametersInclude: s]){
			[pams removeObject:s];
			[self removeExcludedKeysFromArray:pams];
			return;
		}
	}
}

-(void) writeCSD {
  	[document setIndeterminateProgressTask:@"writing csd..."];
    [document displayProgress:YES];
	NSLog(@"writeCSD");
	NSMutableString * csd = [[NSMutableString alloc]init];
	
	[csd appendFormat:@"<CsoundSynthesizer>\n<CsInstruments>\n"];
	[self writeOrc:csd];
	
	[csd appendFormat:@"</CsInstruments>\n<CsScore>\n"];
	
	[self writeSco:csd];
	[csd appendFormat:@"\n\n</CsScore>\n</CsoundSynthesizer>\n"];
	NSError * err;
	if(![csd writeToFile:@"/tmp/quince.csd" atomically:YES encoding:NSUTF8StringEncoding error:&err]){
		NSLog(@"could not write csd!");
		NSLog(@"%@", err);
	}
	//NSLog(@"\n\n\n\n\n%@", csd);
	[csd release];
}


-(void)writeOrc:(NSMutableString *)csd{
	[document setIndeterminateProgressTask:@"writing orc..."];
    [document displayProgress:YES];
    
	/* [csd appendFormat:@"\n\n\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n"];
		 //instruments
		 [csd appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
		 [csd appendFormat:@"instr 1			;knacks\n\n"];
		 [csd appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
		 [csd appendFormat:@"kenv\tlinseg\tiamp, .01, 0\n"];
		 [csd appendFormat:@"a1\trand\tkenv\n"];
		 [csd appendFormat:@"\touts\ta1, a1\n"];
		 [csd appendFormat:@"endin\n\n"];
	 */
	
	[csd appendString:[orcView string]];
}

-(void)writeSco:(NSMutableString *)csd{

    [document setIndeterminateProgressTask:@"writing score..."];
    [document displayProgress:YES];
    NSArray * commonParameters = [self valueForKey:@"commonParameters"];
	[csd appendFormat:@"f1 0 4096 10 1\n\n\n;i#     start           dur          vol      "];
	for(NSString * s in commonParameters)
		[csd appendFormat:@"%@     ", s ];
	
	[csd appendFormat:@"\n\n\n"];
	
	for(QuinceObject * q in flatQuinceList){
		if([q isOfType:@"envelope"]);
		else{
			[csd appendFormat:@"i1     %f     %f     %f     ", [[q valueForKey:@"start"]doubleValue], [[q valueForKey:@"duration"]doubleValue], [[q valueForKey:@"volume"]doubleValue]];
			for(NSString * s in commonParameters){
				id val = [q valueForKey:s];
				
				if([s isEqualToString:@"audioFileName"] || [s isEqualToString:@"mediaFileName"]){
					val = [[document objectWithValue:[q valueForKey:s] forKey:@"name"]valueForKey:@"filePath"];
				}
				
				//NSLog(@"%@", [val className]);
				if(val){
					if([[val className]isEqualToString:@"NSCFString"])
						[csd appendFormat:@"\"%@\"   ", val];
					else
						[csd appendFormat:@"%@   ", val];
				}
				else {
					[csd appendFormat:@"0   "];
				}
			}
			[csd appendFormat:@"\n"];
		}
	}

}

-(CSOUND *)csound{return csound;}

-(NSPanel *)window{return window;}

-(void)showWindow{
    [document displayProgress:YES];
	[self prepare];
	NSMutableString * score = [[[NSMutableString alloc]init]autorelease];
	[self writeSco:score];
    [self setValue:score forKey:@"scoreString"];
//	[scoreView setString:score];
	[[self window]makeKeyAndOrderFront:nil];

    [document displayProgress:NO];
}

-(IBAction)Clicks:(id)sender{
	NSMutableString * orc = [[[NSMutableString alloc]init]autorelease];
	[orc appendFormat:@"\n\n\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n"];
	//instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
	[orc appendFormat:@"instr 1			;Clicks\n\n"];
	[orc appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
	[orc appendFormat:@"kenv\tlinseg\tiamp, .01, 0\n"];
	[orc appendFormat:@"a1\trand\tkenv\n"];
	[orc appendFormat:@"\touts\ta1, a1\n"];
	[orc appendFormat:@"endin\n\n"];
    [self setValue:orc forKey:@"orcString"];
//	[orcView setString:orc];
}

-(IBAction)SampWin:(id)sender{
	NSMutableString * orc = [[[NSMutableString alloc]init]autorelease];
	[orc appendFormat:@"\n\n\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n"];
	//instruments
	[orc appendFormat:@"instr 1			;Windowing\n\n"];
	
	[orc appendFormat:@"iamp\t=\tampdb(p4)\n"];
	[orc appendFormat:@"a1\tdiskin\tp8, 1, p2\n"];
	[orc appendFormat:@"kenv\tlinseg\t0, .004, 1, p3-.008, 1, .004, 0\n"];
	[orc appendFormat:@"\t\touts a1*kenv*iamp, a1*kenv*iamp\n"];
	[orc appendFormat:@"endin\n\n"];
	
    [self setValue:orc forKey:@"orcString"];
	//[orcView setString:orc];
	
}
-(IBAction)Pitches:(id)sender{
	NSMutableString * orc = [[[NSMutableString alloc]init]autorelease];
	[orc appendFormat:@"\n\n\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n"];
	//instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
	[orc appendFormat:@"instr 1			;Pitches\n\n"];
	[orc appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
	[orc appendFormat:@"kenv\tlinseg\t0, .005, 1, p3-.01, 1, .005, 0\n"];
	[orc appendFormat:@"a1\toscil\tiamp, p7, 1\n"];
	[orc appendFormat:@"\touts\ta1*kenv, a1*kenv\n"];
	[orc appendFormat:@"endin\n\n"];
	//[orcView setString:orc];
    [self setValue:orc forKey:@"orcString"];
	
}
-(IBAction)Custom:(id)sender{
	NSMutableString * orc = [[[NSMutableString alloc]init]autorelease];
	[orc appendFormat:@"\n\n\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n"];
	//instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
	[orc appendFormat:@"instr 1			;\n\n"];

	
	[orc appendFormat:@"\touts\ta1, a1\n"];
	[orc appendFormat:@"endin\n\n"];
	//[orcView setString:orc];
    [self setValue:orc forKey:@"orcString"];
	
}

-(NSDictionary *)settings{

	NSMutableDictionary * s = [[NSMutableDictionary alloc]init];
	
	[s setValue:[orcView string] forKey:@"orc"];
	return [s autorelease];
}

-(void)setSettings:(NSDictionary *)settings{
	[orcView setString:[NSString stringWithString:[settings valueForKey:@"orc"]]];
}

@end
