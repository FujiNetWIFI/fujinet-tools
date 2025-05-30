        ;; Borrowed from NOS. Thanks Michael.
EOL    = $9B

FASC    =   $D8E6       ; Floating point to ASCII
IFP     =   $D9AA       ; Integer to floating point
FR0     =   $D4         ; Floating Point register 0 (used during Hex->ASCII conversion)

INBUFF = $0580

        .export _put_error

        ;; void __fastcall__ put_error(unsigned char errnum);
        
;---------------------------------------
; Print integer error number from DOSIOV
; Y: Return code from DOSIOV
;---------------------------------------
_put_error:
        TAY                     ; get parameter
        CPY     #$01        ; Exit if success (1)
        BEQ     PRINT_ERROR_DONE

PRINT_ERROR_NEXT:
    ;-----------------------------------
    ; Convert error code to ASCII
    ;-----------------------------------
    ; Call subroutines in ROM to convert error from int to ascii
        STY     FR0
        LDA     #$00
        STA     FR0+1
        JSR     IFP         ; Convert error from int to floating point
        JSR     FASC        ; Convert floating point to ASCII

    ;---------------------------------------
    ; Find last char in ASCII error (noted by high bit)
    ; Unset high bit & append EOL
    ;---------------------------------------
        LDY     #$FF        ; Init counter = 0
@:      INY
        LDA     INBUFF,Y
        CMP     #$80        ; Loop until high bit is set
        BCC     @-

        AND     #$7F        ; Clear high bit
        STA     INBUFF,Y
        INY
        LDA     #$9B        ; Append EOL
        STA     INBUFF,Y

        LDA     INBUFF
        LDY     INBUFF+1
        RTS                     ; INBUFF now contains error number

PRINT_ERROR_DONE:
        RTS

; End PRINTSCR
;---------------------------------------
