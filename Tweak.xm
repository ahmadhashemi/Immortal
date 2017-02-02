#import "./Headers.h"

static NSString *preferencesFilePath = @"/private/var/mobile/Library/Preferences/com.ahmad.immortal.plist";

%hook SBFLockScreenDateView

-(void)didMoveToSuperview {

    %orig;

    if (self.window) {
        return;
    }

    // get yalu embedded profile size
    unsigned long long embeddedSize = [ImmortalHandlers getYaluEmbeddedProfileSize];

    // get saved profile matching yalu embedded profile size
    NSString *yaluPath = [ImmortalHandlers getMatchingProfileWithSize:embeddedSize];

    // remove all saved profiles except yalu's
    [ImmortalHandlers removeProfilesExecpt:yaluPath];

}

%end

%hook SBHomeScreenViewController

-(void)viewDidAppear:(BOOL)animated {

	%orig;

    [self checkAndShowImmortalAlert];

}

%new
-(void)checkAndShowImmortalAlert {

    NSMutableDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesFilePath].mutableCopy;

    if (preferences && [[preferences objectForKey:@"ImmortalAlertShown"] isEqualToString:@"YES"]) {
        return;
    }

    NSString *title = @"Immortal is Active";
    NSString *message = [NSString stringWithFormat:@"You can now use applications forever.\n\nNote: If you got maxiumum 3 applications error while using Cydia Impactor, just lock & unlock your device, and then retry installation.\n\nJoin our telegram channel for further updates."];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Join Channel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        NSURL *url = [NSURL URLWithString:@"tg://resolve?domain=idevelop"];

        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            url = [NSURL URLWithString:@"http://telegram.me/idevelop"];
        }

        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

    }]];

    [self presentViewController:alert animated:YES completion:nil];


    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    [preferences setObject:@"YES" forKey:@"ImmortalAlertShown"];

    [preferences writeToFile:preferencesFilePath atomically:YES];

}

%end

@implementation ImmortalHandlers

+(long long unsigned)getYaluEmbeddedProfileSize {

    NSString *appsPath = @"/var/containers/Bundle/Application";
    NSArray *appNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appsPath error:nil];
    NSString *yaluProvisioningPath = @"";
    
    for (NSString *appName in appNames) {

        NSString *appFolderPath = [appsPath stringByAppendingPathComponent:appName];

        NSString *machPortalPath = [appFolderPath stringByAppendingPathComponent:@"mach_portal.app/embedded.mobileprovision"]; // for yalu 10(.1(.1))

        if ([[NSFileManager defaultManager] fileExistsAtPath:machPortalPath]) {
            yaluProvisioningPath = machPortalPath;
            break;
        }

        NSString *yaluPath = [appFolderPath stringByAppendingPathComponent:@"yalu102.app/embedded.mobileprovision"]; // for yalu 10.2

        if ([[NSFileManager defaultManager] fileExistsAtPath:yaluPath]) {
            yaluProvisioningPath = yaluPath;
            break;
        }

    }

    if ([yaluProvisioningPath isEqualToString:@""]) {
        return 0;
    }

    return [[[NSFileManager defaultManager] attributesOfItemAtPath:yaluProvisioningPath error:nil] fileSize];

}

+(NSString *)getMatchingProfileWithSize:(unsigned long long)embeddedSize {

    if (embeddedSize == 0) {
        return @"";
    }

    NSString *profilesPath = @"/var/MobileDevice/ProvisioningProfiles";
    NSString *profilePath = @"";
    
    NSArray *profileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:profilesPath error:nil];
    
    for (NSString *profileName in profileNames) {

        NSString *checkPath = [profilesPath stringByAppendingPathComponent:profileName];
        unsigned long long checkSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:checkPath error:nil] fileSize];

        if (checkSize == embeddedSize) {
            profilePath = checkPath;
            break;
        }
        
    }

    return profilePath;

}

+(void)removeProfilesExecpt:(NSString *)yaluPath {

    NSString *profilesPath = @"/var/MobileDevice/ProvisioningProfiles";
    NSArray *profileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:profilesPath error:nil];

    for (NSString *profileName in profileNames) {

        NSString *profilePath = [profilesPath stringByAppendingPathComponent:profileName];

        if ([profilePath isEqualToString:yaluPath]) {
            continue;
        }

        [[NSFileManager defaultManager] removeItemAtPath:profilePath error:nil];

    }

}

@end
