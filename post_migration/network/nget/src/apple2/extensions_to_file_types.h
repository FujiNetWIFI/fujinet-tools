/**
 * @brief Table of extensions to file types
 */

#include <stdint.h>

#ifndef EXTENSIONS_TO_FILETYPES_H
#define EXTENSIONS_TO_FILETYPES_H

struct _extensions_to_filetypes
{
  const char *extension;
  uint8_t fileType;
  uint16_t auxType;
} extensionsToFiletypes[] =
  {
    {".UNK",0x00,0x0000}, // Unknown
    {".BAD",0x01,0x0000}, // Bad block
    {".PCD",0x02,0x0000}, // Pascal Code
    {".PTX",0x03,0x0000}, // Pascal Text
    {".TXT",0x04,0x0000}, // ASCII Text
    {".PDA",0x05,0x0000}, // Pascal Data
    {".BIN",0x06,0x0000}, // Binary File
    {".FNT",0x07,0x0000}, // Apple /// font
    {".FOT",0x08,0x0000}, // HiRes/Double HiRes Graphics
    {".BA3",0x09,0x0000}, // Apple /// BASIC Program
    {".DA3",0x0A,0x0000}, // Apple /// BASIC Data
    {".WPF",0x0B,0x0000}, // Generic Word Processing File
    {".SOS",0x0C,0x0000}, // Apple /// SOS System File
    {".DIR",0x0F,0x0000}, // ProDOS Directory
    {".RPD",0x10,0x0000}, // RPS Data
    {".RPI",0x11,0x0000}, // RPS Index
    {".AFD",0x12,0x0000}, // AppleFile Discard
    {".AFM",0x13,0x0000}, // AppleFile Model
    {".AFR",0x14,0x0000}, // AppleFile Report
    {".SCL",0x15,0x0000}, // Screen Library
    {".PFS",0x16,0x0000}, // PFS Document
    {".ADB",0x19,0x0000}, // AppleWorks Database
    {".AWP",0x1A,0x0000}, // AppleWorks Word Processing
    {".ASP",0x1B,0x0000}, // AppleWorks Spreadsheet
    {".TDM",0x20,0x0000}, // Desktop Manager File
    {".IPS",0x21,0x0000}, // Instant Pascal Source
    {".UPV",0x22,0x0000}, // UCSD Pascal Volume
    {".3SD",0x29,0x0000}, // Apple /// SOS Directory
    {".8SC",0x2A,0x0000}, // Source Code
    {".8OB",0x2B,0x0000}, // Object Code
    {".8IC",0x2C,0x8003}, // Apex Program File
    {".8LD",0x2D,0x0000}, // Language Data
    {".P8C",0x2E,0x0000}, // ProDOS 8 Code Module
    {".OCR",0x41,0x0000}, // OCR File
    {".FTD",0x42,0x0000}, // File Type Definitions
    {".GWP",0x50,0x0000}, // Apple IIgs Word Processing
    {".GSS",0x51,0x8010}, // Apple IIgs Spreadsheet
    {".GDB",0x52,0x8010}, // Apple IIgs Database
    {".DRW",0x53,0x8010}, // Apple IIgs Drawing
    {".GDP",0x54,0x8010}, // Apple IIgs Desktop Publishing
    {".HMD",0x55,0x0001}, // HyperCard GS
    {".EDU",0x56,0x0000}, // Educational Program Data
    {".STN",0x57,0x0000}, // Stationary
    {".HLP",0x58,0x0000}, // Help File
    {".COM",0x59,0x8010}, // Communications
    {".CFG",0x5A,0x0000}, // Configuration File (CFG)
    {".ANM",0x5B,0x0000}, // Animation
    {".MUM",0x5C,0x0000}, // Multimedia
    {".ENT",0x5D,0x0000}, // Entertainment
    {".DVU",0x5E,0x0000}, // Development Utility
    {".PRE",0x60,0x0000}, // PC Transporter Pre-Boot
    {".NCF",0x66,0x0000}, // PC Transporter File Navigator Command File
    {".BIO",0x6B,0x0000}, // PC Transporter BIOS
    {".DVR",0x6D,0x0000}, // PC Transporter Driver
    {".HDV",0x6F,0x0000}, // PC Transporter Hard Disk Image
    {".GES",0x80,0x0000}, // GEOS System File
    {".GEA",0x81,0x0000}, // GEOS Desk Accessory
    {".GEO",0x82,0x0000}, // GEOS Application
    {".GED",0x83,0x0000}, // GEOS Document
    {".GEF",0x84,0x0000}, // GEOS Font
    {".GEP",0x85,0x0000}, // GEOS Printer Driver
    {".GEI",0x86,0x0000}, // GEOS Input Driver
    {".GEX",0x87,0x0000}, // GEOS Auxiliary Driver
    {".GEV",0x89,0x0000}, // GEOS Swap File
    {".GEC",0x8B,0x0000}, // GEOS Clock Driver
    {".GEK",0x8C,0x0000}, // GEOS Interface Card Driver
    {".GEW",0x8D,0x0000}, // GEOS Formatting Data
    {".WP", 0xA0,0x0000}, // WordPerfect
    {".GSB",0xAB,0x0000}, // Apple IIgs BASIC Program
    {".TDF",0xAC,0x0000}, // Apple IIgs BASIC TDF
    {".BDF",0xAD,0x0000}, // Apple IIgs BASIC Data
    {".SRC",0xB0,0x0000}, // Apple IIgs Source Code
    {".OBJ",0xB1,0x0000}, // Apple IIgs Object Code
    {".LIB",0xB2,0x0000}, // Apple IIgs Library
    {".S16",0xB3,0x0000}, // Apple IIgs Application Program
    {".RTL",0xB4,0x0000}, // Apple IIgs Run Time Library
    {".EXE",0xB5,0x0000}, // Apple IIgs Shell Script
    {".PIF",0xB6,0x0000}, // Apple IIgs Permanent Init
    {".TIF",0xB7,0x0000}, // Apple IIgs Temporary Init
    {".NDA",0xB8,0x0000}, // Apple IIgs New Desk Accessory
    {".CDA",0xB9,0x0000}, // Apple IIgs Classic Desk Accessory
    {".TOL",0xBA,0x0000}, // Apple IIgs Tool
    {".DRV",0xBB,0x0000}, // Apple IIgs Device Driver
    {".LDF",0xBC,0x0000}, // Apple IIgs Generic Load File
    {".FST",0xBD,0x0000}, // Apple IIgs File System Translator
    {".DOC",0xBF,0x0000}, // Apple IIgs Document
    {".PNT",0xC0,0x0000}, // Apple IIgs Packed Super HiRes
    {".PIC",0xC1,0x0001}, // Apple IIgs Super HiRes
    {".ANI",0xC2,0x0000}, // PaintWorks Animation
    {".PAL",0xC3,0x0000}, // PaintWorks Palette
    {".OOG",0xC5,0x0000}, // Object Oriented Graphics
    {".SCR",0xC6,0x0000}, // Script
    {".CDV",0xC7,0x0000}, // Apple IIgs Control Panel
    {".FON",0xC8,0x0000}, // Apple IIgs Font
    {".FND",0xC9,0x0000}, // Apple IIgs Finder Data
    {".ICN",0xCA,0x0000}, // Apple IIgs ICon File
    {".MUS",0xD5,0x0000}, // Music
    {".INS",0xD6,0x0000}, // Instrument
    {".MDI",0xD7,0x0000}, // MIDI
    {".SND",0xD8,0x0000}, // Apple IIgs Audio
    {".DBM",0xDB,0x0000}, // DB Master Document
    {".LBR",0xE0,0x0000}, // LBR Archive
    {".ATK",0xE2,0x0000}, // AppleTalk Data
    {".R16",0xEE,0x0000}, // EDASM 816 Relocatable Code
    {".PAR",0xEF,0x0000}, // Pascal Area
    {".CMD",0xF0,0x0000}, // ProDOS Command File
    {".OVL",0xF1,0x0000}, // User Defined 1 (Overlay)
    {".UD2",0xF2,0x0000}, // User Defined 2
    {".UD3",0xF3,0x0000}, // User Defined 3
    {".UD4",0xF4,0x0000}, // User Defined 4
    {".UD5",0xF5,0x0000}, // User Defined 5
    {".UD6",0xF6,0x0000}, // User Defined 6
    {".UD7",0xF7,0x0000}, // User Defined 7
    {".PRG",0xF8,0x0000}, // User Defined 8
    {".P16",0xF9,0x0000}, // ProDOS-16 System File
    {".INT",0xFA,0x0000}, // Integer BASIC File
    {".IVR",0xFB,0x0000}, // Integer BASIC Variables
    {".BAS",0xFC,0x0801}, // AppleSoft BASIC Program
    {".VAR",0xFD,0x0000}, // AppleSoft BASIC Variables
    {".REL",0xFE,0x0000}, // EDASM Relocatable Code
    {".SYS",0xFF,0x2000}, // ProDOS 8 System File
  };

#endif /* EXTENSIONS_TO_FILETYPES_H */
