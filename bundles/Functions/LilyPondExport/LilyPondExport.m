//
//  LilyPondExport.m
//  quince
//
//  Created by max on 3/27/10.
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

#import "LilyPondExport.h"


@implementation LilyPondExport

-(LilyPondExport *)init{

	if((self = [super init])){
		[NSBundle loadNibNamed:@"LilyPondExportWindow" owner:self];
		topKeys = [[NSMutableArray alloc]init];
		bottomKeys = [[NSMutableArray alloc]init];					
		lilly = [[NSMutableString alloc]init];
		//pitches = YES;
	}
	return self;
}

-(void)dealloc{
	[topKeys release];
	[bottomKeys release];
	[lilly release];
	if(grid) [grid release];
	if(flatGrid) [flatGrid release];
	[super dealloc];
}


-(void)perform{
	if(lilly){
		[lilly release];
		lilly = [[NSMutableString alloc]init];
	}
	if(topKeys){
		[topKeys release];
		topKeys = [[NSMutableArray alloc]init];
	}
	if (bottomKeys){
		[bottomKeys release];
		bottomKeys = [[NSMutableArray alloc]init];
	}
	[self fillSettingsArray];
	
	id t = [[self objectForPurpose:@"source"]valueForKey:@"tempo"];
	if(t)
		[tempoField setFloatValue:[t floatValue]];
	
	[window makeKeyAndOrderFront:nil];	
}

-(IBAction)export:(id)sender{
	
	pitches = [pitchesButton state]==NSOnState ? YES : NO;
	[window orderOut:nil];
	NSSavePanel* sp = [NSSavePanel savePanel];
	[sp setRequiredFileType:@"ly"];
	[sp setTitle:@"LilyPond Export"];
#ifdef MAC_OS_X_VERSION_10_6
	[sp setNameFieldStringValue:@"filenamedoesntmatter.ly"];
#endif
	outTempo = [tempoField floatValue];
	
	int status = [sp runModal];
	NSError * error;
	if(status==NSFileHandlingPanelOKButton){
		path = [[sp URL]path];
		[self generateCode];
		
		if(![lilly writeToURL:[sp URL] atomically:NO encoding:NSASCIIStringEncoding error:&error])
			[document presentAlertWithText:[NSString stringWithFormat:@"LilyPondExport: save operation failed: %@", error]];
	}
	[document displayProgress:NO];
	[self done];
}

-(void)sortKeys{

	for(NSDictionary * d in [settingsArray arrangedObjects]){
		if([[d valueForKey:@"field"]isEqualToString:@"pitch"]){
			pitches = [[d valueForKey:@"include"]boolValue];
		}
		else if([[d valueForKey:@"include"]boolValue]){
			if([[d valueForKey:@"field"]isEqualToString:@"dynExpr"])
				[bottomKeys addObject:[d valueForKey:@"field"]];
			else if([[d valueForKey:@"position"]intValue]==1)
				[bottomKeys addObject:[d valueForKey:@"field"]];
			else 
				[topKeys  addObject:[d valueForKey:@"field"]];
		}
		
		//NSLog(@"top: %@", topKeys);
		//NSLog(@"bottom: %@", bottomKeys);
	}
}

-(void)fillSettingsArray{
	[settingsArray removeObjects:[settingsArray content]];
	NSArray * keys = [[self objectForPurpose:@"source"] subObjectKeys];
	for(NSString * key in keys){
		if(weWantKey(key)){
			NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
			[dict setValue:key forKey:@"field"];
			[dict setValue:[self defaultIncludeForKey:key] forKey:@"include"];
			[dict setValue:[self defaultPositionForKey:key] forKey:@"position"];
			[settingsArray addObject:dict];
			[dict release];
		}
	}
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"field" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[[settingsArray content ]sortUsingDescriptors:descriptors];
	[sd release];
}

