#import "ViewController.h"
#import "LMPortCheck.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *textFieldHost;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSTextField *textFieldTimeout;
@property (weak) IBOutlet NSButton *buttonConnect;
@property (weak) IBOutlet NSImageView *imageViewStatus;

@end

@implementation ViewController

- (IBAction)buttonConnect_action:(id)sender
{
	self.buttonConnect.enabled = NO;
	self.imageViewStatus.toolTip = @"Connecting…";
	self.imageViewStatus.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
	
	__weak ViewController* weakSelf = self;
	
	[LMPortCheck connectToHost:self.textFieldHost.stringValue
						  port:self.textFieldPort.integerValue
					   timeout:self.textFieldTimeout.doubleValue
			 completionHandler:^(BOOL success, NSError * _Nullable error) {
		NSString* tooltipText = @"";
		NSImageName imageName;
		
		if (success) {
			tooltipText = @"Success";
			imageName = NSImageNameStatusAvailable;
		} else {
			tooltipText = error.localizedDescription;
			imageName = NSImageNameStatusUnavailable;
			
			if (!tooltipText ||
				[tooltipText isEqualToString:@""]) {
				tooltipText = @"Unknown Error";
			}
		}
		
		if (!tooltipText) {
			tooltipText = @"Unknown";
		}
		
		weakSelf.imageViewStatus.toolTip = tooltipText;
		weakSelf.imageViewStatus.image = [NSImage imageNamed:imageName];
		
		weakSelf.buttonConnect.enabled = YES;
	}];
}

@end
