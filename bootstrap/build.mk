SRC_HC_OPTS          = -H64m -O0 -fPIC
SRC_CC_OPTS          = -O0 -fPIC
GhcStage1HcOpts      = -O -fPIC
GhcStage2HcOpts      = -O2 -fPIC
GhcLibHcOpts         = -O -fPIC
GhcHcOpts            = -Rghc-timing
SplitObjs            = NO
BeConservative       = YES
HADDOCK_DOCS         = NO
BUILD_DOCBOOK_HTML   = NO
BUILD_DOCBOOK_PS     = NO
BUILD_DOCBOOK_PDF    = NO
INTEGER_LIBRARY      = integer-simple
DYNAMIC_BY_DEFAULT   = NO
DYNAMIC_GHC_PROGRAMS = NO
V                    = 0
