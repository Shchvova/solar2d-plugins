#pragma once
/*#
    # m6502.h

    MOS Technology 6502 / 6510 CPU emulator.

    Do this:
    ~~~C
    #define CHIPS_IMPL
    ~~~
    before you include this file in *one* C or C++ file to create the 
    implementation.

    Optionally provide the following macros with your own implementation
    ~~~C    
    CHIPS_ASSERT(c)
    ~~~

    ## Emulated Pins

    ***********************************
    *           +-----------+         *
    *   IRQ --->|           |---> A0  *
    *   NMI --->|           |...      *
    *    RDY--->|           |---> A15 *
    *    RW <---|           |         *
    *  SYNC <---|           |         *
    *           |           |<--> D0  *
    *   (P0)<-->|           |...      *
    *        ...|           |<--> D7  *
    *   (P5)<-->|           |         *
    *           +-----------+         *
    ***********************************

    The input/output P0..P5 pins only exist on the m6510.

    If the RDY pin is active (1) the CPU will loop on the next read
    access until the pin goes inactive.

    ## Notes

    Stored here for later referencer:

    - https://www.pagetable.com/?p=39
    
    Maybe it makes sense to rewrite the code-generation python script with
    a real 'decode' ROM?

    ## Functions
    ~~~C
    void m6502_init(m6502_t* cpu, const m6502_desc_t* desc)
    ~~~
        Initialize a m6502_t instance, the desc structure provides initialization
        attributes:
            ~~~C
            typedef struct {
                m6502_tick_t tick_cb;       // the CPU tick callback
                bool bcd_disabled;          // set to true if BCD mode is disabled
                m6510_in_t in_cb;           // optional port IO input callback (only on m6510)
                m6510_out_t out_cb;         // optional port IO output callback (only on m6510)
                uint8_t m6510_io_pullup;    // IO port bits that are 1 when reading
                uint8_t m6510_io_floating;  // unconnected IO port pins
                void* user_data;            // optional user-data for callbacks
            } m6502_desc_t;
            ~~~

        To emulate a m6510 you must provide port IO callbacks in _in_cb_ and _out_cb_,
        and should initialize the m6510_io_pullup and m6510_io_floating members.

    ~~~C
    void m6502_reset(m6502_t* cpu)
    ~~~
        Reset the m6502 instance.

    ~~~C
    uint32_t m6502_exec(m6502_t* cpu, uint32_t ticks)
    ~~~
        Execute instructions until the requested number of _ticks_ is reached,
        or a trap has been hit. Return number of executed cycles. To check if a trap
        has been hit, test the m6502_t.trap_id member on >= 0. 
        During execution the tick callback will be called for each clock cycle
        with the current CPU pin bitmask. The tick callback function must inspect
        the pin bitmask, perform memory requests and if necessary update the
        data bus pins. Finally the tick callback returns the (optionally
        modified) pin bitmask. If the tick callback sets the RDY pin (1),
        and the current tick is a read-access, the CPU will loop until the
        RDY pin is (0). The RDY pin is automatically cleared before the
        tick function is called for a read-access.

    ~~~C
    uint64_t m6510_iorq(m6502_t* cpu, uint64_t pins)
    ~~~
        For the m6510, call this function from inside the tick callback when the
        CPU wants to access the special memory location 0 and 1 (these are mapped
        to the IO port control registers of the m6510). m6510_iorq() may call the
        input/output callback functions provided in m6510_init().

    ~~~C
    void m6502_trap_cb(m6502_t* cpu, m6502_trap_t trap_cb)
    ~~~
        Set an optional trap callback. If this is set it will be invoked
        at the end of an instruction with the current PC (which points
        to the start of the next instruction). The trap callback should
        return a non-zero value if the execution loop should exit. The
        returned value will also be written to m6502_t.trap_id.
        Set a null ptr as trap callback disables the trap checking.
        To get the current trap callback, simply access m6502_t.trap_cb directly.

    ~~~C
    void m6502_set_x(m6502_t* cpu, uint8_t val)
    void m6502_set_xx(m6502_t* cpu, uint16_t val)
    uint8_t m6502_x(m6502_t* cpu)
    uint16_t m6502_xx(m6502_t* cpu)
    ~~~
        Set and get 6502 registers and flags.

    ## zlib/libpng license

    Copyright (c) 2018 Andre Weissflog
    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.
    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source
        distribution. 
#*/
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* address lines */
#define M6502_A0  (1ULL<<0)
#define M6502_A1  (1ULL<<1)
#define M6502_A2  (1ULL<<2)
#define M6502_A3  (1ULL<<3)
#define M6502_A4  (1ULL<<4)
#define M6502_A5  (1ULL<<5)
#define M6502_A6  (1ULL<<6)
#define M6502_A7  (1ULL<<7)
#define M6502_A8  (1ULL<<8)
#define M6502_A9  (1ULL<<9)
#define M6502_A10 (1ULL<<10)
#define M6502_A11 (1ULL<<11)
#define M6502_A12 (1ULL<<12)
#define M6502_A13 (1ULL<<13)
#define M6502_A14 (1ULL<<14)
#define M6502_A15 (1ULL<<15)

