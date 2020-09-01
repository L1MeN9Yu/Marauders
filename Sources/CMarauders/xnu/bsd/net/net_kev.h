#define    KEV_NETPOLICY_SUBCLASS  3    /* Network policy subclass */
/* KEV_NETPOLICY_SUBCLASS event codes */
#define    KEV_NETPOLICY_IFDENIED  1       /* denied access to interface */
#define    KEV_NETPOLICY_IFFAILED  2       /* failed to bring up interface */

#define    KEV_SOCKET_SUBCLASS     4    /* Socket subclass */
/* KEV_SOCKET_SUBCLASS event codes */
#define    KEV_SOCKET_CLOSED       1       /* completely closed by protocol */

#define    KEV_ND6_SUBCLASS    7    /* IPv6 NDP subclass */
/* KEV_ND6_SUBCLASS event codes */
#define    KEV_ND6_RA                      1
#define    KEV_ND6_NDFAILURE               2 /* IPv6 neighbor cache entry expiry */
#define    KEV_ND6_NDALIVE                 3 /* IPv6 neighbor reachable */

#define    KEV_NECP_SUBCLASS    8    /* NECP subclasss */
/* KEV_NECP_SUBCLASS event codes */
#define    KEV_NECP_POLICIES_CHANGED 1

#define    KEV_NETAGENT_SUBCLASS    9    /* Net-Agent subclass */
/* Network Agent kernel event codes */
#define    KEV_NETAGENT_REGISTERED                 1
#define    KEV_NETAGENT_UNREGISTERED               2
#define    KEV_NETAGENT_UPDATED                    3
#define    KEV_NETAGENT_UPDATED_INTERFACES         4

#define    KEV_LOG_SUBCLASS    10    /* Log subclass */
/* KEV_LOG_SUBCLASS event codes */
#define    IPFWLOGEVENT    0

#define    KEV_NETEVENT_SUBCLASS    11    /* Generic Net events subclass */
/* KEV_NETEVENT_SUBCLASS event codes */
#define    KEV_NETEVENT_APNFALLBACK                1

#define    KEV_ATALK_SUBCLASS               5
#define    KEV_MEMORYSTATUS_SUBCLASS        3
#define        KEV_IPFW_SUBCLASS            1
#define        KEV_IP6FW_SUBCLASS            2
#define    KEV_APPLE80211_EVENT_SUBCLASS    1
