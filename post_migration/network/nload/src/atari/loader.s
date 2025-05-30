        .export _load_app

        .import _nuke_memory
        .import clear_menu
        .import load_setup
        .import load_init
        .import dosiov_status
        .import dosiov_read
        .import bindcb
        .import clodcb
        .import stadcb

        .include "atari.inc"

.struct IO_DCB
        .org $0300
        ddevic  .byte
        dunit   .byte
        dcomnd  .byte
        dstats  .byte
        dbuflo  .byte
        dbufhi  .byte
        dtimlo  .byte
        dunuse  .byte
        dbytlo  .byte
        dbythi  .byte
        daux1   .byte
        daux2   .byte
.endstruct

.segment "LOADER"

_load_app:
        CLI                     ; Why, DOS 2? WHY?!
        JSR     SAVE_UNITID
        JSR     LOAD_READ2
        JSR     LOAD_CHKFF
        CPY     #$01
        BNE     R

        LDA     _nuke_memory    ; Check _nuke_memory set in core.c
        BEQ     noclear         ; If 0, skip over clear_menu
        JSR     clear_menu      ; Otherwise nuke RAM from orbit.
noclear:
        JSR     load_setup

        INC     BIN_1ST
        ; Process each payload
GETFIL: JSR     LOAD_READ2      ; Get two bytes (binary header)
        BMI     R               ; Exit if EOF hit
        JSR     load_init       ; Set init default
        LDX     #$01
        JSR     LOAD_CHKFF      ; Check if header (and start addr, too)
        JSR     LOAD_STRAD      ; Put start address in
        JSR     LOAD_READ2      ; Get to more butes (end addr)
        JSR     LOAD_ENDAD      ; Put end address in
        JSR     LOAD_BUFLEN     ; Calculate buffer length
        JSR     LOAD_GETDAT     ; Get the data record
        BPL     @+              ; was EOF detected?
        JSR	JSTART		; Yes, go to runad.
@:	JSR	JINIT           ; Attempt Init.
        JMP     GETFIL          ; Process next payload

JINIT:  JMP     (INITAD)        ; Will either RTS or perform INIT
JSTART: JMP     (RUNAD)         ; Godspeed.
R:      RTS                     ; Stunt-double for (INITAD),(RUNAD)

;---------------------------------------
SAVE_UNITID:
;---------------------------------------
    ; The application is expected to have opened the device before calling the loader, and setting dunit in this process.
    ; We need to honour that id in the DCB blocks the loader uses.
        LDA     IO_DCB::dunit
        STA     bindcb + IO_DCB::dunit - DCB
        STA     clodcb + IO_DCB::dunit - DCB
        STA     stadcb + IO_DCB::dunit - DCB
        RTS

;---------------------------------------
LOAD_READ2:
;---------------------------------------

    ;---------------------------------------
    ; This is accomplished by abusing the LOAD_GETDAT
    ; routine by stuffing the buffer addr (BAL/H)
    ; into the payload Start/End addrs. We're doing
    ; this in case a payload  header straddles a
    ; cache boundary. LOAD_GETDAT has the logic for
    ; dealing with that.
    ;---------------------------------------
        LDA     #<BAL
        STA     STL         ; Payload start address
        LDA     #>BAL
        STA     STH

        LDA     #<BAH
        STA     ENL         ; Payload end address
        LDA     #>BAH
        STA     ENH

        LDX     #$02
        STX     BLL         ; Payload size (2)
        LDA     #$00
        STA     BLH

        JMP     LOAD_GETDAT ; Read 2 bytes

;---------------------------------------
LOAD_CHKFF:
;---------------------------------------
    ; On 1st pass, check for binary signature (FF FF)
    ; On 2..n passes, Skip FF FF (if found)
    ; and read next 2 bytes
    ;---------------------------------------

        LDA     BAL         ; Is 1st byte FF?
        AND     BAH         ; Is 2nd byte FF?
        CMP     #$FF
        BNE     NOTFF       ; If no, skip down.

    ;---------------------------------------
    ; Here if FF FF tags found.
    ; On 1st pass, we're done.
    ; On 2..n passes, read next 2 bytes and leave.
    ;---------------------------------------
        CMP     BIN_1ST     ; Is this 1st pass?
        BEQ     NOTFF_DONE  ; If yes, then we're done here.
        JMP     LOAD_READ2  ;

    ;---------------------------------------
    ; Here if FF FF tags NOT found.
    ; On 1st pass, print error.
    ; On 2..n passes, the 2 bytes = payload start addr.
    ;---------------------------------------