/*--- data lines ------*/
#define M6502_D0  (1ULL<<16)
#define M6502_D1  (1ULL<<17)
#define M6502_D2  (1ULL<<18)
#define M6502_D3  (1ULL<<19)
#define M6502_D4  (1ULL<<20)
#define M6502_D5  (1ULL<<21)
#define M6502_D6  (1ULL<<22)
#define M6502_D7  (1ULL<<23)

/*--- control pins ---*/
#define M6502_RW    (1ULL<<24)
#define M6502_SYNC  (1ULL<<25)
#define M6502_IRQ   (1ULL<<26)
#define M6502_NMI   (1ULL<<27)
#define M6502_RDY   (1ULL<<28)
#define M6510_AEC   (1ULL<<29)

/*--- m6510 specific port pins ---*/
#define M6510_P0    (1ULL<<32)
#define M6510_P1    (1ULL<<33)
#define M6510_P2    (1ULL<<34)
#define M6510_P3    (1ULL<<35)
#define M6510_P4    (1ULL<<36)
#define M6510_P5    (1ULL<<37)
#define M6510_PORT_BITS (M6510_P0|M6510_P1|M6510_P2|M6510_P3|M6510_P4|M6510_P5)

/* bit mask for all CPU pins (up to bit pos 40) */
#define M6502_PIN_MASK ((1ULL<<40)-1)

/*--- status indicator flags ---*/
#define M6502_CF (1<<0)   /* carry */
#define M6502_ZF (1<<1)   /* zero */
#define M6502_IF (1<<2)   /* IRQ disable */
#define M6502_DF (1<<3)   /* decimal mode */
#define M6502_BF (1<<4)   /* BRK command */
#define M6502_XF (1<<5)   /* unused */
#define M6502_VF (1<<6)   /* overflow */
#define M6502_NF (1<<7)   /* negative */

/* max number of trap points */
#define M6502_MAX_NUM_TRAPS (8)

/* callback function typedefs */
typedef uint64_t (*m6502_tick_t)(uint64_t pins, void* user_data);
typedef int (*m6502_trap_t)(uint16_t pc, int ticks, uint64_t pins, void* user_data);
typedef void (*m6510_out_t)(uint8_t data, void* user_data);
typedef uint8_t (*m6510_in_t)(void* user_data);

/* the desc structure provided to m6502_init() */
typedef struct {
    m6502_tick_t tick_cb;   /* the CPU tick callback */
    void* user_data;        /* optional callback user data */
    bool bcd_disabled;      /* set to true if BCD mode is disabled */
    m6510_in_t in_cb;       /* optional port IO input callback (only on m6510) */
    m6510_out_t out_cb;     /* optional port IO output callback (only on m6510) */
    uint8_t m6510_io_pullup;    /* IO port bits that are 1 when reading */
    uint8_t m6510_io_floating;  /* unconnected IO port pins */
} m6502_desc_t;

/* mutable tick state */
typedef struct {
    uint64_t PINS;
    uint8_t A,X,Y,S,P;      /* 8-bit registers */
    uint16_t PC;            /* 16-bit program counter */
    /* state of interrupt enable flag at the time when the IRQ pin is sampled,
       this is used to implement 'delayed IRQ response'
       (see: https://wiki.nesdev.com/w/index.php/CPU_interrupts)
    */
    uint8_t pi;
    bool bcd_enabled;       /* this is actually not mutable but needed when ticking */
} m6502_state_t;

