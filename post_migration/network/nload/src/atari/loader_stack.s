        .export clear_menu
        .export load_setup
        .export load_init
        .export dosiov_status
        .export dosiov_read
        .export dosiov_close
        .export bindcb
        .export clodcb
        .export stadcb

        .include "atari.inc"

.segment "LSTACK"

clear_menu:    
    	lda     #$00
        tax
    	ldy     #$b8
cloop:	sta     $0700,x
    	inx
    	bne     cloop
    	inc     cloop+2  ; increasing HI-byte of the clearing address
    	dey
    	bne     cloop
	rts

load_setup:
        LDA     #$C0
        STA     RUNAD
        LDA     #$E4
        STA     RUNAD+1
        RTS

load_init:
        LDA     #$C0
        STA     INITAD
        LDA     #$E4
        STA     INITAD+1
        RTS

dosiov_close:
        LDA     #<clodcb
        sta     dodcbl+1
        LDA     #>clodcb        ; never zero as we're on the stack
        sta     dodcbl+2
        bne     siov_copy_go

dosiov_status:
        LDA     #<stadcb
        sta     dodcbl+1
        LDA     #>stadcb        ; never zero as we're on the stack
        sta     dodcbl+2
        bne     siov_copy_go

dosiov_read:
        LDA     #<bindcb
        sta     dodcbl+1
        LDA     #>bindcb
        sta     dodcbl+2
        ; fall through

siov_copy_go:
        LDY     #$0B
dodcbl: LDA     $FFFF,Y
        STA     DCB,Y
        DEY
        BPL     dodcbl

SIOVDST:
        JMP     SIOV

stadcb:
        .BYTE   $71         ; DDEVIC
        .BYTE   $01         ; DUNIT
        .BYTE   'S'         ; DCOMND
        .BYTE   $40         ; DSTATS
        .BYTE   <DVSTAT     ; DBUFL
        .BYTE   >DVSTAT     ; DBUFH
        .BYTE   $0F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $04         ; DBYTL
        .BYTE   $00         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

clodcb:
        .BYTE   $71         ; DDEVIC
        .BYTE   $01         ; DUNIT
        .BYTE   'C'         ; DCOMND
        .BYTE   $00         ; DSTATS
        .BYTE   $00         ; DBUFL
        .BYTE   $00         ; DBUFH
        .BYTE   $0F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $00         ; DBYTL
        .BYTE   $00         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

bindcb:
        .BYTE   $71         ; DDEVIC
        .BYTE   $01         ; DUNIT
        .BYTE   'R'         ; DCOMND
        .BYTE   $40         ; DSTATS
        .BYTE   $FF         ; DBUFL
        .BYTE   $FF         ; DBUFH
        .BYTE   $0F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $FF         ; DBYTL
        .BYTE   $FF         ; DBYTH
        .BYTE   $FF         ; DAUX1
        .BYTE   $FF         ; DAUX2
