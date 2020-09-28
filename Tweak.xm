#include "substrate.h"
#include <string>
#include <cstdio>
#include <mach-o/dyld.h>
#include <stdint.h>

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

struct Vec3 {

	float x, y, z;
};

struct Actor {};

struct LocalPlayer : public Actor {};

static uintptr_t** VTLocalPlayer;

UILabel* sc_text;

NSString *string;

static Vec3& (*Actor$getPos)(Actor*);

static int (*LocalPlayer_tickWorld)(LocalPlayer*, const uintptr_t&);
static int _LocalPlayer_tickWorld(LocalPlayer* self, const uintptr_t& tick) {

	string = [NSString stringWithFormat:@"x:%.5f y:%.5f z:%.5f", Actor$getPos(self).x, Actor$getPos(self).y, Actor$getPos(self).z];

	return LocalPlayer_tickWorld(self, tick);
}

static void (*Minecraft_startLeaveGame)(uintptr_t*, bool);
static void _Minecraft_startLeaveGame(uintptr_t* self, bool b1) {

	sc_text.hidden = YES;

	return Minecraft_startLeaveGame(self, b1);
}

static void (*MinecraftGame_onPlayerLoaded)(uintptr_t*, uintptr_t&, uintptr_t&);
static void _MinecraftGame_onPlayerLoaded(uintptr_t* self, uintptr_t& clientinst, uintptr_t& player) {

	sc_text.hidden = NO;

	return MinecraftGame_onPlayerLoaded(self, clientinst, player);
}

%ctor {
	VTLocalPlayer = (uintptr_t**)(0x103bfe870 + _dyld_get_image_vmaddr_slide(0));

	Actor$getPos = (Vec3&(*)(Actor*)) VTLocalPlayer[14];

	MSHookFunction((void*)(0x100b18a50 + _dyld_get_image_vmaddr_slide(0)), (void*)&_LocalPlayer_tickWorld, (void**)&LocalPlayer_tickWorld);
	MSHookFunction((void*)(0x10227b92c + _dyld_get_image_vmaddr_slide(0)), (void*)&_Minecraft_startLeaveGame, (void**)&Minecraft_startLeaveGame);
	MSHookFunction((void*)(0x1000bcbd4 + _dyld_get_image_vmaddr_slide(0)), (void*)&_MinecraftGame_onPlayerLoaded, (void**)&MinecraftGame_onPlayerLoaded);
}

@interface minecraftpeViewController: UIViewController {}
@end

%hook minecraftpeViewController
-(void)viewDidLoad {

	%orig;

	sc_text = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
	sc_text.text = string;
	sc_text.textColor = [UIColor whiteColor];
	[self.view addSubview:sc_text];

	sc_text.hidden = YES;
}

%end