NOTFF:  LDY     #$01        ; Preload success return code
        CMP     BIN_1ST     ; A still has FF. BIN_1ST = FF on first pass
        BNE     NOTFF_DONE  ; Not 1st pass, exit with success.

        LDY     #$FF        ; Return failure
NOTFF_DONE:
        RTS

;---------------------------------------
LOAD_STRAD:
;---------------------------------------
    ; Save payload start address into STL2/STLH2.
    ; Otherwise it will get clobbered
    ; when reading payload end address.
        LDA     BAL
        STA     STL2
        LDA     BAH
        STA     STH2
        RTS

;---------------------------------------
LOAD_ENDAD:
;---------------------------------------
    ; Save payload end address
        LDA     STL2
        STA     STL
        LDA     STH2
        STA     STH

        LDA     BAL
        STA     ENL
        LDA     BAH
        STA     ENH
        RTS

;---------------------------------------
LOAD_BUFLEN:
;---------------------------------------
    ; Calculate buffer length (end-start+1)

    ; Calc buffer size Lo
        LDA     ENL
        SEC
        SBC     STL
        STA     BLL     ; Buffer Length Lo

    ; Calc buffer size Hi
        LDA     ENH     ; Calc buffer size Hi
        SBC     STH
        STA     BLH     ; Buffer Length Hi

    ; Add 1
        CLC
        LDA     BLL
        ADC     #$01
        STA     BLL

        LDA     BLH
        ADC     #$00    ; Take care of any carry
        STA     BLH

        RTS

;---------------------------------------
LOAD_GETDAT:
;---------------------------------------
    ; Definitions:
    ; HEAD = requested bytes that will be found in current cache (< 512 bytes)
    ; BODY = contiguous 512 byte sections. BODY = n * 512 bytes)
    ; TAIL = any bytes remaining after BODY (< 512 bytes)

        JSR     GETDAT_CHECK_EOF    ; Check EOF before proceeding
        BPL     GETDAT_NEXT1        ; If true, then EOF found. Exit
        RTS

    ; Check if bytes requested BL < DVSTAT (bytes waiting in cache)
GETDAT_NEXT1:
        LDA     DVSTAT
        CMP     BLL
        LDA     DVSTAT+1
        SBC     BLH
        BCS     GETDAT_OPT2     ; BL <= BW (bytes waiting)

GETDAT_OPT1:
    ;--------------------------------
    ; Here if bytes requested > bytes
    ; remaining in cache
    ;--------------------------------

    ;-------------------------------
    ; Head = BW (bytes waiting)
    ;-------------------------------
        LDA     DVSTAT
        STA     HEADL
        LDA     DVSTAT+1
        STA     HEADH

    ;-------------------------------
    ; Tail = (BL - HEAD) mod 512
    ;-------------------------------
        SEC
        LDA     BLL
        SBC     HEADL
        AND     #$FF
        STA     TAILL
        LDA     BLH
        SBC     HEADH
        AND     #$01
        STA     TAILH

    ;-----------------------------------
    ; Body = BL - HEAD - TAIL
    ;-----------------------------------
        ; 1. Body = BL - HEAD
        ;-------------------------------
        SEC
        LDA     BLL
        SBC     HEADL
        STA     BODYL
        LDA     BLH
        SBC     HEADH
        STA     BODYH

        ;-------------------------------
        ; 2. Body = Body - HEAD
        ;-------------------------------
        SEC
        LDA     BODYL
        SBC     TAILL
        STA     BODYL
        LDA     BODYH
        SBC     TAILH
        STA     BODYH

        JMP     GETDAT_READ

GETDAT_OPT2:
    ;--------------------------------
    ; Here if bytes requested <= bytes
    ; remaining in cache
    ;--------------------------------
    ; Head = BL, TAIL = BODY = 0
    ;--------------------------------
        LDA     BLL
        STA     HEADL
        LDA     BLH
        STA     HEADH
        LDA     #$00
        STA     TAILL
        STA     TAILH
        STA     BODYL
        STA     BODYH

