#import "ArrowButton.h"

@implementation ArrowButton

- (void) _setupKeyEquivalent
{
	unichar key;
	if ([self type] == ArrowButtonTypeLeft) {
		key = NSLeftArrowFunctionKey;
		[self setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
	} else if ([self type] == ArrowButtonTypeRight) {
		key = NSRightArrowFunctionKey;
		[self setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
	} else if ([self type] == ArrowButtonTypeUp) {
		key = NSUpArrowFunctionKey;
		[self setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
	} else if ([self type] == ArrowButtonTypeDown) {
		key = NSDownArrowFunctionKey;
		[self setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
	}
}

- (id) initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		[self setType:ArrowButtonTypeNotSet];
		[self setModifierMask:0];
	}
	return self;
}

- (unsigned int) type { return _type; }
- (void) setType:(unsigned int)newType
{
	_type = newType;
	[self _setupKeyEquivalent];
}

- (unsigned int) modifierMask { return _modifierMask; }
- (void) setModifierMask:(unsigned int)modifierMask
{
	_modifierMask = modifierMask;
	[self setKeyEquivalentModifierMask:modifierMask];
}

- (BOOL) performKeyEquivalent:(NSEvent *)theEvent
{
	/* Get the keycode */
	unichar kc;
	if ([[theEvent characters] length]) {
		kc = [[theEvent characters] characterAtIndex:0];
	} else {
		return NO;
	}
	
	/* Ignore all but the NSKeyDown */
	if ([theEvent type] != NSKeyDown) {
		return NO;
	}
	
	/* Make sure this event has the modifier flags this obj needs */
	if ([self modifierMask] == 0 &&
	    (([theEvent modifierFlags] & NSCommandKeyMask) ||
	     ([theEvent modifierFlags] & NSShiftKeyMask) ||
	     ([theEvent modifierFlags] & NSAlternateKeyMask)))
	{
		// We didn't want any modifiers, but one was there.
		return NO;
	} else if ([self modifierMask] == NSCommandKeyMask &&
		   !([theEvent modifierFlags] & NSCommandKeyMask))
	{
		// We wanted command, but it wasn't there.
		return NO;
	} else if ([self modifierMask] == NSShiftKeyMask &&
		   !([theEvent modifierFlags] & NSShiftKeyMask))
	{
		// We wanted shift, but it wasn't there.
		return NO;
	} else if ([self modifierMask] == NSAlternateKeyMask &&
		   !([theEvent modifierFlags] & NSAlternateKeyMask))
	{
		// We wanted Alt, but it wasn't there.
		return NO;
	}
	
	/* Check the keycode */
	if (kc == NSUpArrowFunctionKey && [self type] == ArrowButtonTypeUp) {
		[self performClick:self];
		return YES;
	} else if (kc == NSDownArrowFunctionKey && [self type] == ArrowButtonTypeDown) {
		[self performClick:self];
		return YES;
	} else if (kc == NSLeftArrowFunctionKey && [self type] == ArrowButtonTypeLeft) {
		[self performClick:self];
		return YES;
	} else if (kc == NSRightArrowFunctionKey && [self type] == ArrowButtonTypeRight) {
		[self performClick:self];
		return YES;
	} else {
		return NO;
	}
}

@end
