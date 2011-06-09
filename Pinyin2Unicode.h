#import <Foundation/Foundation.h>

@interface Pinyin2Unicode : NSObject
{
	NSArray *toIntermediary;
	NSArray *toUnicode;
}

+ (Pinyin2Unicode *) converter;
- (NSString *) convert:(NSString *)text;

@end