BOOL weWantKey(NSString * key){
//	if([key isEqualToString:@"start"])return NO;
	if([key isEqualToString:@"duration"] )return NO;
	if([key isEqualToString:@"subObjects"]) return NO;
	if([key isEqualToString:@"superObject"])return NO;
	if([key isEqualToString:@"pitch"])return NO;

	//if([key isEqualToString:@"date"])return NO;
	return YES;
}

-(NSValue *)defaultIncludeForKey:(NSString *)key{
	
	return [NSNumber numberWithBool:NO];
}
  
-(NSValue *)defaultPositionForKey:(NSString *)key{
	
	return [NSNumber numberWithInt:0];
}

-(void)toFile:(NSString *)s{
	[lilly appendString:s];
}

-(void)generateCode{
	
	[document setProgressTask:@"Converting To LilyPond..."];
	[document setProgress:0];
	[document displayProgress:YES];
	[self sortKeys];
	[self fillGrid];
	quince = [[self objectForPurpose:@"source"]copy];
	if(!quince){
		NSLog(@"%@: ERROR: no object for purpose 'source'!", [self className]);
		NSLog(@"%@", [self valueForKey:@"inputDescriptors"]);
		return;
	}
	[quince sortChronologically];
	//NSLog(@"sorted");
	
	[self changeTempo];
	[self quantize];
	//NSLog(@"quantized");
	events = [quince valueForKey:@"subObjects"];
	
	initialEventsCount = [events count];
	[self writeHeader];
//	NSLog(@"header written");
	voice = 0;
	while([events count]>0) {
		voice++;
		[self createVoiceString];	
	}
//	NSLog(@"voices written");
	[self writeFooter];
	
	[quince autorelease];

	//	NSLog(@"done");
}

-(void)quantize{
	for(QuinceObject * sub in [quince valueForKey:@"subObjects"])
		[self quantizeMint:sub];
}

-(void)fillGrid{ // grid: one array for each measure with one nsnumber for each lock including 0 and 1  - flatGrid, onw nsnumber for each lock, no duplicates

	grid = [[NSMutableArray alloc]init];
	flatGrid = [[NSMutableArray alloc]init];
	for(int i = 1;i<=8;i++){
		NSMutableArray * m = [[NSMutableArray alloc]init];
		for(int j = 0;j<=i;j++){
			NSNumber * c = [NSNumber numberWithDouble:1.0/i*j];
			[m addObject:c];
			if(![self numberInFlatGrid:c])
				[flatGrid addObject:c];	
		}
		[grid addObject:m];
		[m release];
	}
	
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"doubleValue" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[flatGrid sortUsingDescriptors:descriptors];
	[sd release];
}

-(BOOL) numberInFlatGrid:(NSNumber *)c{

	for(NSNumber * n in flatGrid){
		if ([n isEqualTo:c])
			return YES;
	}
	return NO;
}

-(void) createVoiceString{
	
	[self toFile:@"\\new Staff \\with { \n\t\\remove \"Time_signature_engraver\"\t"];
	if(!pitches)
		[self toFile:@"\n\t\\remove \"Clef_engraver\"\n"];
	
	[self toFile:@"\t} {\n"];
	[self toFile:@"\t\\override DynamicLineSpanner #'staff-padding = #2.4\n"];
	if(!pitches)
		[self toFile:@"\t\\override Staff.StaffSymbol #'line-count = 1\n \t\\override Staff.StaffSymbol #'line-count = 1"];
	[self toFile:@"\t\\override TextScript #'padding = #1.2\n"];
	[self toFile:@"\t\n\n"];	//[self toFile:@"\t\\fatText\n\n"];
	
	int next=0, event =0;
	
	while(event >=0){
		
		next = [self createStringForEventAtIndex:event start:next withMeasure:0];
		event = [self getIndexOfFirstEventAfterSecond:next];
		//printf("next: %d, event: %d\n", next, event);
	}
	//printf("\n------- S T A F F --------\n\n");
	[self toFile:@"}\n\n"];	
	voice++;
}

-(void)setProgressWithEventsCount:(long)c{
	long total = [[self objectForPurpose:@"source"]subObjectsCount];
	float progress = c/total * 100.0;
	[document setProgress:progress];
}

