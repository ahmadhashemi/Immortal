@interface SBFLockScreenDateView : UIView
@end

@interface SBHomeScreenViewController : UIViewController

-(void)checkAndShowImmortalAlert;

@end

@interface ImmortalHandlers : NSObject

+(unsigned long long)getYaluEmbeddedProfileSize;
+(NSString *)getMatchingProfileWithSize:(unsigned long long)embeddedSize;
+(void)removeProfilesExecpt:(NSString *)yaluPath;

@end