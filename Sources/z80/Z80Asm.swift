public struct Z80Asm
{
    private(set) var mem: Memory
    var addr: UShort = 0x0000

    init(_ mem: Memory) {
        self.mem = mem
    }

    public mutating func Reset()
    {
        mem.clear()
        addr = 0
    }

    public mutating func Halt()
    {
        Write(0x76)
    }

    public mutating func Write(_ val: Int)
    {
        Write(Byte(truncatingIfNeeded: val))
    }

    public mutating func Write(_ val: UShort)
    {
        Write(Byte(truncatingIfNeeded: val))
    }

    public mutating func Write(_ val: SByte)
    {
        Write(Byte(truncatingIfNeeded: val))
    }

    public mutating func Write(_ val: Byte)
    {
        mem[addr] = val
        addr += 1
    }

    public mutating func Nop()
    {
        Write(0x00)
    }

    public mutating func LoadRegVal(_ reg: Byte, _ val: Byte)
    {
        Write(reg * 8 + 6)
        Write(val)
    }

    public mutating func LoadRegReg(_ reg: Byte, _ reg2: Byte)
    {
        Write(reg * 8 + reg2 + 64)
    }

    public mutating func LoadReg16Val(_ reg: Byte, _ val: UShort)
    {
        Write(1 + reg * 16)
        Write(val & 0xFF)
        Write(val >> 8)
    }

    public mutating func LoadRegAtHl(_ reg: Byte)
    {
        Write(70 + reg * 8)
    }

    public mutating func Data(_ val: Byte)
    {
        Write(val)
    }

    public mutating func LoadRegAddrIx(_ reg: Byte, _ d: SByte)
    {
        Write(0xDD)
        Write(70 + reg * 8)
        Write(d)
    }

    public mutating func LoadIxVal(_ val: UShort)
    {
        Write(0xDD)
        Write(33)
        Write(val & 0xFF)
        Write(val >> 8)
    }

    public mutating func LoadRegAddrIy(_ reg: Byte, _ d: SByte)
    {
        Write(0xFD)
        Write(70 + reg * 8)
        Write(d)
    }

    public mutating func LoadIyVal(_ val: UShort)
    {
        Write(0xFD)
        Write(33)
        Write(val & 0xFF)
        Write(val >> 8)
    }

    public mutating func LoadAtHlReg(_ reg: Byte)
    {
        Write(reg + 0x70)
    }

    public mutating func LoadIxReg(_ reg: Byte, _ d: SByte)
    {
        Write(0xDD)
        Write(reg + 0x70)
        Write(d)
    }

    public mutating func LoadIyReg(_ reg: Byte, _ d: SByte)
    {
        Write(0xFD)
        Write(reg + 0x70)
        Write(d)
    }

    public mutating func LoadAtHlVal(_ val: Byte)
    {
        Write(0x36)
        Write(val)
    }

    public mutating func LoadAtIxVal(_ d: SByte, _ val: Byte)
    {
        Write(0xDD)
        Write(0x36)
        Write(d)
        Write(val)
    }

    public mutating func LoadIyN(_ d: SByte, _ val: Byte)
    {
        Write(0xFD)
        Write(0x36)
        Write(d)
        Write(val)
    }

    public mutating func LoadABc()
    {
        Write(0x0A)
    }

    public mutating func LoadADe()
    {
        Write(0x1A)
    }

    public mutating func LoadAAddr(_ addr: UShort)
    {
        Write(0x3A)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadBcA()
    {
        Write(0x02)
    }

    public mutating func LoadDeA()
    {
        Write(0x12)
    }

    public mutating func LoadAddrA(_ addr: UShort)
    {
        Write(0x32)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadAI()
    {
        Write(0xED)
        Write(0x57)
    }

    public mutating func LoadIA()
    {
        Write(0xED)
        Write(0x47)
    }

    public mutating func LoadAR()
    {
        Write(0xED)
        Write(0x5F)
    }

    public mutating func LoadRA()
    {
        Write(0xED)
        Write(0x4F)
    }

    public mutating func Di()
    {
        Write(0xF3)
    }

    public mutating func Ei()
    {
        Write(0xFB)
    }

    public mutating func LoadHlAddr(_ addr: UShort)
    {
        Write(0x2A)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadReg16Addr(_ reg: Byte, _ addr: UShort)
    {
        Write(0xED)
        Write(0x4B + reg * 16)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadIXAddr(_ addr: UShort)
    {
        Write(0xDD)
        Write(0x2A)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadIYAddr(_ addr: UShort)
    {
        Write(0xFD)
        Write(0x2A)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadAddrHl(_ addr: UShort)
    {
        Write(0x22)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadAddrReg16(_ reg: Byte, _ addr: UShort)
    {
        Write(0xED)
        Write(0x43 + reg * 16)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadAddrIx(_ addr: UShort)
    {
        Write(0xDD)
        Write(0x22)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadAddrIy(_ addr: UShort)
    {
        Write(0xFD)
        Write(0x22)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func LoadSpHl()
    {
        Write(0xF9)
    }

    public mutating func LoadSpIx()
    {
        Write(0xDD)
        Write(0xF9)
    }

    public mutating func LoadSpIy()
    {
        Write(0xFD)
        Write(0xF9)
    }

    public mutating func PushReg16(_ reg: Byte)
    {
        Write(0xC5 + reg * 16)
    }

    public mutating func PushIx()
    {
        Write(0xDD)
        Write(0xE5)
    }

    public mutating func PushIy()
    {
        Write(0xFD)
        Write(0xE5)
    }

    public mutating func PopReg16(_ reg: Byte)
    {
        Write(0xC1 + reg * 16)
    }

    public mutating func PopIx()
    {
        Write(0xDD)
        Write(0xE1)
    }

    public mutating func PopIy()
    {
        Write(0xFD)
        Write(0xE1)
    }

    public mutating func ExDeHl()
    {
        Write(0xEB)
    }

    public mutating func ExAfAfp()
    {
        Write(0x08)
    }

    public mutating func Exx()
    {
        Write(0xD9)
    }

    public mutating func ExAddrSpHl()
    {
        Write(0xE3)
    }

    public mutating func ExAddrSpIx()
    {
        Write(0xDD)
        Write(0xE3)
    }

    public mutating func ExAddrSpIy()
    {
        Write(0xFD)
        Write(0xE3)
    }

    public mutating func Ldi()
    {
        Write(0xED)
        Write(0xA0)
    }

    public mutating func Ldir()
    {
        Write(0xED)
        Write(0xB0)
    }

    public mutating func Ldd()
    {
        Write(0xED)
        Write(0xA8)
    }

    public mutating func Lddr()
    {
        Write(0xED)
        Write(0xB8)
    }

    public mutating func Cpi()
    {
        Write(0xED)
        Write(0xA1)
    }

    public mutating func Cpir()
    {
        Write(0xED)
        Write(0xB1)
    }

    public mutating func Cpd()
    {
        Write(0xED)
        Write(0xA9)
    }

    public mutating func Cpdr()
    {
        Write(0xED)
        Write(0xB9)
    }

    public mutating func AddAReg(_ reg: Byte)
    {
        Write(reg + 0x80)
    }

    public mutating func AddAVal(_ val: Byte)
    {
        Write(0xC6)
        Write(val)
    }

    public mutating func AddAAddrHl()
    {
        Write(0x86)
    }

    public mutating func AddAAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x86)
        Write(d)
    }

    public mutating func AddAAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x86)
        Write(d)
    }

    public mutating func AdcAReg(_ reg: Byte)
    {
        Write(reg + 0x88)
    }

    public mutating func AdcAVal(_ val: Byte)
    {
        Write(0xCE)
        Write(val)
    }

    public mutating func AdcAAddrHl()
    {
        Write(0x8E)
    }

    public mutating func AdcAAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x8E)
        Write(d)
    }

    public mutating func AdcAAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x8E)
        Write(d)
    }

    public mutating func SubReg(_ reg: Byte)
    {
        Write(reg + 0x90)
    }

    public mutating func SubVal(_ val: Byte)
    {
        Write(0xD6)
        Write(val)
    }

    public mutating func SubAddrHl()
    {
        Write(0x96)
    }

    public mutating func SubAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x96)
        Write(d)
    }

    public mutating func SubAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x96)
        Write(d)
    }

    public mutating func SbcAReg(_ reg: Byte)
    {
        Write(reg + 0x98)
    }

    public mutating func SbcAVal(_ val: Byte)
    {
        Write(0xDE)
        Write(val)
    }

    public mutating func SbcAAddrHl()
    {
        Write(0x9E)
    }

    public mutating func SbcAAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x9E)
        Write(d)
    }

    public mutating func SbcAAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x9E)
        Write(d)
    }

    public mutating func AndReg(_ reg: Byte)
    {
        Write(reg + 0xA0)
    }

    public mutating func AndVal(_ val: Byte)
    {
        Write(0xE6)
        Write(val)
    }

    public mutating func AndAddrHl()
    {
        Write(0xA6)
    }

    public mutating func AndAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xA6)
        Write(d)
    }

    public mutating func AndAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xA6)
        Write(d)
    }

    public mutating func OrReg(_ reg: Byte)
    {
        Write(reg + 0xB0)
    }

    public mutating func OrVal(_ val: Byte)
    {
        Write(0xF6)
        Write(val)
    }

    public mutating func OrAddrHl()
    {
        Write(0xB6)
    }

    public mutating func OrAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xB6)
        Write(d)
    }

    public mutating func OrAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xB6)
        Write(d)
    }

    public mutating func XorReg(_ reg: Byte)
    {
        Write(reg + 0xA8)
    }

    public mutating func XorVal(_ val: Byte)
    {
        Write(0xEE)
        Write(val)
    }

    public mutating func XorAddrHl()
    {
        Write(0xAE)
    }

    public mutating func XorAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xAE)
        Write(d)
    }

    public mutating func XorAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xAE)
        Write(d)
    }

    public mutating func CpReg(_ reg: Byte)
    {
        Write(reg + 0xB8)
    }

    public mutating func CpVal(_ val: Byte)
    {
        Write(0xFE)
        Write(val)
    }

    public mutating func CpAddrHl()
    {
        Write(0xBE)
    }

    public mutating func CpAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xBE)
        Write(d)
    }

    public mutating func CpAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xBE)
        Write(d)
    }

    public mutating func IncReg(_ reg: Byte)
    {
        Write(0x04 + reg * 8)
    }

    public mutating func IncAddrHl()
    {
        Write(0x34)
    }

    public mutating func IncAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x34)
        Write(d)
    }

    public mutating func IncAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x34)
        Write(d)
    }

    public mutating func DecReg(_ reg: Byte)
    {
        Write(0x05 + reg * 8)
    }

    public mutating func DecAddrHl()
    {
        Write(0x35)
    }

    public mutating func DecAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0x35)
        Write(d)
    }

    public mutating func DecAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0x35)
        Write(d)
    }

    public mutating func Daa()
    {
        Write(0x27)
    }

    public mutating func Cpl()
    {
        Write(0x2F)
    }

    public mutating func Neg()
    {
        Write(0xED)
        Write(0x44)
    }

    public mutating func Ccf()
    {
        Write(0x3F)
    }

    public mutating func Scf()
    {
        Write(0x37)
    }

    public mutating func Im0()
    {
        Write(0xED)
        Write(0x46)
    }

    public mutating func Im1()
    {
        Write(0xED)
        Write(0x56)
    }

    public mutating func Im2()
    {
        Write(0xED)
        Write(0x5E)
    }

    public mutating func AddHlReg16(_ reg: Byte)
    {
        Write(0x09 + reg * 16)
    }

    public mutating func AdcHlReg16(_ reg: Byte)
    {
        Write(0xED)
        Write(0x4A + reg * 16)
    }

    public mutating func SbcHlReg16(_ reg: Byte)
    {
        Write(0xED)
        Write(0x42 + reg * 16)
    }

    public mutating func AddIxReg16(_ reg: Byte)
    {
        Write(0xDD)
        Write(0x09 + reg * 16)
    }

    public mutating func AddIyReg16(_ reg: Byte)
    {
        Write(0xFD)
        Write(0x09 + reg * 16)
    }

    public mutating func IncReg16(_ reg: Byte)
    {
        Write(0x03 + reg * 16)
    }

    public mutating func IncIx()
    {
        Write(0xDD)
        Write(0x23)
    }

    public mutating func IncIy()
    {
        Write(0xFD)
        Write(0x23)
    }

    public mutating func DecReg16(_ reg: Byte)
    {
        Write(0x0B + reg * 16)
    }

    public mutating func DecIx()
    {
        Write(0xDD)
        Write(0x2B)
    }

    public mutating func DecIy()
    {
        Write(0xFD)
        Write(0x2B)
    }

    public mutating func Rlca()
    {
        Write(0x07)
    }

    public mutating func Rla()
    {
        Write(0x17)
    }

    public mutating func Rrca()
    {
        Write(0x0F)
    }

    public mutating func Rra()
    {
        Write(0x1F)
    }

    public mutating func RlcReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg)
    }

    public mutating func RlcAddrHl()
    {
        Write(0xCB)
        Write(0x06)
    }

    public mutating func RlcAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x06)
    }

    public mutating func RlcAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x06)
    }

    public mutating func RlReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x10)
    }

    public mutating func RlAddrHl()
    {
        Write(0xCB)
        Write(0x16)
    }

    public mutating func RlAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x16)
    }

    public mutating func RlAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x16)
    }

    public mutating func RrcReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x08)
    }

    public mutating func RrcAddrHl()
    {
        Write(0xCB)
        Write(0x0E)
    }

    public mutating func RrcAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x0E)
    }

    public mutating func RrcAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x0E)
    }

    public mutating func RrReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x18)
    }

    public mutating func RrAddrHl()
    {
        Write(0xCB)
        Write(0x1E)
    }

    public mutating func RrAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x1E)
    }

    public mutating func RrAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x1E)
    }

    public mutating func SlaAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x26)
    }

    public mutating func SlaAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x26)
    }

    public mutating func SlaAddrHl()
    {
        Write(0xCB)
        Write(0x26)
    }

    public mutating func SlaReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x20)
    }

    public mutating func SraReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x28)
    }

    public mutating func SraAddrHl()
    {
        Write(0xCB)
        Write(0x2E)
    }

    public mutating func SraAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x2E)
    }

    public mutating func SraAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x2E)
    }

    public mutating func SrlReg(_ reg: Byte)
    {
        Write(0xCB)
        Write(reg + 0x38)
    }

    public mutating func SrlAddrHl()
    {
        Write(0xCB)
        Write(0x3E)
    }

    public mutating func SrlAddrIx(_ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x3E)
    }

    public mutating func SrlAddrIy(_ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x3E)
    }

    public mutating func Rld()
    {
        Write(0xED)
        Write(0x6F)
    }

    public mutating func Rrd()
    {
        Write(0xED)
        Write(0x67)
    }

    public mutating func BitNReg(_ bit: Byte, _ reg: Byte)
    {
        Write(0xCB)
        Write(0x40 + bit * 8 + reg)
    }

    public mutating func BitNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0x46 + bit * 8)
    }

    public mutating func BitNAtIxd(_ bit: Byte, _ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x46 + bit * 8)
    }

    public mutating func BitNAtIyd(_ bit: Byte, _ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x46 + bit * 8)
    }

    public mutating func SetNReg(_ bit: Byte, _ reg: Byte)
    {
        Write(0xCB)
        Write(0xC0 + bit * 8 + reg)
    }

    public mutating func SetNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0xC6 + bit * 8)
    }

    public mutating func SetNAtIxd(_ bit: Byte, _ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0xC6 + bit * 8)
    }

    public mutating func SetNAtIyd(_ bit: Byte, _ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0xC6 + bit * 8)
    }

    public mutating func ResNReg(_ bit: Byte, _ reg: Byte)
    {
        Write(0xCB)
        Write(0x80 + bit * 8 + reg)
    }

    public mutating func ResNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0x86 + bit * 8)
    }

    public mutating func ResNAtIxd(_ bit: Byte, _ d: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(d)
        Write(0x86 + bit * 8)
    }

    public mutating func ResNAtIyd(_ bit: Byte, _ d: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(d)
        Write(0x86 + bit * 8)
    }

    public mutating func Jp(_ addr: UShort)
    {
        Write(0xC3)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func Jr(_ d: SByte)
    {
        Write(0x18)
        Write(d - 2)
    }

    public mutating func JrNz(_ d: SByte)
    {
        Write(0x20)
        Write(d - 2)
    }

    public mutating func JrZ(_ d: SByte)
    {
        Write(0x28)
        Write(d - 2)
    }

    public mutating func JrNc(_ d: SByte)
    {
        Write(0x30)
        Write(d - 2)
    }

    public mutating func JrC(_ d: SByte)
    {
        Write(0x38)
        Write(d - 2)
    }

    public mutating func JpHl()
    {
        Write(0xE9)
    }

    public mutating func JpIx()
    {
        Write(0xDD)
        Write(0xE9)
    }

    public mutating func JpIy()
    {
        Write(0xFD)
        Write(0xE9)
    }

    public mutating func Djnz(_ d: SByte)
    {
        Write(0x10)
        Write(d - 2)
    }

    public mutating func JpNz(_ addr: UShort)
    {
        Write(0xC2)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpZ(_ addr: UShort)
    {
        Write(0xCA)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpNc(_ addr: UShort)
    {
        Write(0xD2)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpC(_ addr: UShort)
    {
        Write(0xDA)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpPo(_ addr: UShort)
    {
        Write(0xE2)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpPe(_ addr: UShort)
    {
        Write(0xEA)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpP(_ addr: UShort)
    {
        Write(0xF2)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func JpM(_ addr: UShort)
    {
        Write(0xFA)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func Call(_ addr: UShort)
    {
        Write(0xCD)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallNz(_ addr: UShort)
    {
        Write(0xC4)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallZ(_ addr: UShort)
    {
        Write(0xCC)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallNc(_ addr: UShort)
    {
        Write(0xD4)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallC(_ addr: UShort)
    {
        Write(0xDC)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallPo(_ addr: UShort)
    {
        Write(0xE4)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallPe(_ addr: UShort)
    {
        Write(0xEC)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallP(_ addr: UShort)
    {
        Write(0xF4)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func CallM(_ addr: UShort)
    {
        Write(0xFC)
        Write(addr & 0xFF)
        Write(addr >> 8)
    }

    public mutating func Ret()
    {
        Write(0xC9)
    }

    public mutating func RetNz()
    {
        Write(0xC0)
    }

    public mutating func RetZ()
    {
        Write(0xC8)
    }

    public mutating func RetNc()
    {
        Write(0xD0)
    }

    public mutating func RetC()
    {
        Write(0xD8)
    }

    public mutating func RetPo()
    {
        Write(0xE0)
    }

    public mutating func RetPe()
    {
        Write(0xE8)
    }

    public mutating func RetP()
    {
        Write(0xF0)
    }

    public mutating func RetM()
    {
        Write(0xF8)
    }

    public mutating func RetI()
    {
        Write(0xED)
        Write(0x4D)
    }

    public mutating func RetN()
    {
        Write(0xED)
        Write(0x45)
    }

    public mutating func Rst(_ page: Byte)
    {
        Write(0xC7 + page * 8)
    }

    public mutating func InAPort(_ port: Byte)
    {
        Write(0xDB)
        Write(port)
    }

    public mutating func InRegBc(_ reg: Byte)
    {
        Write(0xED)
        Write(0x40 + reg * 8)
    }

    public mutating func Ini()
    {
        Write(0xED)
        Write(0xA2)
    }

    public mutating func Inir()
    {
        Write(0xED)
        Write(0xB2)
    }

    public mutating func Ind()
    {
        Write(0xED)
        Write(0xAA)
    }

    public mutating func Indr()
    {
        Write(0xED)
        Write(0xBA)
    }

    public mutating func OutPortA(_ port: Byte)
    {   
        Write(0xD3)
        Write(port)
    }

    public mutating func OutBcReg(_ reg: Byte)
    {
        Write(0xED)
        Write(0x41 + reg * 8)
    }

    public mutating func Outi()
    {
        Write(0xED)
        Write(0xA3)
    }

    public mutating func Outir()
    {
        Write(0xED)
        Write(0xB3)
    }

    public mutating func Outd()
    {
        Write(0xED)
        Write(0xAB)
    }

    public mutating func Outdr()
    {
        Write(0xED)
        Write(0xBB)
    }
}
