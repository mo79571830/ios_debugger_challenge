#include "debugger_ptrace.h"

@implementation YDDebuggerPtrace

+ (void) warning {
    NSLog(@"[*]🐝⚠️ if a debugger attached, expect a segment fault or exit");
}

/* check Parent loaded name. Trying to detect Frida-Trace */
/* FAILED -> frida-trace still return a ppid of 1 on jailbroken 11.4 device */

+(BOOL)checkParent{
    
    NSProcessInfo *process = [NSProcessInfo processInfo];
    NSString *name = [process processName];

    pid_t pid = getpid();
    pid_t parentpid = getppid();
    NSLog(@"[*]🐝Process Name: '%@'\tProcess ID:'%d'\tParent'%d'\t%@", name, pid, parentpid, [process hostName]);
    
    #if defined(__arm64__)
        return parentpid != 1 ? YES : NO;
    //MARK: broken. Unsure if it is possible to get parent processes name on __x86_64__
    #elif defined(__x86_64__)
        NSLog(@"[*]🐝: Work in progress -> the same getppid  does NOT work on an iOS Simulator\t%@");
    #endif
    
    return NO;
}

+ (BOOL) setPtraceWithASM {
    [self warning];
    NSString *message;
    BOOL flag = true;

    #if defined(__arm64__)
        message = @"ptrace for __arm64__";
        __asm(
            "mov x0, #26\n"             // ptrace
            "mov x1, #31\n"             // PT_DENY_ATTACH
            "mov x2, #0\n"
            "mov x3, #0\n"
            "mov x16, #0\n"
            "svc #128\n"
        );
    #elif defined(__x86_64__)
        message = @"ptrace for __x86_64__";
        int result, data = 0;
        pid_t pid = 0;
        caddr_t addr = 0;
        errno = 0;
        result = syscall(SYS_ptrace, 31, pid, addr, data);
        NSString *tempresult = [NSString stringWithFormat:@"ptrace result: %d\t Error: %d", result, errno ];
        message = [message stringByAppendingString:tempresult];
    #else
        message = @"Unknown target.";
    #endif

    flag = false;       // if a debugger was attached, it would have crashed
    NSLog(@"%@", message);
    return flag;
}

+ (BOOL) setPtraceWithSymbol{
    [self warning];
    BOOL ptrace_detected = false;
    
    /* dynamically link the ptrace symbol at runtime on iOS */
    ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(RTLD_SELF, PTRACE_NAME);
    int x = ptrace_ptr(31, 0, 0, 0); // PTRACE_DENY_ATTACH = 31

    NSLog(@"ptrace result handle: %d", x);
    return ptrace_detected;
}

@end
