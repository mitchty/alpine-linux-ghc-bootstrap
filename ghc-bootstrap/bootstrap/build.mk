SRC_HC_OPTS          = -H64m
SRC_CC_OPTS          = -O
GhcStage1HcOpts      = -O
GhcStage2HcOpts      = -O2 -fllvm -pgmlo=opt -pgmlc=llc
GhcLibHcOpts         = -O2 -fPIC
SplitObjs            = NO
BeConservative       = YES
HADDOCK_DOCS         = NO
BUILD_DOCBOOK_HTML   = NO
BUILD_DOCBOOK_PS     = NO
BUILD_DOCBOOK_PDF    = NO
V                    = 0
