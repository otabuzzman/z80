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

    public mutating func Write(_ value: Int)
    {
        Write(Byte(truncatingIfNeeded: value))
    }

    public mutating func Write(_ value: UShort)
    {
        Write(Byte(truncatingIfNeeded: value))
    }

    public mutating func Write(_ value: SByte)
    {
        Write(Byte(truncatingIfNeeded: value))
    }

    public mutating func Write(_ value: Byte)
    {
        mem[addr] = value
        addr += 1
    }

    public mutating func Nop()
    {
        Write(0x00)
    }

    public mutating func LoadRegVal(_ register: Byte, _ value: Byte)
    {
        Write(register * 8 + 6)
        Write(value)
    }

    public mutating func LoadRegReg(_ register: Byte, _ register2: Byte)
    {
        Write(register * 8 + register2 + 64)
    }

    public mutating func LoadReg16Val(_ register16: Byte, _ value: UShort)
    {
        Write(1 + register16 * 16)
        Write(value & 0xFF)
        Write(value >> 8)
    }

    public mutating func LoadRegAtHl(_ register: Byte)
    {
        Write(70 + register * 8)
    }

    public mutating func Data(_ value: Byte)
    {
        Write(value)
    }

    public mutating func LoadRegAddrIx(_ register: Byte, _ displacement: SByte)
    {
        Write(0xDD)
        Write(70 + register * 8)
        Write(displacement)
    }

    public mutating func LoadIxVal(_ value: UShort)
    {
        Write(0xDD)
        Write(33)
        Write(value & 0xFF)
        Write(value >> 8)
    }

    public mutating func LoadRegAddrIy(_ register: Byte, _ displacement: SByte)
    {
        Write(0xFD)
        Write(70 + register * 8)
        Write(displacement)
    }

    public mutating func LoadIyVal(_ value: UShort)
    {
        Write(0xFD)
        Write(33)
        Write(value & 0xFF)
        Write(value >> 8)
    }

    public mutating func LoadAtHlReg(_ register: Byte)
    {
        Write(register + 0x70)
    }

    public mutating func LoadIxReg(_ register: Byte, _ displacement: SByte)
    {
        Write(0xDD)
        Write(register + 0x70)
        Write(displacement)
    }

    public mutating func LoadIyReg(_ register: Byte, _ displacement: SByte)
    {
        Write(0xFD)
        Write(register + 0x70)
        Write(displacement)
    }

    public mutating func LoadAtHlVal(_ value: Byte)
    {
        Write(0x36)
        Write(value)
    }

    public mutating func LoadAtIxVal(_ displacement: SByte, _ value: Byte)
    {
        Write(0xDD)
        Write(0x36)
        Write(displacement)
        Write(value)
    }

    public mutating func LoadIyN(_ displacement: SByte, _ value: Byte)
    {
        Write(0xFD)
        Write(0x36)
        Write(displacement)
        Write(value)
    }

    public mutating func LoadABc()
    {
        Write(0x0A)
    }

    public mutating func LoadADe()
    {
        Write(0x1A)
    }

    public mutating func LoadAAddr(_ address: UShort)
    {
        Write(0x3A)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadBcA()
    {
        Write(0x02)
    }

    public mutating func LoadDeA()
    {
        Write(0x12)
    }

    public mutating func LoadAddrA(_ address: UShort)
    {
        Write(0x32)
        Write(address & 0xFF)
        Write(address >> 8)
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

    public mutating func LoadHlAddr(_ address: UShort)
    {
        Write(0x2A)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadReg16Addr(_ register16: Byte, _ address: UShort)
    {
        Write(0xED)
        Write(0x4B + register16 * 16)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadIXAddr(_ address: UShort)
    {
        Write(0xDD)
        Write(0x2A)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadIYAddr(_ address: UShort)
    {
        Write(0xFD)
        Write(0x2A)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadAddrHl(_ address: UShort)
    {
        Write(0x22)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadAddrReg16(_ register16: Byte, _ address: UShort)
    {
        Write(0xED)
        Write(0x43 + register16 * 16)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadAddrIx(_ address: UShort)
    {
        Write(0xDD)
        Write(0x22)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func LoadAddrIy(_ address: UShort)
    {
        Write(0xFD)
        Write(0x22)
        Write(address & 0xFF)
        Write(address >> 8)
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

    public mutating func PushReg16(_ register16: Byte)
    {
        Write(0xC5 + register16 * 16)
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

    public mutating func PopReg16(_ register16: Byte)
    {
        Write(0xC1 + register16 * 16)
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

    public mutating func AddAReg(_ register: Byte)
    {
        Write(register + 0x80)
    }

    public mutating func AddAVal(_ value: Byte)
    {
        Write(0xC6)
        Write(value)
    }

    public mutating func AddAAddrHl()
    {
        Write(0x86)
    }

    public mutating func AddAAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x86)
        Write(displacement)
    }

    public mutating func AddAAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x86)
        Write(displacement)
    }

    public mutating func AdcAReg(_ register: Byte)
    {
        Write(register + 0x88)
    }

    public mutating func AdcAVal(_ value: Byte)
    {
        Write(0xCE)
        Write(value)
    }

    public mutating func AdcAAddrHl()
    {
        Write(0x8E)
    }

    public mutating func AdcAAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x8E)
        Write(displacement)
    }

    public mutating func AdcAAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x8E)
        Write(displacement)
    }

    public mutating func SubReg(_ register: Byte)
    {
        Write(register + 0x90)
    }

    public mutating func SubVal(_ value: Byte)
    {
        Write(0xD6)
        Write(value)
    }

    public mutating func SubAddrHl()
    {
        Write(0x96)
    }

    public mutating func SubAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x96)
        Write(displacement)
    }

    public mutating func SubAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x96)
        Write(displacement)
    }

    public mutating func SbcAReg(_ register: Byte)
    {
        Write(register + 0x98)
    }

    public mutating func SbcAVal(_ value: Byte)
    {
        Write(0xDE)
        Write(value)
    }

    public mutating func SbcAAddrHl()
    {
        Write(0x9E)
    }

    public mutating func SbcAAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x9E)
        Write(displacement)
    }

    public mutating func SbcAAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x9E)
        Write(displacement)
    }

    public mutating func AndReg(_ reg: Byte)
    {
        Write(reg + 0xA0)
    }

    public mutating func AndVal(_ value: Byte)
    {
        Write(0xE6)
        Write(value)
    }

    public mutating func AndAddrHl()
    {
        Write(0xA6)
    }

    public mutating func AndAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xA6)
        Write(displacement)
    }

    public mutating func AndAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xA6)
        Write(displacement)
    }

    public mutating func OrReg(_ reg: Byte)
    {
        Write(reg + 0xB0)
    }

    public mutating func OrVal(_ value: Byte)
    {
        Write(0xF6)
        Write(value)
    }

    public mutating func OrAddrHl()
    {
        Write(0xB6)
    }

    public mutating func OrAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xB6)
        Write(displacement)
    }

    public mutating func OrAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xB6)
        Write(displacement)
    }

    public mutating func XorReg(_ reg: Byte)
    {
        Write(reg + 0xA8)
    }

    public mutating func XorVal(_ value: Byte)
    {
        Write(0xEE)
        Write(value)
    }

    public mutating func XorAddrHl()
    {
        Write(0xAE)
    }

    public mutating func XorAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xAE)
        Write(displacement)
    }

    public mutating func XorAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xAE)
        Write(displacement)
    }

    public mutating func CpReg(_ register: Byte)
    {
        Write(register + 0xB8)
    }

    public mutating func CpVal(_ value: Byte)
    {
        Write(0xFE)
        Write(value)
    }

    public mutating func CpAddrHl()
    {
        Write(0xBE)
    }

    public mutating func CpAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xBE)
        Write(displacement)
    }

    public mutating func CpAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xBE)
        Write(displacement)
    }

    public mutating func IncReg(_ register: Byte)
    {
        Write(0x04 + register * 8)
    }

    public mutating func IncAddrHl()
    {
        Write(0x34)
    }

    public mutating func IncAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x34)
        Write(displacement)
    }

    public mutating func IncAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x34)
        Write(displacement)
    }

    public mutating func DecReg(_ register: Byte)
    {
        Write(0x05 + register * 8)
    }

    public mutating func DecAddrHl()
    {
        Write(0x35)
    }

    public mutating func DecAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0x35)
        Write(displacement)
    }

    public mutating func DecAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0x35)
        Write(displacement)
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

    public mutating func AddHlReg16(_ register16: Byte)
    {
        Write(0x09 + register16 * 16)
    }

    public mutating func AdcHlReg16(_ register16: Byte)
    {
        Write(0xED)
        Write(0x4A + register16 * 16)
    }

    public mutating func SbcHlReg16(_ register16: Byte)
    {
        Write(0xED)
        Write(0x42 + register16 * 16)
    }

    public mutating func AddIxReg16(_ register16: Byte)
    {
        Write(0xDD)
        Write(0x09 + register16 * 16)
    }

    public mutating func AddIyReg16(_ register16: Byte)
    {
        Write(0xFD)
        Write(0x09 + register16 * 16)
    }

    public mutating func IncReg16(_ register16: Byte)
    {
        Write(0x03 + register16 * 16)
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

    public mutating func DecReg16(_ register16: Byte)
    {
        Write(0x0B + register16 * 16)
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

    public mutating func RlcReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register)
    }

    public mutating func RlcAddrHl()
    {
        Write(0xCB)
        Write(0x06)
    }

    public mutating func RlcAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x06)
    }

    public mutating func RlcAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x06)
    }

    public mutating func RlReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x10)
    }

    public mutating func RlAddrHl()
    {
        Write(0xCB)
        Write(0x16)
    }

    public mutating func RlAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x16)
    }

    public mutating func RlAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x16)
    }

    public mutating func RrcReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x08)
    }

    public mutating func RrcAddrHl()
    {
        Write(0xCB)
        Write(0x0E)
    }

    public mutating func RrcAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x0E)
    }

    public mutating func RrcAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x0E)
    }

    public mutating func RrReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x18)
    }

    public mutating func RrAddrHl()
    {
        Write(0xCB)
        Write(0x1E)
    }

    public mutating func RrAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x1E)
    }

    public mutating func RrAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x1E)
    }

    public mutating func SlaAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x26)
    }

    public mutating func SlaAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x26)
    }

    public mutating func SlaAddrHl()
    {
        Write(0xCB)
        Write(0x26)
    }

    public mutating func SlaReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x20)
    }

    public mutating func SraReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x28)
    }

    public mutating func SraAddrHl()
    {
        Write(0xCB)
        Write(0x2E)
    }

    public mutating func SraAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x2E)
    }

    public mutating func SraAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x2E)
    }

    public mutating func SrlReg(_ register: Byte)
    {
        Write(0xCB)
        Write(register + 0x38)
    }

    public mutating func SrlAddrHl()
    {
        Write(0xCB)
        Write(0x3E)
    }

    public mutating func SrlAddrIx(_ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x3E)
    }

    public mutating func SrlAddrIy(_ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
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

    public mutating func BitNReg(_ bit: Byte, _ register: Byte)
    {
        Write(0xCB)
        Write(0x40 + bit * 8 + register)
    }

    public mutating func BitNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0x46 + bit * 8)
    }

    public mutating func BitNAtIxd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x46 + bit * 8)
    }

    public mutating func BitNAtIyd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x46 + bit * 8)
    }

    public mutating func SetNReg(_ bit: Byte, _ register: Byte)
    {
        Write(0xCB)
        Write(0xC0 + bit * 8 + register)
    }

    public mutating func SetNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0xC6 + bit * 8)
    }

    public mutating func SetNAtIxd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0xC6 + bit * 8)
    }

    public mutating func SetNAtIyd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0xC6 + bit * 8)
    }

    public mutating func ResNReg(_ bit: Byte, _ register: Byte)
    {
        Write(0xCB)
        Write(0x80 + bit * 8 + register)
    }

    public mutating func ResNAtHl(_ bit: Byte)
    {
        Write(0xCB)
        Write(0x86 + bit * 8)
    }

    public mutating func ResNAtIxd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xDD)
        Write(0xCB)
        Write(displacement)
        Write(0x86 + bit * 8)
    }

    public mutating func ResNAtIyd(_ bit: Byte, _ displacement: SByte)
    {
        Write(0xFD)
        Write(0xCB)
        Write(displacement)
        Write(0x86 + bit * 8)
    }

    public mutating func Jp(_ address: UShort)
    {
        Write(0xC3)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func Jr(_ displacement: SByte)
    {
        Write(0x18)
        Write(displacement - 2)
    }

    public mutating func JrNz(_ displacement: SByte)
    {
        Write(0x20)
        Write(displacement - 2)
    }

    public mutating func JrZ(_ displacement: SByte)
    {
        Write(0x28)
        Write(displacement - 2)
    }

    public mutating func JrNc(_ displacement: SByte)
    {
        Write(0x30)
        Write(displacement - 2)
    }

    public mutating func JrC(_ displacement: SByte)
    {
        Write(0x38)
        Write(displacement - 2)
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

    public mutating func Djnz(_ displacement: SByte)
    {
        Write(0x10)
        Write(displacement - 2)
    }

    public mutating func JpNz(_ address: UShort)
    {
        Write(0xC2)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpZ(_ address: UShort)
    {
        Write(0xCA)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpNc(_ address: UShort)
    {
        Write(0xD2)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpC(_ address: UShort)
    {
        Write(0xDA)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpPo(_ address: UShort)
    {
        Write(0xE2)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpPe(_ address: UShort)
    {
        Write(0xEA)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpP(_ address: UShort)
    {
        Write(0xF2)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func JpM(_ address: UShort)
    {
        Write(0xFA)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func Call(_ address: UShort)
    {
        Write(0xCD)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallNz(_ address: UShort)
    {
        Write(0xC4)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallZ(_ address: UShort)
    {
        Write(0xCC)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallNc(_ address: UShort)
    {
        Write(0xD4)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallC(_ address: UShort)
    {
        Write(0xDC)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallPo(_ address: UShort)
    {
        Write(0xE4)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallPe(_ address: UShort)
    {
        Write(0xEC)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallP(_ address: UShort)
    {
        Write(0xF4)
        Write(address & 0xFF)
        Write(address >> 8)
    }

    public mutating func CallM(_ address: UShort)
    {
        Write(0xFC)
        Write(address & 0xFF)
        Write(address >> 8)
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

    public mutating func InRegBc(_ register: Byte)
    {
        Write(0xED)
        Write(0x40 + register * 8)
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

    public mutating func OutBcReg(_ register: Byte)
    {
        Write(0xED)
        Write(0x41 + register * 8)
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