/* M6502 CPU state */
typedef struct {
    m6502_state_t state;
    m6502_tick_t tick_cb;
    m6502_trap_t trap_cb;
    void* user_data;
    void* trap_user_data;
    int trap_id;        /* index of trap hit (-1 if no trap) */

    /* the m6510 IO port stuff */
    m6510_in_t in_cb;
    m6510_out_t out_cb;
    uint8_t io_ddr;     /* 1: output, 0: input */
    uint8_t io_inp;     /* last port input */
    uint8_t io_out;     /* last port output */
    uint8_t io_pins;    /* current state of IO pins (combined input/output) */
    uint8_t io_pullup;
    uint8_t io_floating;
    uint8_t io_drive;
} m6502_t;

/* initialize a new m6502 instance */
void m6502_init(m6502_t* cpu, const m6502_desc_t* desc);
/* reset an existing m6502 instance */
void m6502_reset(m6502_t* cpu);
/* set a trap callback function */
void m6502_trap_cb(m6502_t* cpu, m6502_trap_t trap_cb, void* trap_user_data);
/* execute instruction for at least 'ticks' or trap hit, return number of executed ticks */
uint32_t m6502_exec(m6502_t* cpu, uint32_t ticks);
/* perform m6510 port IO (only call this if M6510_CHECK_IO(pins) is true) */
uint64_t m6510_iorq(m6502_t* cpu, uint64_t pins);

/* register access functions */
void m6502_set_a(m6502_t* cpu, uint8_t v);
void m6502_set_x(m6502_t* cpu, uint8_t v);
void m6502_set_y(m6502_t* cpu, uint8_t v);
void m6502_set_s(m6502_t* cpu, uint8_t v);
void m6502_set_p(m6502_t* cpu, uint8_t v);
void m6502_set_pc(m6502_t* cpu, uint16_t v);

uint8_t m6502_a(m6502_t* cpu);
uint8_t m6502_x(m6502_t* cpu);
uint8_t m6502_y(m6502_t* cpu);
uint8_t m6502_s(m6502_t* cpu);
uint8_t m6502_p(m6502_t* cpu);
uint16_t m6502_pc(m6502_t* cpu);

/* extract 16-bit address bus from 64-bit pins */
#define M6502_GET_ADDR(p) ((uint16_t)(p&0xFFFFULL))
/* merge 16-bit address bus value into 64-bit pins */
#define M6502_SET_ADDR(p,a) {p=((p&~0xFFFFULL)|((a)&0xFFFFULL));}
/* extract 8-bit data bus from 64-bit pins */
#define M6502_GET_DATA(p) ((uint8_t)((p&0xFF0000ULL)>>16))
/* merge 8-bit data bus value into 64-bit pins */
#define M6502_SET_DATA(p,d) {p=(((p)&~0xFF0000ULL)|(((d)<<16)&0xFF0000ULL));}
/* return a pin mask with control-pins, address and data bus */
#define M6502_MAKE_PINS(ctrl, addr, data) ((ctrl)|(((data)<<16)&0xFF0000ULL)|((addr)&0xFFFFULL))
/* set the port bits on the 64-bit pin mask */
#define M6510_SET_PORT(p,d) {p=(((p)&~M6510_PORT_BITS)|((((uint64_t)d)<<32)&M6510_PORT_BITS));}

/* M6510: check for IO port access to address 0 or 1 */
#define M6510_CHECK_IO(p) ((p&0xFFFEULL)==0)

#ifdef __cplusplus
} /* extern "C" */
#endif

/*-- IMPLEMENTATION ----------------------------------------------------------*/
#ifdef CHIPS_IMPL
#include <string.h>
#ifndef CHIPS_ASSERT
    #include <assert.h>
    #define CHIPS_ASSERT(c) assert(c)
#endif

/* register access functions */
void m6502_set_a(m6502_t* cpu, uint8_t v) { cpu->state.A = v; }
void m6502_set_x(m6502_t* cpu, uint8_t v) { cpu->state.X = v; }
void m6502_set_y(m6502_t* cpu, uint8_t v) { cpu->state.Y = v; }
void m6502_set_s(m6502_t* cpu, uint8_t v) { cpu->state.S = v; }
void m6502_set_p(m6502_t* cpu, uint8_t v) { cpu->state.P = v; }
void m6502_set_pc(m6502_t* cpu, uint16_t v) { cpu->state.PC = v; }
uint8_t m6502_a(m6502_t* cpu) { return cpu->state.A; }
uint8_t m6502_x(m6502_t* cpu) { return cpu->state.X; }
uint8_t m6502_y(m6502_t* cpu) { return cpu->state.Y; }
uint8_t m6502_s(m6502_t* cpu) { return cpu->state.S; }
uint8_t m6502_p(m6502_t* cpu) { return cpu->state.P; }
uint16_t m6502_pc(m6502_t* cpu) { return cpu->state.PC; }

