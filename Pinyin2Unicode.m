/* toIntermediary data from 
   http://www.foolsworkshop.com/downloads/pinyintounicode.txt
   (written by Konrad Mitchell Lawson)
   toUnicode data is derived from that (converted to hex)
*/
#import "Pinyin2Unicode.h"

@implementation Pinyin2Unicode

+ (Pinyin2Unicode *) converter
{
	Pinyin2Unicode *cvt = [[Pinyin2Unicode alloc] init];
	[cvt autorelease];
	return cvt;
}

- (NSString *) convert:(NSString *)text
{
	NSMutableString *rv = [NSMutableString stringWithString:text];
	NSEnumerator *en = [toIntermediary objectEnumerator];
	id value;
	while ((value = [en nextObject])) {
		NSString *from = (NSString *)[en nextObject];
		NSString *to = (NSString *)value;
		[rv replaceOccurrencesOfString:from withString:to options:0 
					 range:NSMakeRange(0, [rv length])];
	}
	value = nil;
	en = [toUnicode objectEnumerator];
	while ((value = [en nextObject])) {
		NSString *from = (NSString *)[en nextObject];
		NSString *to = (NSString *)value;
		[rv replaceOccurrencesOfString:from withString:to options:0 
					 range:NSMakeRange(0, [rv length])];
	}
	return [NSString stringWithString:rv];
}

