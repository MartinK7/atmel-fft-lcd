#define DD_SCK    PB5   // ARD_13   PCINT5    SCK   LED-OUT
#define DD_MOSI   PB3   // ARD_11   OC2A   PCINT3    MOSI  PWM
#define DDR_SPI   DDRB  // 
#define LCD_DDR   DDRB  //
#define LCD_PORT  PORTB //
#define LCD_DC    PB0   // ARD_8
#define LCD_CE    PB1   // ARD_9
#define LCD_RST   PB2   // ARD_10

#define LCDWIDTH 84   ///< LCD is 84 pixels wide
#define LCDHEIGHT 48  ///< 48 pixels high

#define PCD8544_POWERDOWN 0x04            ///< Function set, Power down mode
#define PCD8544_ENTRYMODE 0x02            ///< Function set, Entry mode
#define PCD8544_EXTENDEDINSTRUCTION 0x01  ///< Function set, Extended instruction set control

#define PCD8544_DISPLAYBLANK 0x0      ///< Display control, blank
#define PCD8544_DISPLAYNORMAL 0x4     ///< Display control, normal mode
#define PCD8544_DISPLAYALLON 0x1      ///< Display control, all segments on
#define PCD8544_DISPLAYINVERTED 0x5   ///< Display control, inverse mode

#define PCD8544_FUNCTIONSET 0x20      ///< Basic instruction set
#define PCD8544_DISPLAYCONTROL 0x08   ///< Basic instruction set - Set display configuration
#define PCD8544_SETYADDR 0x40         ///< Basic instruction set - Set Y address of RAM, 0 <= Y <= 5
#define PCD8544_SETXADDR 0x80         ///< Basic instruction set - Set X address of RAM, 0 <= X <= 83

#define PCD8544_SETTEMP 0x04          ///< Extended instruction set - Set temperature coefficient
#define PCD8544_SETBIAS 0x10          ///< Extended instruction set - Set bias system
#define PCD8544_SETVOP 0x80           ///< Extended instruction set - Write Vop to register

uint8_t LCD_pixelBuffer[84*6];

void LCD_command(uint8_t cmd); 
void LCD_data(uint8_t dat);

void LCD_init(void);
void LCD_setPixel(uint8_t x, uint8_t y);
void LCD_line(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);

void LCD_clear(void);

void LCD_showBuffer(void);