/* helper macros and functions for code-generated instruction decoder */
#define _M6502_NZ(p,v) ((p&~(M6502_NF|M6502_ZF))|((v&0xFF)?(v&M6502_NF):M6502_ZF))

static inline void _m6502_adc(m6502_state_t* cpu, uint8_t val) {
    if (cpu->bcd_enabled && (cpu->P & M6502_DF)) {
        /* decimal mode (credit goes to MAME) */
        uint8_t c = cpu->P & M6502_CF ? 1 : 0;
        cpu->P &= ~(M6502_NF|M6502_VF|M6502_ZF|M6502_CF);
        uint8_t al = (cpu->A & 0x0F) + (val & 0x0F) + c;
        if (al > 9) {
            al += 6;
        }
        uint8_t ah = (cpu->A >> 4) + (val >> 4) + (al > 0x0F);
        if (0 == (uint8_t)(cpu->A + val + c)) {
            cpu->P |= M6502_ZF;
        }
        else if (ah & 0x08) {
            cpu->P |= M6502_NF;
        }
        if (~(cpu->A^val) & (cpu->A^(ah<<4)) & 0x80) {
            cpu->P |= M6502_VF;
        }
        if (ah > 9) {
            ah += 6;
        }
        if (ah > 15) {
            cpu->P |= M6502_CF;
        }
        cpu->A = (ah<<4) | (al & 0x0F);
    }
    else {
        /* default mode */
        uint16_t sum = cpu->A + val + (cpu->P & M6502_CF ? 1:0);
        cpu->P &= ~(M6502_VF|M6502_CF);
        cpu->P = _M6502_NZ(cpu->P,sum);
        if (~(cpu->A^val) & (cpu->A^sum) & 0x80) {
            cpu->P |= M6502_VF;
        }
        if (sum & 0xFF00) {
            cpu->P |= M6502_CF;
        }
        cpu->A = sum & 0xFF;
    }    
}

static inline void _m6502_sbc(m6502_state_t* cpu, uint8_t val) {
    if (cpu->bcd_enabled && (cpu->P & M6502_DF)) {
        /* decimal mode (credit goes to MAME) */
        uint8_t c = cpu->P & M6502_CF ? 0 : 1;
        cpu->P &= ~(M6502_NF|M6502_VF|M6502_ZF|M6502_CF);
        uint16_t diff = cpu->A - val - c;
        uint8_t al = (cpu->A & 0x0F) - (val & 0x0F) - c;
        if ((int8_t)al < 0) {
            al -= 6;
        }
        uint8_t ah = (cpu->A>>4) - (val>>4) - ((int8_t)al < 0);
        if (0 == (uint8_t)diff) {
            cpu->P |= M6502_ZF;
        }
        else if (diff & 0x80) {
            cpu->P |= M6502_NF;
        }
        if ((cpu->A^val) & (cpu->A^diff) & 0x80) {
            cpu->P |= M6502_VF;
        }
        if (!(diff & 0xFF00)) {
            cpu->P |= M6502_CF;
        }
        if (ah & 0x80) {
            ah -= 6;
        }
        cpu->A = (ah<<4) | (al & 0x0F);
    }
    else {
        /* default mode */
        uint16_t diff = cpu->A - val - (cpu->P & M6502_CF ? 0 : 1);
        cpu->P &= ~(M6502_VF|M6502_CF);
        cpu->P = _M6502_NZ(cpu->P, (uint8_t)diff);
        if ((cpu->A^val) & (cpu->A^diff) & 0x80) {
            cpu->P |= M6502_VF;
        }
        if (!(diff & 0xFF00)) {
            cpu->P |= M6502_CF;
        }
        cpu->A = diff & 0xFF;
    }
}