-(void)writeHeader{
	int tempo = [[quince valueForKey:@"tempo"]intValue];
	if(!tempo)tempo = 60;
	
	[self toFile:[NSString stringWithFormat:@"\\header { title = \"%@\"}\n", [path lastPathComponent]]];
	[self toFile:@"\\score{{\n"];
	[self toFile:@"\\override Score.VerticalAxisGroup #'remove-first = ##t \n"];
	[self toFile:@"\\override Score.MetronomeMark #'extra-offset = #'(-3 . 3)\n"];
	[self toFile:@"\\time 1/4\n"];
	[self toFile:[NSString stringWithFormat:@"\\set Score.currentBarNumber = #0\n \t\\tempo 4 = %d\n", tempo]];
	[self toFile:@"\\new StaffGroup\n"];
	[self toFile:@"<<\n\n"];
	
}

-(void)writeFooter{
	
	[self toFile:@">>\n"];
	[self toFile:@"}\n"];
	[self toFile:@"\\layout{\\context { \\RemoveEmptyStaffContext } }\n"];
	[self toFile:@"}\n"];
	[self toFile:@"\\paper{ print-page-number = ##t\n\tprintfirst-page-number = ##t\n\t	 systemSeparatorMarkup = \\slashSeparator\n\tmyStaffSize = #9 	 #(define fonts (make-pango-font-tree \"Helvetica Neue Regular\" \"Helvetica Neue Regular\" \"Helvetica Neue Regular\" (/ myStaffSize 10))) \n"];

	[self toFile:
	 [NSString stringWithFormat:@"oddFooterMarkup = #( string-append \"%@ code generated by quince on \"", [path lastPathComponent]]] ;
	[self toFile:@" ( strftime \"\%m/\%d/\%Y %H:%M:%S\" ( localtime ( current-time ))))"];
	[self toFile:@"\n}\n"];
}

-(int)getMeasureForTime:(double)start{

	int dezimalPart = start, measure, testInt;
	double frac = start - dezimalPart, testFrac, test;
	double tolerance = 0.006, grain;
	
	for(measure = 8;measure > 3;measure--){
		grain = 1.0/measure;
		test = frac/grain;
		testInt = test;
		testFrac = test-testInt;
		if(maxabs(testFrac) <= tolerance || maxabs(1-testFrac) <= tolerance)
			return measure;
	}
	return -1;
}

////////////////////////////////////////////////////////////////////////

double maxabs(double d){return d<0?d*(-1):d;}

////////////////////////////////////////////////////////////////////////

-(int)getLockIndexOfTime:(double)time inMeasure:(int)measure{
	
	int integerPart = time;
	double frac = time - integerPart, grain = 1.0/measure;
	return frac/grain + 0.5;
}

////////////////////////////////////////////////////////////////////////