- (id) init
{
	if (self = [super init]) {
		toIntermediary = [[NSArray alloc] initWithObjects:
			@"//aq//ng", @"ang1",
			@"//aw//ng", @"ang2",
			@"//ae//ng", @"ang3",
			@"//ar//ng", @"ang4",
			@"ang", @"ang5",
			@"//eq//ng", @"eng1",
			@"//ew//ng", @"eng2",
			@"//ee//ng", @"eng3",
			@"//er//ng", @"eng4",
			@"eng", @"eng5",
			@"//iq//ng", @"ing1",
			@"//iw//ng", @"ing2",
			@"//ie//ng", @"ing3",
			@"//ir//ng", @"ing4",
			@"ing", @"ing5",
			@"//oq//ng", @"ong1",
			@"//ow//ng", @"ong2",
			@"//oe//ng", @"ong3",
			@"//or//ng", @"ong4",
			@"ong", @"ong5",
			@"//aq//n", @"an1",
			@"//aw//n", @"an2",
			@"//ae//n", @"an3",
			@"//ar//n", @"an4",
			@"an", @"an5",
			@"//eq//n", @"en1",
			@"//ew//n", @"en2",
			@"//ee//n", @"en3",
			@"//er//n", @"en4",
			@"en", @"en5",
			@"//iq//n", @"in1",
			@"//iw//n", @"in2",
			@"//ie//n", @"in3",
			@"//ir//n", @"in4",
			@"in", @"in5",
			@"//uq//n", @"un1",
			@"//uw//n", @"un2",
			@"//ue//n", @"un3",
			@"//ur//n", @"un4",
			@"un", @"un5",
			@"//aq//o", @"ao1",
			@"//aw//o", @"ao2",
			@"//ae//o", @"ao3",
			@"//ar//o", @"ao4",
			@"ao", @"ao5",
			@"//oq//u", @"ou1",
			@"//ow//u", @"ou2",
			@"//oe//u", @"ou3",
			@"//or//u", @"ou4",
			@"ou", @"ou5",
			@"//aq//i", @"ai1",
			@"//aw//i", @"ai2",
			@"//ae//i", @"ai3",
			@"//ar//i", @"ai4",
			@"ai", @"ai5",
			@"//eq//i", @"ei1",
			@"//ew//i", @"ei2",
			@"//ee//i", @"ei3",
			@"//er//i", @"ei4",
			@"ei", @"ei5",
			@"//aq//", @"a1",
			@"//aw//", @"a2",
			@"//ae//", @"a3",
			@"//ar//", @"a4",
			@"//aq//", @"a1",
			@"//aw//", @"a2",
			@"//ae//", @"a3",
			@"//ar//", @"a4",
			@"a", @"a5",
			@"//ew//r", @"er2",
			@"//ee//r", @"er3",
			@"//er//r", @"er4",
			@"er", @"er5",
			@"l//v//e", @"lyue",
			@"n//v//e", @"nyue",
			@"//eq//", @"e1",
			@"//ew//", @"e2",
			@"//ee//", @"e3",
			@"//er//", @"e4",
			@"e", @"e5",
			@"//oq//", @"o1",
			@"//ow//", @"o2",
			@"//oe//", @"o3",
			@"//or//", @"o4",
			@"o", @"o5",
			@"//iq//", @"i1",
			@"//iw//", @"i2",
			@"//ie//", @"i3",
			@"//ir//", @"i4",
			@"i", @"i5",
			@"n//ve//", @"nyu3",
			@"l//v//", @"lyu",
			@"//vq//", @"v1",
			@"//vw//", @"v2",
			@"//ve//", @"v3",
			@"//vr//", @"v4",
			@"//vs//", @"v0",
			@"//uq//", @"u1",
			@"//uw//", @"u2",
			@"//ue//", @"u3",
			@"//ur//", @"u4",
			@"u", @"u5",
			nil];
		toUnicode = [[NSArray alloc] initWithObjects:
			[NSString stringWithFormat:@"%C", 0x0101], @"//aq//",
			[NSString stringWithFormat:@"%C", 0x00E1], @"//aw//",
			[NSString stringWithFormat:@"%C", 0x01CE], @"//ae//",
			[NSString stringWithFormat:@"%C", 0x00E0], @"//ar//",
			[NSString stringWithFormat:@"%C", 0x0113], @"//eq//",
			[NSString stringWithFormat:@"%C", 0x00E9], @"//ew//",
			[NSString stringWithFormat:@"%C", 0x011B], @"//ee//",
			[NSString stringWithFormat:@"%C", 0x00E8], @"//er//",
			[NSString stringWithFormat:@"%C", 0x012B], @"//iq//",
			[NSString stringWithFormat:@"%C", 0x00ED], @"//iw//",
			[NSString stringWithFormat:@"%C", 0x01D0], @"//ie//",
			[NSString stringWithFormat:@"%C", 0x00EC], @"//ir//",
			[NSString stringWithFormat:@"%C", 0x014D], @"//oq//",
			[NSString stringWithFormat:@"%C", 0x00F3], @"//ow//",
			[NSString stringWithFormat:@"%C", 0x01D2], @"//oe//",
			[NSString stringWithFormat:@"%C", 0x00F2], @"//or//",
			[NSString stringWithFormat:@"%C", 0x016B], @"//uq//",
			[NSString stringWithFormat:@"%C", 0x00FA], @"//uw//",
			[NSString stringWithFormat:@"%C", 0x01D4], @"//ue//",
			[NSString stringWithFormat:@"%C", 0x00F9], @"//ur//",
			[NSString stringWithFormat:@"%C", 0x01D6], @"//vq//",
			[NSString stringWithFormat:@"%C", 0x01D8], @"//vw//",
			[NSString stringWithFormat:@"%C", 0x01DA], @"//ve//",
			[NSString stringWithFormat:@"%C", 0x01DC], @"//vr//",
			[NSString stringWithFormat:@"%C", 0x00FC], @"//vs//",
			[NSString stringWithFormat:@"%C", 0x0100], @"//aaq//",
			[NSString stringWithFormat:@"%C", 0x00C0], @"//aaw//",
			[NSString stringWithFormat:@"%C", 0x01CD], @"//aae//",
			[NSString stringWithFormat:@"%C", 0x00BF], @"//aar//",
			[NSString stringWithFormat:@"%C", 0x0112], @"//eeq//",
			[NSString stringWithFormat:@"%C", 0x00C9], @"//eew//",
			[NSString stringWithFormat:@"%C", 0x00C8], @"//eer//",
			nil];
	}
	return self;
}
- (void) dealloc
{
	[toIntermediary release];
	[toUnicode release];
	[super dealloc];
}

@end