static inline void _m6502_arr(m6502_state_t* cpu) {
    /* undocumented, unreliable ARR instruction, but this is tested
       by the Wolfgang Lorenz C64 test suite
       implementation taken from MAME
    */
    if (cpu->bcd_enabled && (cpu->P & M6502_DF)) {
        bool c = cpu->P & M6502_CF;
        cpu->P &= ~(M6502_NF|M6502_VF|M6502_ZF|M6502_CF);
        uint8_t a = cpu->A>>1;
        if (c) {
            a |= 0x80;
        }
        cpu->P = _M6502_NZ(cpu->P,a);
        if ((a ^ cpu->A) & 0x40) {
            cpu->P |= M6502_VF;
        }
        if ((cpu->A & 0xF) >= 5) {
            a = ((a + 6) & 0xF) | (a & 0xF0);
        }
        if ((cpu->A & 0xF0) >= 0x50) {
            a += 0x60;
            cpu->P |= M6502_CF;
        }
        cpu->A = a;
    }
    else {
        bool c = cpu->P & M6502_CF;
        cpu->P &= ~(M6502_NF|M6502_VF|M6502_ZF|M6502_CF);
        cpu->A >>= 1;
        if (c) {
            cpu->A |= 0x80;
        }
        cpu->P = _M6502_NZ(cpu->P,cpu->A);
        if (cpu->A & 0x40) {
            cpu->P |= M6502_VF|M6502_CF;
        }
        if (cpu->A & 0x20) {
            cpu->P ^= M6502_VF;
        }
    }
}

#undef _M6502_NZ

#include "_m6502_decoder.h"

void m6502_init(m6502_t* c, const m6502_desc_t* desc) {
    CHIPS_ASSERT(c && desc);
    CHIPS_ASSERT(desc->tick_cb);
    memset(c, 0, sizeof(*c));
    c->tick_cb = desc->tick_cb;
    c->user_data = desc->user_data;
    c->state.PINS = M6502_RW;
    c->state.P = M6502_IF|M6502_XF;
    c->state.S = 0xFD;
    c->state.bcd_enabled = !desc->bcd_disabled;
    c->in_cb = desc->in_cb;
    c->out_cb = desc->out_cb;
    c->io_pullup = desc->m6510_io_pullup;
    c->io_floating = desc->m6510_io_floating;
    c->trap_id = -1;
}

void m6502_reset(m6502_t* c) {
    CHIPS_ASSERT(c);
    c->state.P = M6502_IF|M6502_XF;
    c->state.S = 0xFD;
    c->state.PINS = M6502_RW;
    /* load reset vector from 0xFFFD into PC */
    uint8_t l = M6502_GET_DATA(c->tick_cb(M6502_MAKE_PINS(M6502_RW, 0xFFFC, 0x00), c->user_data));
    uint8_t h = M6502_GET_DATA(c->tick_cb(M6502_MAKE_PINS(M6502_RW, 0xFFFD, 0x00), c->user_data));
    c->state.PC = (h<<8)|l;
    c->io_ddr = 0;
    c->io_out = 0;
    c->io_inp = 0;
    c->io_pins = 0;
}

void m6502_trap_cb(m6502_t* c, m6502_trap_t trap_cb, void* trap_user_data) {
    CHIPS_ASSERT(c);
    c->trap_cb = trap_cb;
    c->trap_user_data = trap_user_data;
}

/* only call this when accessing address 0 or 1 (M6510_CHECK_IO(pins) evaluates to true) */
uint64_t m6510_iorq(m6502_t* c, uint64_t pins) {
    CHIPS_ASSERT(c->in_cb && c->out_cb);
    if ((pins & M6502_A0) == 0) {
        /* address 0: access to data direction register */
        if (pins & M6502_RW) {
            /* read IO direction bits */
            M6502_SET_DATA(pins, c->io_ddr);
        }
        else {
            /* write IO direction bits and update outside world */
            c->io_ddr = M6502_GET_DATA(pins);
            c->io_drive = (c->io_out & c->io_ddr) | (c->io_drive & ~c->io_ddr);
            c->out_cb((c->io_out & c->io_ddr) | (c->io_pullup & ~c->io_ddr), c->user_data);
            c->io_pins = (c->io_out & c->io_ddr) | (c->io_inp & ~c->io_ddr);
        }
    }
    else {
        /* address 1: perform I/O */
        if (pins & M6502_RW) {
            /* an input operation */
            c->io_inp = c->in_cb(c->user_data);
            uint8_t val = ((c->io_inp | (c->io_floating & c->io_drive)) & ~c->io_ddr) | (c->io_out & c->io_ddr);
            M6502_SET_DATA(pins, val);
        }
        else {
            /* an output operation */
            c->io_out = M6502_GET_DATA(pins);
            c->io_drive = (c->io_out & c->io_ddr) | (c->io_drive & ~c->io_ddr);
            c->out_cb((c->io_out & c->io_ddr) | (c->io_pullup & ~c->io_ddr), c->user_data);
        }
        c->io_pins = (c->io_out & c->io_ddr) | (c->io_inp & ~c->io_ddr);
    }
    return pins;
}
#endif /* CHIPS_IMPL */