;---------------------------------------
GETDAT_READ:
;---------------------------------------
    ;---------------------------------------
    ; Read HEAD bytes
    ;---------------------------------------
        LDA     HEADL
        STA     BLL
        LDA     HEADH
        STA     BLH
        JSR     GETDAT_DOSIOV
        BPL     GETDAT_BODY ; Skip ahead if no problems
        RTS                 ; Bail if error

    ;---------------------------------------
    ; Read BODY bytes
    ;---------------------------------------
GETDAT_BODY:
        LDX     BODYH
GETDAT_BODY_LOOP:
        BEQ     GETDAT_TAIL ; Skip if less than a page to read

        LDA     #$00
        STA     BLL         ; Buffer length
        LDA     #$02        ; 512 bytes at a time
        STA     BLH

        TXA                 ; Stash our loop index (X)
        PHA                 ; onto the stack
        JSR     GETDAT_DOSIOV
        BPL     :+          ; Skip ahead if no problems
        PLA                 ; Here if problem. Clean up stack
        TYA                 ; Reset N status flag before returning
        RTS                 ; Bail if error

:       PLA                 ; Retrieve our loop index
        TAX                 ; and xfer it back into X
        DEX                 ; -2 (we pull 0200 bytes at a time)
        DEX                 ;
        BNE     GETDAT_BODY_LOOP

GETDAT_TAIL:
    ;---------------------------------------
    ; Read TAIL bytes
    ;---------------------------------------
        LDA     TAILL
        STA     BLL
        LDA     TAILH
        STA     BLH

;---------------------------------------
GETDAT_DOSIOV:
;---------------------------------------
    ; Bail if BL = 0
        LDA     BLL
        ORA     BLH
        BEQ     CHECK_EOF_DONE

    ; SIO READ
        LDA     STL
        STA     bindcb + IO_DCB::dbuflo - DCB    ; Start Address Lo
        LDA     STH
        STA     bindcb + IO_DCB::dbufhi - DCB    ; Start Address Hi
        LDA     BLL
        STA     bindcb + IO_DCB::dbytlo - DCB    ; Buffer Size Lo
        STA     bindcb + IO_DCB::daux1 - DCB
        LDA     BLH
        STA     bindcb + IO_DCB::dbythi - DCB    ; Buffer Size Hi
        STA     bindcb + IO_DCB::daux2 - DCB

    ;---------------------------------------
    ; Send Read request to SIO
    ;---------------------------------------
        JSR     dosiov_read

    ;---------------------------------------
    ; Advance start address by buffer length
    ;---------------------------------------
        CLC
        LDA     STL
        ADC     BLL
        STA     STL

        LDA     STH
        ADC     BLH
        STA     STH

GETDAT_CHECK_EOF:
    ; Get status (updates DVSTAT, DSTATS)
        JSR     dosiov_status

    ; Return -1 if DVSTAT == $0000 and DVSTAT+3 == EOF
        LDA     DVSTAT
        BNE     CHECK_EOF_DONE

        LDA     DVSTAT+1
        BNE     CHECK_EOF_DONE

        LDA     #EOFERR         ; 136 defined in atari.inc
        CMP     DVSTAT+3        ; Is it EOF
        BNE     CHECK_EOF_DONE  ; No? Go to success
        LDY     #$FF            ; Yes? Return -1
        RTS

CHECK_EOF_DONE:
        LDY     #$01        ; Return success
        RTS


; these have to be part of the LOADER segment
VARSPACE:
BAL:            .res 1  ; 00
BAH:            .res 1  ; 01
STL:            .res 1  ; 02 ; Payload Start address
STH:            .res 1  ; 03
ENL:            .res 1  ; 04 ; Payload End address
ENH:            .res 1  ; 05
HEADL:          .res 1  ; 06 ; Bytes read from existing cache
HEADH:          .res 1  ; 07
BODYL:          .res 1  ; 08 ; Total bytes read in contiguous 512-byte blocks
BODYH:          .res 1  ; 09
BLL:            .res 1  ; 0A ; Payload Buffer Length
BLH:            .res 1  ; 0B
TAILL:          .res 1  ; 0C ; Bytes read from last cache
TAILH:          .res 1  ; 0D
STL2:           .res 1  ; 0E ; Payload Start address (working var)
STH2:           .res 1  ; 0F

BIN_1ST:        .byte $FF    ; Flag for binary loader signature (FF -> 1st pass)
