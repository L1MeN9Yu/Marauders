//from xnu/osfmk/kern/ipc_kobject.h


#define IKOT_NONE                       0
#define IKOT_THREAD                     1
#define IKOT_TASK                       2
#define IKOT_HOST                       3
#define IKOT_HOST_PRIV                  4
#define IKOT_PROCESSOR                  5
#define IKOT_PSET                       6
#define IKOT_PSET_NAME                  7
#define IKOT_TIMER                      8
#define IKOT_PAGING_REQUEST             9
#define IKOT_MIG                        10
#define IKOT_MEMORY_OBJECT              11
#define IKOT_XMM_PAGER                  12
#define IKOT_XMM_KERNEL                 13
#define IKOT_XMM_REPLY                  14
#define IKOT_UND_REPLY                  15
#define IKOT_HOST_NOTIFY                16
#define IKOT_HOST_SECURITY              17
#define IKOT_LEDGER                     18
#define IKOT_MASTER_DEVICE              19
#define IKOT_TASK_NAME                  20
#define IKOT_SUBSYSTEM                  21
#define IKOT_IO_DONE_QUEUE              22
#define IKOT_SEMAPHORE                  23
#define IKOT_LOCK_SET                   24
#define IKOT_CLOCK                      25
#define IKOT_CLOCK_CTRL                 26
#define IKOT_IOKIT_IDENT                27
#define IKOT_NAMED_ENTRY                28
#define IKOT_IOKIT_CONNECT              29
#define IKOT_IOKIT_OBJECT               30
#define IKOT_UPL                        31
#define IKOT_MEM_OBJ_CONTROL            32
#define IKOT_AU_SESSIONPORT             33
#define IKOT_FILEPORT                   34
#define IKOT_LABELH                     35
#define IKOT_TASK_RESUME                36
#define IKOT_VOUCHER                    37
#define IKOT_VOUCHER_ATTR_CONTROL       38
#define IKOT_WORK_INTERVAL              39
#define IKOT_UX_HANDLER                 40
#define IKOT_UEXT_OBJECT                41
#define IKOT_ARCADE_REG                 42
/*
 * Add new entries here and adjust IKOT_UNKNOWN.
 * Please keep ipc/ipc_object.c:ikot_print_array up to date.
 */
#define IKOT_UNKNOWN                    43      /* magic catchall       */
#define IKOT_MAX_TYPE   (IKOT_UNKNOWN+1)        /* # of IKOT_ types	*/
