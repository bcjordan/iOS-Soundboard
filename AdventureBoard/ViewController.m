//
//  ViewController.m
//  AdventureBoard
//
//  Created by Brian Jordan on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize someLabel, volume, finn, _soundPlayers;

-(IBAction)sliderChanged:(id)sender
{
    UISlider *slider = (UISlider *) sender;
    int sliderValue = [[NSNumber numberWithFloat: slider.value*10] intValue];

    NSLog(@"Volume changed to %f (displaying as %d)", slider.value, sliderValue);

    for (AVAudioPlayer *player in _soundPlayers.allValues) {
        [player setVolume:slider.value];
    }

    [volume setText: [NSString stringWithFormat:@"%d", sliderValue]];
    CGPoint finnPoint = slider.center;
    finnPoint.x = finnPoint.x + slider.value * 350 - 150;
    finnPoint.y = 815;
    [finn setCenter:finnPoint];
    [someLabel setText:[NSString stringWithFormat:@"Volume %d? Great job.", sliderValue]];
}

-(IBAction)aboutThisApp:(id)sender
{
    UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"AdventureBoard"
                                                  message:@"Thanks for givin' AdventureBoard some love.\nSay hi!\nb.jordan@tufts.edu"
                                                 delegate:self
                                        cancelButtonTitle:@"Algebraic!"
                                        otherButtonTitles:nil, nil];
    [view show];
}

-(IBAction)buttonTriggered:(id)sender
{
    UIButton *theButton = (UIButton *) sender;
    NSLog(@"You pressed the button %@", theButton.currentTitle);

    if( [theButton.currentTitle isEqualToString:@"Click me!"]){
        [[[UIAlertView alloc] initWithTitle:@"You bozo" message:@"You're stupid" delegate:self cancelButtonTitle:@"ok, I'll fix it" otherButtonTitles:nil] show];
    }
    else if ([theButton.currentTitle isEqualToString:@"Second button!"]){
        AVAudioPlayer *play = [_soundPlayers valueForKey:@"Quack!"];
        if (play != nil){
            [play play];
            NSLog(@"Sound should have played by now.");
        } else {
            NSLog(@"Player did not initialize properly.");
        }
    }
    else if ([theButton.currentTitle isEqualToString:@"Change me!"]) {
        NSLog(@"Entering conditional.");
//        if(player != nil) {
//            [player play];
//            [someLabel setText:@"QUACK!"];
//
//            NSLog(@"Sound effect has been played");
//        } else {
//            NSLog(@"Player did not initialize properly");
//        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Construct audio loading error
    NSError *error;

    [super viewDidLoad];

    // Use hash of filenames to titles to build soundboard buttons
    NSMutableDictionary *textToFilename = [NSMutableDictionary dictionary];

//    NSArray* soundClips = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp3" inDirectory:nil];
//    NSLog(@"%@", soundClips);

    // Build hash using files from |SOUND_DIR| directory
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [manager enumeratorAtPath:bundleRoot];

    NSString *fileName;
    NSString *title;

    while((fileName = [directoryEnumerator nextObject])) {
        NSLog(@"Adding file %@", fileName);
        if([fileName hasSuffix:@".mp3"] || [fileName hasSuffix:@".wav"]){
            title = [[fileName stringByReplacingOccurrencesOfString:@".mp3" withString:@""]
                               stringByReplacingOccurrencesOfString:@".wav" withString:@""];
            [textToFilename setValue:fileName forKey:title];
        }
    }

    const float INIT_X = 50.0;
    const float INIT_Y = 250.0;
    const float BUTTON_WIDTH = 200.0;
    const float BUTTON_HEIGHT = 100.0;
    const float COL_MARGIN = 20.0;
    const float ROW_MARGIN = 20.0;
    const int BUTTONS_PER_ROW = 3;
    const float BUTTON_FONT_SIZE = 70.0;
    
    int row = 0;
    int col = 0;

    _soundPlayers = [NSMutableDictionary dictionaryWithCapacity:[textToFilename count]];

    for (NSString *title in [textToFilename allKeys]) {
        // Construct |AVAudioPlayer| with sound file
        NSString *fileName = [textToFilename valueForKey:title];
        NSURL *urlPathOfAudio = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                                                                  [[NSBundle mainBundle] resourcePath],
                                                                                  fileName]];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPathOfAudio error:&error];
        [player prepareToPlay];
        [_soundPlayers setValue:player forKey:title];
        NSLog(@"Loaded %@ with description %@", fileName, title);

        // Construct titled button, given current row and col
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        newButton.frame = CGRectMake(
                INIT_X + col * (COL_MARGIN + BUTTON_WIDTH),
                INIT_Y + row * (ROW_MARGIN + BUTTON_HEIGHT),
                BUTTON_WIDTH,
                BUTTON_HEIGHT);
        [newButton setTitle:title forState:UIControlStateNormal];
        newButton.titleLabel.font = [UIFont systemFontOfSize:BUTTON_FONT_SIZE];
        newButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [newButton addTarget:self action:@selector(playAudioForTitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:newButton];
        [self.view sendSubviewToBack:newButton];

        // Calculate next row/col
        if(col >= (BUTTONS_PER_ROW - 1)){
            row++;
            col = 0;
        } else {
            col++;
        }

        NSLog(@"Constructed button %@ at col %i row %i", title, col, row);
    }

    // TODO: Show an animated gif for fun
    // Use method from http://www.alterplay.com/ios-dev-tips/2010/12/making-gif-animating-on-ios.html
}

- (IBAction)playAudioForTitle:(id)sender;
{
    UIButton *button = (UIButton *)sender;
    NSString *title = button.currentTitle;
    AVAudioPlayer *player = [_soundPlayers valueForKey:title];
    if (player != nil) {
        [player play];
    } else {
        NSLog(@"Could not play audio for button %@", title);
    }
    NSLog(@"Playing audio for button %@", title);

    [someLabel setText:title];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
