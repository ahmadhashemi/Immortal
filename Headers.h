@interface SBHomeScreenViewController : UIViewController

-(unsigned long long)getYaluEmbeddedProfileSize;
-(NSString *)getMatchingProfileWithSize:(unsigned long long)embeddedSize;
-(void)removeProfilesExecpt:(NSString *)yaluPath;
-(void)checkAndShowImmortalAlert;

@end