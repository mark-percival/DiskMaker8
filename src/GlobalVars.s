;          Global variables definition

TextLine:                             ; Text screen line starting addresses

TextLine00: .addr $0400
TextLine01: .addr $0480
TextLine02: .addr $0500
TextLine03: .addr $0580
TextLine04: .addr $0600
TextLine05: .addr $0680
TextLine06: .addr $0700
TextLine07: .addr $0780
TextLine08: .addr $0428
TextLine09: .addr $04A8
TextLine10: .addr $0528
TextLine11: .addr $05A8
TextLine12: .addr $0628
TextLine13: .addr $06A8
TextLine14: .addr $0728
TextLine15: .addr $07A8
TextLine16: .addr $0450
TextLine17: .addr $04D0
TextLine18: .addr $0550
TextLine19: .addr $05D0
TextLine20: .addr $0650
TextLine21: .addr $06D0
TextLine22: .addr $0750
TextLine23: .addr $07D0

; MLI Read Request - everyone uses these locations, but no one defined them...
readRequest:  .res 2