-(NSString *)durationStringForMeasure:(int)measure times:(int)times {
	
	int dur = [self fractionForMeasure:measure];	
	NSString * dS;
	switch(times){
		case 1:
			dS=[NSString stringWithFormat:@"%d ", dur];break;
		case 2:
			dS=[NSString stringWithFormat:@"%d ", dur/2];break;
		case 3:		
			dS=[NSString stringWithFormat:@"%d. ", dur/2];break;
		case 4:
			dS=[NSString stringWithFormat:@"%d ", dur/4];break;
		case 5:
			return @""; // special case, if not a rest, needs special care 
		case 6:
			dS=[NSString stringWithFormat:@"%d. ", dur/4];break;
		case 7:
			dS=[NSString stringWithFormat:@"%d.. ", dur/4];break;
		case 8:
			dS = [NSString stringWithFormat:@"4 "];
			if(measure !=8){
				NSLog(@"%@: ERROR: durationStringForMeasure: assumed times==8: measure: %d, times: %d, dur: %d",[self className], measure, times, dur);
			}
			break;
	}
	if(!dS)NSLog(@"%@: durationStringForMeasure: no duration string created, measure: %d, times: %d, dur: %d",[self className], measure, times, dur);
	return dS;
}
////////////////////////////////////////////////////////////////////////

 -(int)	fractionForMeasure:(int)measure {
	
	int dur;
	if		(measure == 8)	dur = 32;
	else if	(measure >= 4)	dur = 16;
	else if	(measure >= 2)	dur = 8;
	else					dur = 4;
	
	return dur;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(int) createStringForEventAtIndex:(int)index start:(double)searchStart withMeasure:(int)measure{//second is the time to start, index is the event to use
	
	//NSLog(@"createStringForEventAtIndex:");
	// we can, at this point, be sure that the event at INDEX is either in a bar which is already already open, with MEASURE, OR that it starts in another second (if !measure)
	// events to fill up a bar are called from within this method, events to start in another second should be called from outside
	[self setProgressWithEventsCount:[events count]];
	NSString* tupletStart;
	NSString* tupletEnd;
	QuinceObject* event = [events objectAtIndex:index];
	NSString* pitchString = [self getPitchStringForEvent:event];
	NSString* infoString=[self createInfoStringForEvent:event];
	
	if(measure<=0)
		measure =  [self getMeasureForTime:[[event valueForKey:@"start"]doubleValue]];
	
	tupletStart = [self getTupletStartStringForMeasure:measure];
	tupletEnd = [self getTupletEndStringForMeasure:measure];
	
	int lockIndex=-1, rests, nextSec, timeLockIndex = [self getLockIndexOfTime:searchStart inMeasure:measure];
	double eventStart = [[event valueForKey:@"start"]doubleValue], remainingDur =0, remainingDurFractionalPart=0;
	double end = [[event end]doubleValue];
	int deltaSeconds=eventStart-searchStart; //was mit pausen aufgefüllt werden muss
	if(deltaSeconds>0){
		if(voice > 1) [self toFile:@"\t\\stopStaff\t\\override Staff.Clef #'transparent = ##t "];
		while(deltaSeconds--){
			if(voice>1)[self toFile:@"s4 "];
			else [self toFile:@"r4 "];
		}
		if(voice > 1)[self toFile:@"\t\\startStaff\t\\override Staff.Clef #'transparent = ##f\n"];
	}
	
	if(timeLockIndex == 0) [self toFile:tupletStart];
	
	lockIndex = [self getLockIndexOfTime:eventStart inMeasure:measure];
	int lockCount=timeLockIndex;
	rests = lockIndex-timeLockIndex;
	
	if(rests > 0) {
		[self toFile:[self createStringForRestOfMeasure:measure count:rests]];
		lockCount+=rests;
	}
	int times = [[event duration]doubleValue] > ((measure-lockIndex)*(1.0/measure)) ? (measure-lockIndex) : [[event duration]doubleValue]/(1.0/measure)+0.5;// was : 1;
	
	if(times ==0)times = 1;
	
	if(times==5){
		[self toFile:[NSString stringWithFormat:@"%@%@~%@", pitchString, [self durationStringForMeasure:measure times:3], infoString]];
		[self toFile:[NSString stringWithFormat:@"%@%@", pitchString, [self durationStringForMeasure:measure times:2]]];
	}
	else {
		[self toFile:[NSString stringWithFormat:@"%@%@%@", pitchString, [self durationStringForMeasure:measure times:times], infoString]] ;
	}
	remainingDur = 	[[event duration]doubleValue] - (1.0/measure)*times;
	int remainingSeconds = remainingDur;
	remainingDurFractionalPart = remainingDur-remainingSeconds;
	
	if(lockIndex+times== measure){
		if(remainingDur>0.001)
			[self toFile:@"~"];
		[self toFile:tupletEnd];
	}
	while(remainingSeconds--){
		//NSLog(@"remainingSeconds?");
		[self toFile:[NSString stringWithFormat:@"\t%@4", pitchString]];
		//NSLog(@"remainingSeconds: no");
		if(remainingDurFractionalPart>0){
			[self toFile:@"~"];
			[self toFile:@"\n"];	
		}
		else tupletEnd = [self getTupletEndStringForMeasure:1];
	}
	if(remainingDurFractionalPart>0.000001){ // due to rounding errors...
		//NSLog(@"LilyPondExport:createStringForEventAtIndex:... in rounding error correction block. should be avoided!");
		measure = [self getMeasureForTime:remainingDurFractionalPart];
		double measureLength = 1.0 / measure;
		tupletStart = [self getTupletStartStringForMeasure:measure];
		tupletEnd = [self getTupletEndStringForMeasure:measure];
		lockIndex=0;//[grid getGridPointForLock:remainingDurFractionalPart].lockIndex;
		lockCount=0;
		//NSLog(@"tupletStart oder was?!:measure:%d", measure);
		[self toFile:tupletStart];
		//NSLog(@"nö");
		float timesF = remainingDurFractionalPart / measureLength;
		times = timesF+0.5;			// very dirty!!!!
		//NSLog(@"irgendwo hier muss es ja sein...");
		if(times==5){
			
			[self toFile:[NSString stringWithFormat:@"%@%@~", pitchString, [self durationStringForMeasure:measure times:3]]];
			[self toFile:[NSString stringWithFormat:@"%@%@", pitchString, [self durationStringForMeasure:measure times:2]]];
			
		}
		else{
			[self toFile:[NSString stringWithFormat:@"%@%@", pitchString, [self durationStringForMeasure:measure times:times]]];
		}
		//NSLog(@"oder doch nicht?");
	}
	
	int i=index+1;
	if(times == measure){
		[self toFile:tupletEnd];
		nextSec = end+0.9;
	}
	else{
		
		i =[self eventWithMeasure:measure inSameSecondAfter:end afterEvent:index]; 
		if(i>0)																			
			nextSec = [self createStringForEventAtIndex:i start:end withMeasure:measure];
		else{
			rests = measure-times-lockIndex;
			if(rests>0){
				[self toFile:[self createStringForRestOfMeasure:measure count:rests]];
				[self toFile:tupletEnd];												
				end+=(1.0 / measure)*rests;
			}
			nextSec = end+.9;
		}
	}
	[events removeObject:event];
	//NSLog(@"createStringForEventAtIndex:DONE");
	return nextSec;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*) getTupletStartStringForMeasure:(int)measure{
	
	
	NSString*s;
	
	switch(measure) {
			
		case 8:	s = [NSString stringWithFormat:@"\t"];
			break;
		case 7:	s = [NSString stringWithFormat:@"\t\\times 4/7{ "];
			break;
		case 6: s = [NSString stringWithFormat:@"\t\\times 4/6{ "];
			break;
		case 5:	s = [NSString stringWithFormat:@"\t\\times 4/5{ "];
			break;
		case 4:	s = [NSString stringWithFormat:@"\t"];
			break;			
		case 3:	s = [NSString stringWithFormat:@"\t\\times 2/3{		"];
			break;
		case 2:	s = [NSString stringWithFormat:@"\t"];
			break;
		case 1:	s = [NSString stringWithFormat:@"\t"];
			break;						
	}
	[s retain];
	return s;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*) getTupletEndStringForMeasure:(int)measure{
	
	
	NSString*s;
	
	switch(measure) {
			
		case 8:	s = [NSString stringWithFormat:@"\n"];
			break;
		case 7:	s = [NSString stringWithFormat:@"}\n"];
			break;
		case 6: s = [NSString stringWithFormat:@"}\n"];
			break;
		case 5:	s = [NSString stringWithFormat:@"}\n"];
			break;
		case 4:	s = [NSString stringWithFormat:@"\n"];
			break;			
		case 3:	s = [NSString stringWithFormat:@"}\n"];
			break;
		case 2:s = [NSString stringWithFormat:@"\n"];
			break;
		case 1:	s = [NSString stringWithFormat:@"\n"];
			break;						
	}
	[s retain];
	return s;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(int) eventWithMeasure:(int)measure inSameSecondAfter:(double)time afterEvent:(int)index{
	
	
	int i=index+1, max = time+1.0;
	QuinceObject* event;
	double start;

	while([events count] > i){
		
		event = [events objectAtIndex:i];
		start = [[event valueForKey:@"start"]doubleValue];
		
		if(start >= max)
			break;
		if((start >= time) && (measure == [self getMeasureForTime:start]))
			return i;
		i++;
	}
	return -5;	//failure
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(int) getIndexOfFirstEventAfterSecond:(int)second {

	for(int i=0;i<[events count];i++){
		int time = [[[events objectAtIndex:i]valueForKey:@"start"]doubleValue];
		if(time >= second)
			return i;
	}
	return -1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *) createStringForRestOfMeasure:(int)measure count:(int)times {
	if(times == 5) return [self createStringFor5RestsOfMeasure:measure];
	NSString * dur = [NSString stringWithString:[self durationStringForMeasure:measure times:times]];
	
	if(!dur)
		return [self createStringFor5RestsOfMeasure:measure];
	return [NSString stringWithFormat:@"r%@ ", dur];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *) createStringFor5RestsOfMeasure:(int)measure {
	int dur = [self fractionForMeasure:measure];
	return [NSString stringWithFormat:@"r%d r%d r%d ", dur/2, dur/2, dur];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)getPitchStringForEvent:(QuinceObject *) event {

	int midi = [[event valueForKey:@"pitch"]intValue];
	int cent = [[event valueForKey:@"cent"]intValue];
	NSString * quarterToneSuffix;
	NSString * octaveString;
	NSString * pitchString;	
	NSString * clefString = [NSString string];

	int octave = midi / 12;
	int pitch = midi % 12;
	
	if (!pitches)
		return [NSString stringWithFormat:@"b'"];
	
	if(cent>50){
		pitch++;
		if(pitch==12){
			pitch =0;
			octave++;
		}
		cent -=100;
	}
	else if(cent<-50){
		pitch--;
		if(pitch==-1){
			pitch=11;
			octave--;
		}
		cent +=100;
	}
	
	if (cent < -25){ // then quartertone Down
		if(pitch == 1 || pitch == 3 || pitch == 6 || pitch == 8 || pitch == 10){ // wenn schwarze taste
			pitch--;												// halbton runter
			quarterToneSuffix = [NSString stringWithFormat:@"ih"];	// und viertelton rauf
		}
		else														//wenn weisse taste
			quarterToneSuffix = [NSString stringWithFormat:@"eh"]; // viertelTon runter
		
		cent+=50;
	}
	
	else if(cent > 25) {	// 
		if(pitch == 1 || pitch == 3 || pitch == 6 || pitch == 8 || pitch == 10){//wenn schwarze taste,
			pitch++; //halbton rauf
			quarterToneSuffix = [NSString stringWithFormat:@"eh"]; // viertelTon runter

		}
		else														//wenn weisse taste
			quarterToneSuffix = [NSString stringWithFormat:@"ih"]; // viertelTon rauf
			
		cent -= 50;
	}	
	else quarterToneSuffix = [NSString stringWithFormat:@""];	

	[event setValue:[NSNumber numberWithInt:cent] forKey:@"cent"];

	switch(octave) {
			
		case 15:	octaveString = [NSString stringWithFormat:@"'"]; break;
		case 14:	octaveString = [NSString stringWithFormat:@"''''''''''"]; break;
		case 13:	octaveString = [NSString stringWithFormat:@"'''''''''"]; break;
		case 12:	octaveString = [NSString stringWithFormat:@"''''''''"]; break;
		case 11:	octaveString = [NSString stringWithFormat:@"'''''''"]; break;
		case 10:	octaveString = [NSString stringWithFormat:@"''''''"]; break;
		case 9:		octaveString = [NSString stringWithFormat:@"'''''"]; break;
		case 8:		octaveString = [NSString stringWithFormat:@"''''"]; break;
		case 7:		octaveString = [NSString stringWithFormat:@"'''"]; break;
		case 6:		octaveString = [NSString stringWithFormat:@"''"]; break;
		case 5:		octaveString = [NSString stringWithFormat:@"'"]; break;
		case 4:		octaveString = [NSString stringWithFormat:@""]; break;
		case 3:		octaveString = [NSString stringWithFormat:@","]; break;
		case 2:		octaveString = [NSString stringWithFormat:@",,"]; break;
		case 1:		octaveString = [NSString stringWithFormat:@",,,"]; break;
		case 0:		octaveString = [NSString stringWithFormat:@",,,,"]; break;
		default:	octaveString = [NSString stringWithFormat:@",,,,"];				
	}
	
	switch(pitch) {
			
		case 0:		pitchString = [NSString stringWithFormat:@"c"]; break;
		case 1:		pitchString = [NSString stringWithFormat:@"cis"]; break;
		case 2:		pitchString = [NSString stringWithFormat:@"d"]; break;
		case 3:		pitchString = [NSString stringWithFormat:@"dis"]; break;
		case 4:		pitchString = [NSString stringWithFormat:@"e"]; break;
		case 5:		pitchString = [NSString stringWithFormat:@"f"]; break;
		case 6:		pitchString = [NSString stringWithFormat:@"fis"]; break;
		case 7:		pitchString = [NSString stringWithFormat:@"g"]; break;
		case 8:		pitchString = [NSString stringWithFormat:@"gis"]; break;
		case 9:		pitchString = [NSString stringWithFormat:@"a"]; break;
		case 10:	pitchString = [NSString stringWithFormat:@"ais"]; break;
		case 11:	pitchString = [NSString stringWithFormat:@"b"]; break;
	}
	if(octave > 7) clefString = [NSString stringWithFormat:@"\\clef treble"];// #(set-octavation 2)"];
	else if(octave>6) clefString = [NSString stringWithFormat:@"\\clef treble"];// #(set-octavation 1)"];
	else if(octave>=5)clefString = [NSString stringWithFormat:@"\\clef treble"];
	else clefString = [NSString stringWithFormat:@"\\clef bass"];// #(set-octavation 0)"];	
	
	return [NSString stringWithFormat:@"%@ %@%@%@", clefString, pitchString, quarterToneSuffix, octaveString];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *)getStringValueOf:(id)value{

	if([value isKindOfClass:NSClassFromString(@"NSString")]) return value;
	if ([value isKindOfClass:NSClassFromString(@"NSNumber")]) return [value stringValue]; 
//	NSLog(@"hier? : %@", [value description]);
	return [value description];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString *) createInfoStringForEvent:(QuinceObject *)event{
	

	NSMutableString * m = [[NSMutableString alloc]init];

	BOOL dynamic = NO;
	if([topKeys count]){ 
		[m appendString:@"^\\markup{\\fontsize #0.1 { \\center-align{"];
		for(NSString * key in topKeys)
			[m appendFormat:@" \"%@\"", [self getStringValueOf:[event valueForKey:key]]];
		[m appendString:@"}}}"];
	}
	if([bottomKeys count]){ 
		[m appendString:@"_\\markup{\\fontsize #0.1 { \\center-align{"];
		for(NSString * key in bottomKeys){
			if([key isEqualToString:@"dynExpr"])
				dynamic = YES;
			else [m appendFormat:@" \"%@\"", [self getStringValueOf:[event valueForKey:key]]];
		}
		[m appendString:@"}}}"];
		if(dynamic && [event valueForKey:@"dynExpr"]) [m appendFormat:@"\\%@ ", [self getStringValueOf:[event valueForKey:@"dynExpr"]]];
	}

	
	/*
	NSString * aS = [NSString stringWithFormat:@"^\\markup{\\fontsize #0.1 { \\center-align{\"#%d\"", [[event index]longValue]];
	int cent = [[event cent]intValue];	
	if([[event cent]intValue] < -25) cent += 50;
	else if ([[event cent]intValue] > 25) cent -= 50;
	if(cent!=0)
		aS = [aS stringByAppendingFormat:@"%@%dcent ", cent > 0 ? [NSString stringWithFormat:@"+"] : [NSString string], cent ];

	if(LYXdescriptions && ![[event description]isEqualToString:@"?"]) aS =[aS stringByAppendingFormat:@" %@", [event description]];
	if(!controller) printf("no controller!\n");
	aS = [aS stringByAppendingFormat:@"}}}"];
	if(LYXdynamics) aS = [aS stringByAppendingFormat:@"\\%@ ", [event dynamicString]];
	return aS;
	 */
	return m;
	
}

-(void)quantizeMint:(QuinceObject *)candidate{
	
	double a, deltaA, b, deltaB,start = [[candidate valueForKey:@"start"]doubleValue], duration, end = [[candidate end]doubleValue];
	long i, startIntegerPart = start, measure, endIntegerPart = end;
	double startFractionalPart = start - startIntegerPart, endFractionalPart = end - endIntegerPart;
	
	// quantizing start
	for(i=0;i<[flatGrid count];i++){
		b = [[flatGrid objectAtIndex:i]doubleValue];
		if(b>startFractionalPart && i>0){
			a = [[flatGrid objectAtIndex:i-1]doubleValue];
			deltaA = startFractionalPart-a;
			deltaB = b-startFractionalPart;
			if (deltaA > deltaB) startFractionalPart = b;
			else startFractionalPart = a;
			start = startIntegerPart + startFractionalPart;
			measure = [self getMeasureForTime:startFractionalPart];
			[candidate setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
			break;
		}
		else if(b>startFractionalPart && i==0){
			NSLog(@"LilyPondExport:quantizeMint: something went awfully wrong! ->->");
			NSLog(@"start: %f startFractionalPart: %f b: %f i: %ld", start, startFractionalPart, b, i);
		}
	}
	
	// quantizing duration
	if(endIntegerPart == startIntegerPart){ // wenn das event in derselben sekunde endet in der es begann, müssen wir im selben gridMeasure bleiben
		NSArray * gridMeasure = [grid objectAtIndex:measure-1];
		for(int i=0;i<[gridMeasure count];i++){
			b = [[gridMeasure objectAtIndex:i] doubleValue];
			if(b>endFractionalPart && i>0){
				a = [[gridMeasure objectAtIndex:i-1]doubleValue];
				deltaA = endFractionalPart-a;
				deltaB = b-endFractionalPart;
				if (deltaA > deltaB) duration = b-start;
				else duration = a-start;
				if(duration < 0.01) duration = 1.0/measure;
				[candidate setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];
				break;
			}
		}
	}
	else{
		for(i = 0;i<[flatGrid count];i++){
			b = [[flatGrid objectAtIndex:i]doubleValue];
			if(b>endFractionalPart && i>0){
				a = [[flatGrid objectAtIndex:i-1]doubleValue];
				deltaA = endFractionalPart-a;
				deltaB = b-endFractionalPart;
				if (deltaA > deltaB) duration = (b+endIntegerPart)-start;
				else duration = (a+endIntegerPart)-start;
				[candidate setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];
				break;
			}
		}
	}
}

-(void)changeTempo{

	id t = [quince valueForKey:@"tempo"];
	float inTempo = 60.0;
	double f;

	if(t)
		inTempo = [t floatValue];
	
	f = outTempo / inTempo;
	//NSLog(@"changeTempo: f: %f", f);
	for(QuinceObject * q in [quince valueForKey:@"subObjects"]){
		double start = [[q valueForKey:@"start"]doubleValue] * f;
		double duration = [[q valueForKey:@"duration"]doubleValue] * f;
		
		[q setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
		[q setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];		
	}
	
	[quince setValue:[NSNumber numberWithFloat:outTempo] forKey:@"tempo"];
}

@end
