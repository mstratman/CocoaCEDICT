#import <Cocoa/Cocoa.h>

/* Instructions:
   1) Add ArrowButton.h and ArrowButton.C to your project.
   2) #import "ArrowButton.h" where it'll be needed.
   3) in Interface Builder, make a subclass of  NSButton called ArrowButton; 
      set your  button's "Custom Class" to ArrowButton
   4) In an awakeFromNib, invoke  [theButton setType:aType] where theButton is 
      an outlet to your button and  aType is one of ArrowButtonTypeLeft,  
      ArrowButtonTypeRight,  ArrowButtonTypeUp, or ArrowButtonTypeDown
   5) If you require a modifer, invoke [theButton setModifierMask:modifierMask] 
      where modifierMask is one of NSShiftKeyMask, NSAlternateKeyMask, or
      NSCommandKeyMask.  It is important that you use this method instead of
      NSButton's setKeyEquivalentModifierMask: so the object knows how to parse
      and handle the event, which is critical if you want, for example, a
      button that handles the right arrow, and a button that handles 
      command + the right arrow.
*/


/* Reasoning for this class: */
/* We have to subclass NSButton (particularly performKeyEquivalent:) because */
/* otherwise key equivalents that are arrows get triggered on NSKeyUp and    */
/* NSKeyDown.  So we override performKeyEquivalent: to ignore KeyUp's.       */

#define ArrowButtonTypeNotSet 0
#define ArrowButtonTypeLeft   1
#define ArrowButtonTypeRight  2
#define ArrowButtonTypeUp     3
#define ArrowButtonTypeDown   4

@interface ArrowButton : NSButton 
{
	int _type;
	int _modifierMask;
}
- (unsigned int) type;
- (void) setType:(unsigned int)newType;
- (unsigned int) modifierMask;
- (void) setModifierMask:(unsigned int)mask;

@end
