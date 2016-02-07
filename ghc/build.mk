SRC_HC_OPTS          = -H32m -O2 -fPIC
SRC_CC_OPTS          = -O2 -fPIC
GhcStage1HcOpts      = -O2 -fPIC
GhcStage2HcOpts      = -O2 -fPIC -fllvm -pgmlo=opt-3.6 -pgmlc=llc-3.6
GhcLibHcOpts         = -O2 -fPIC
SplitObjs            = NO
BeConservative       = YES
HADDOCK_DOCS         = NO
BUILD_DOCBOOK_HTML   = NO
BUILD_DOCBOOK_PS     = NO
BUILD_DOCBOOK_PDF    = NO
INTEGER_LIBRARY      = integer-simple
V                    = 0
