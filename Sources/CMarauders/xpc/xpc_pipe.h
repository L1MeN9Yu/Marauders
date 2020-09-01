#import <TargetConditionals.h>

#if TARGET_OS_IPHONE

#include "xpc.h"

#else
#include <xpc/xpc.h>
#endif

// Declare private types.
typedef struct _xpc_pipe_s *xpc_pipe_t;

// Pipe methods.
xpc_pipe_t xpc_pipe_create_from_port(mach_port_t port, int flags);

int xpc_pipe_receive(mach_port_t port, xpc_object_t *message);

int xpc_pipe_routine(xpc_pipe_t pipe, xpc_object_t request, xpc_object_t *reply);

int xpc_pipe_routine_reply(xpc_object_t reply);

int xpc_pipe_simpleroutine(xpc_pipe_t pipe, xpc_object_t message);

int xpc_pipe_routine_forward(xpc_pipe_t forward_to, xpc_object_t request);
