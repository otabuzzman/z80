public struct Z80Asm {
    private(set) var ram: [UInt8]

    private var position: UInt16

    init(_ ram: [UInt8]) {
        self.ram = ram
        position = 0
    }

    public mutating func reset() {
        for i in 0..<ram.count {
            ram[i] = 0
        }
        position = 0
    }

    public mutating func halt() {
        write(0x76)
    }

    public mutating func write(_ value: Int) {
        write(UInt8(value))
    }

    public mutating func write(_ value: UInt8) {
            ram[Int(position)] = value
            position += 1
    }

    public mutating func noop() {
        write(0x00)
    }

    public mutating func loadRegVal(_ register: UInt8, _ value: UInt8) {
        write(register * 8 + 6)
        write(value)
    }

    public mutating func loadRegReg(_ register: UInt8, _ register2: UInt8) {
        write(register * 8 + register2 + 64)
    }

    public mutating func loadReg16Val(_ register16: UInt8, _ value: UInt16) {
        write(1 + register16 * 16)
        write(UInt8(value & 0xFF))
        write(UInt8(value >> 8))
    }

    public mutating func loadRegAtHl(_ register: UInt8) {
        write(70 + register * 8)
    }

    public mutating func data(_ value: UInt8) {
        write(value)
    }

    public mutating func loadRegAddrIx(_ register: UInt8, _ displacement: Int8) {
        write(0xDD)
        write(70 + register * 8)
        write(Int(displacement))
    }

    public mutating func loadIxVal(_ value: UInt16) {
        write(0xDD)
        write(33)
        write(UInt8(value & 0xFF))
        write(UInt8(value >> 8))
    }

    public mutating func loadRegAddrIy(_ register: UInt8, _ displacement: Int8) {
        write(0xFD)
        write(70 + register * 8)
        write(Int(displacement))
    }

    public mutating func loadIyVal(_ value: Int) {
        write(0xFD)
        write(33)
        write(UInt8(value & 0xFF))
        write(UInt8(value >> 8))
    }

    public mutating func loadAtHLReg(_ register: UInt8) {
        write(0x70 + register)
    }

    public mutating func loadIxR(_ register: UInt8, _ displacement: Int8) {
        write(0xDD)
        write(0x70 + register)
        write(Int(displacement))
    }

    public mutating func loadIyReg(_ register: UInt8, _ displacement: Int8) {
        write(0xFD)
        write(0x70 + register)
        write(Int(displacement))
    }

    public mutating func loadAtHLVal(_ value: UInt8) {
        write(0x36)
        write(value)
    }

    public mutating func loadAtIxVal(_ displacement: Int8, _ value: UInt8) {
        write(0xDD)
        write(0x36)
        write(Int(displacement))
        write(value)
    }

    public mutating func loadIyN(_ displacement: Int8, _ value: UInt8) {
        write(0xFD)
        write(0x36)
        write(Int(displacement))
        write(value)
    }

    public mutating func loadABc() {
        write(0x0A)
    }

    public mutating func loadADe() {
        write(0x1A)
    }

    public mutating func loadAAddr(_ address: UInt16) {
        write(0x3A)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadBcA() {
        write(0x02)
    }

    public mutating func loadDeA() {
        write(0x12)
    }

    public mutating func loadAddrA(_ address: UInt16) {
        write(0x32)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadAI() {
        write(0xED)
        write(0x57)
    }

    public mutating func loadIA() {
        write(0xED)
        write(0x47)
    }

    public mutating func loadAR() {
        write(0xED)
        write(0x5F)
    }

    public mutating func loadRA() {
        write(0xED)
        write(0x4F)
    }

    public mutating func di() {
        write(0xF3)
    }

    public mutating func ei() {
        write(0xFB)
    }

    public mutating func loadHlAddr(_ address: UInt16) {
        write(0x2A)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadReg16Addr(_ register16: UInt8, _ address: UInt16) {
        write(0xED)
        write(0x4B + register16 * 16)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadIXAddr(_ address: UInt16) {
        write(0xDD)
        write(0x2A)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadIYAddr(_ address: UInt16) {
        write(0xFD)
        write(0x2A)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadAddrHl(_ address: UInt16) {
        write(0x22)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadAddrReg16(_ register16: UInt8, _ address: UInt16) {
        write(0xED)
        write(0x43 + register16 * 16)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadAddrIx(_ address: UInt16) {
        write(0xDD)
        write(0x22)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadAddrIy(_ address: UInt16) {
        write(0xFD)
        write(0x22)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func loadSpHl() {
        write(0xF9)
    }

    public mutating func loadSpIx() {
        write(0xDD)
        write(0xF9)
    }

    public mutating func loadSpIy() {
        write(0xFD)
        write(0xF9)
    }

    public mutating func pushReg16(_ register16: UInt8) {
        write(0xC5 + register16 * 16)
    }

    public mutating func pushIx() {
        write(0xDD)
        write(0xE5)
    }

    public mutating func pushIy() {
        write(0xFD)
        write(0xE5)
    }

    public mutating func popReg16(_ register16: UInt8) {
        write(0xC1 + register16 * 16)
    }

    public mutating func popIx() {
        write(0xDD)
        write(0xE1)
    }

    public mutating func popIy() {
        write(0xFD)
        write(0xE1)
    }

    public mutating func exDeHl() {
        write(0xEB)
    }

    public mutating func exAfAfp() {
        write(0x08)
    }

    public mutating func exx() {
        write(0xD9)
    }

    public mutating func exAddrSpHl() {
        write(0xE3)
    }

    public mutating func exAddrSpIx() {
        write(0xDD)
        write(0xE3)
    }

    public mutating func exAddrSpIy() {
        write(0xFD)
        write(0xE3)
    }

    public mutating func ldi() {
        write(0xED)
        write(0xA0)
    }

    public mutating func ldir() {
        write(0xED)
        write(0xB0)
    }

    public mutating func ldd() {
        write(0xED)
        write(0xA8)
    }

    public mutating func lddr() {
        write(0xED)
        write(0xB8)
    }

    public mutating func cpi() {
        write(0xED)
        write(0xA1)
    }

    public mutating func cpir() {
        write(0xED)
        write(0xB1)
    }

    public mutating func cpd() {
        write(0xED)
        write(0xA9)
    }

    public mutating func cpdr() {
        write(0xED)
        write(0xB9)
    }

    public mutating func addAReg(_ register: UInt8) {
        write(0x80 + register)
    }

    public mutating func addAVal(_ value: UInt8) {
        write(0xC6)
        write(value)
    }

    public mutating func addAAddrHl() {
        write(0x86)
    }

    public mutating func addAAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x86)
        write(Int(displacement))
    }

    public mutating func addAAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x86)
        write(Int(displacement))
    }

    public mutating func adcAReg(_ register: UInt8) {
        write(0x88 + register)
    }

    public mutating func adcAVal(_ value: UInt8) {
        write(0xCE)
        write(value)
    }

    public mutating func adcAAddrHl() {
        write(0x8E)
    }

    public mutating func adcAAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x8E)
        write(Int(displacement))
    }

    public mutating func adcAAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x8E)
        write(Int(displacement))
    }

    public mutating func subReg(_ register: UInt8) {
        write(0x90 + register)
    }

    public mutating func subVal(_ value: UInt8) {
        write(0xD6)
        write(value)
    }

    public mutating func subAddrHl() {
        write(0x96)
    }

    public mutating func subAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x96)
        write(Int(displacement))
    }

    public mutating func subAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x96)
        write(Int(displacement))
    }

    public mutating func sbcAReg(_ register: UInt8) {
        write(0x98 + register)
    }

    public mutating func sbcAVal(_ value: UInt8) {
        write(0xDE)
        write(value)
    }

    public mutating func sbcAAddrHl() {
        write(0x9E)
    }

    public mutating func sbcAAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x9E)
        write(Int(displacement))
    }

    public mutating func sbcAAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x9E)
        write(Int(displacement))
    }

    public mutating func andReg(_ register: UInt8) {
        write(0xA0 + register)
    }

    public mutating func andVal(_ value: UInt8) {
        write(0xE6)
        write(value)
    }

    public mutating func andAddrHl() {
        write(0xA6)
    }

    public mutating func andAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xA6)
        write(Int(displacement))
    }

    public mutating func andAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xA6)
        write(Int(displacement))
    }

    public mutating func orReg(_ register: UInt8) {
        write(0xB0 + register)
    }

    public mutating func orVal(_ value: UInt8) {
        write(0xF6)
        write(value)
    }

    public mutating func orAddrHl() {
        write(0xB6)
    }

    public mutating func orAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xB6)
        write(Int(displacement))
    }

    public mutating func orAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xB6)
        write(Int(displacement))
    }

    public mutating func xorReg(_ register: UInt8) {
        write(0xA8 + register)
    }

    public mutating func xorVal(_ value: UInt8) {
        write(0xEE)
        write(value)
    }

    public mutating func xorAddrHl() {
        write(0xAE)
    }

    public mutating func xorAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xAE)
        write(Int(displacement))
    }

    public mutating func xorAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xAE)
        write(Int(displacement))
    }

    public mutating func cpReg(_ register: UInt8) {
        write(0xB8 + register)
    }

    public mutating func cpVal(_ value: UInt8) {
        write(0xFE)
        write(value)
    }

    public mutating func cpAddrHl() {
        write(0xBE)
    }

    public mutating func cpAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xBE)
        write(Int(displacement))
    }

    public mutating func cpAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xBE)
        write(Int(displacement))
    }

    public mutating func incReg(_ register: UInt8) {
        write(0x04 + register * 8)
    }

    public mutating func incAddrHl() {
        write(0x34)
    }

    public mutating func incAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x34)
        write(Int(displacement))
    }

    public mutating func incAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x34)
        write(Int(displacement))
    }

    public mutating func decReg(_ register: UInt8) {
        write(0x05 + register * 8)
    }

    public mutating func decAddrHl() {
        write(0x35)
    }

    public mutating func decAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0x35)
        write(Int(displacement))
    }

    public mutating func decAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0x35)
        write(Int(displacement))
    }

    public mutating func daa() {
        write(0x27)
    }

    public mutating func cpl() {
        write(0x2F)
    }

    public mutating func neg() {
        write(0xED)
        write(0x44)
    }

    public mutating func ccf() {
        write(0x3F)
    }

    public mutating func scf() {
        write(0x37)
    }

    public mutating func im0() {
        write(0xED)
        write(0x46)
    }

    public mutating func im1() {
        write(0xED)
        write(0x56)
    }

    public mutating func im2() {
        write(0xED)
        write(0x5E)
    }

    public mutating func addHlReg16(_ register16: UInt8) {
        write(0x09 + register16 * 16)
    }

    public mutating func adcHlReg16(_ register16: UInt8) {
        write(0xED)
        write(0x4A + register16 * 16)
    }

    public mutating func sbcHlReg16(_ register16: UInt8) {
        write(0xED)
        write(0x42 + register16 * 16)
    }

    public mutating func addIxReg16(_ register16: UInt8) {
        write(0xDD)
        write(0x09 + register16 * 16)
    }

    public mutating func addIyReg16(_ register16: UInt8) {
        write(0xFD)
        write(0x09 + register16 * 16)
    }

    public mutating func incReg16(_ register16: UInt8) {
        write(0x03 + register16 * 16)
    }

    public mutating func incIx() {
        write(0xDD)
        write(0x23)
    }

    public mutating func incIy() {
        write(0xFD)
        write(0x23)
    }

    public mutating func decReg16(_ register16: UInt8) {
        write(0x0B + register16 * 16)
    }

    public mutating func decIx() {
        write(0xDD)
        write(0x2B)
    }

    public mutating func decIy() {
        write(0xFD)
        write(0x2B)
    }

    public mutating func rlca() {
        write(0x07)
    }

    public mutating func rla() {
        write(0x17)
    }

    public mutating func rrca() {
        write(0x0F)
    }

    public mutating func rra() {
        write(0x1F)
    }

    public mutating func rlcReg(_ register: UInt8) {
        write(0xCB)
        write(register)
    }

    public mutating func rlcAddrHl() {
        write(0xCB)
        write(0x06)
    }

    public mutating func rlcAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x06)
    }

    public mutating func rlcAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x06)
    }

    public mutating func rlReg(_ register: UInt8) {
        write(0xCB)
        write(0x10 + register)
    }

    public mutating func rlAddrHl() {
        write(0xCB)
        write(0x16)
    }

    public mutating func rlAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x16)
    }

    public mutating func rlAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x16)
    }

    public mutating func rrcReg(_ register: UInt8) {
        write(0xCB)
        write(0x08 + register)
    }

    public mutating func rrcAddrHl() {
        write(0xCB)
        write(0x0E)
    }

    public mutating func rrcAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x0E)
    }

    public mutating func rrcAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x0E)
    }

    public mutating func rrReg(_ register: UInt8) {
        write(0xCB)
        write(0x18 + register)
    }

    public mutating func rrAddrHl() {
        write(0xCB)
        write(0x1E)
    }

    public mutating func rrAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x1E)
    }

    public mutating func rrAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x1E)
    }

    public mutating func slaAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x26)
    }

    public mutating func slaAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x26)
    }

    public mutating func slaAddrHl() {
        write(0xCB)
        write(0x26)
    }

    public mutating func slaReg(_ register: UInt8) {
        write(0xCB)
        write(0x20 + register)
    }

    public mutating func sraReg(_ register: UInt8) {
        write(0xCB)
        write(0x28 + register)
    }

    public mutating func sraAddrHl() {
        write(0xCB)
        write(0x2E)
    }

    public mutating func sraAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x2E)
    }

    public mutating func sraAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x2E)
    }

    public mutating func srlReg(_ register: UInt8) {
        write(0xCB)
        write(0x38 + register)
    }

    public mutating func srlAddrHl() {
        write(0xCB)
        write(0x3E)
    }

    public mutating func srlAddrIx(_ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x3E)
    }

    public mutating func srlAddrIy(_ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x3E)
    }

    public mutating func rld() {
        write(0xED)
        write(0x6F)
    }

    public mutating func rrd() {
        write(0xED)
        write(0x67)
    }

    public mutating func bitNReg(_ bit: UInt8, _ register: UInt8) {
        write(0xCB)
        write(0x40 + bit * 8 + register)
    }

    public mutating func bitNAtHl(_ bit: UInt8) {
        write(0xCB)
        write(0x46 + bit * 8)
    }

    public mutating func bitNAtIxd(_ bit: UInt8, _ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x46 + bit * 8)
    }

    public mutating func bitNAtIyd(_ bit: UInt8, _ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x46 + bit * 8)
    }

    public mutating func setNReg(_ bit: UInt8, _ register: UInt8) {
        write(0xCB)
        write(0xC0 + bit * 8 + register)
    }

    public mutating func setNAtHl(_ bit: UInt8) {
        write(0xCB)
        write(0xC6 + bit * 8)
    }

    public mutating func setNAtIxd(_ bit: UInt8, _ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0xC6 + bit * 8)
    }

    public mutating func setNAtIyd(_ bit: UInt8, _ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0xC6 + bit * 8)
    }

    public mutating func resNReg(_ bit: UInt8, _ register: UInt8) {
        write(0xCB)
        write(0x80 + bit * 8 + register)
    }

    public mutating func resNAtHl(_ bit: UInt8) {
        write(0xCB)
        write(0x86 + bit * 8)
    }

    public mutating func resNAtIxd(_ bit: UInt8, _ displacement: Int8) {
        write(0xDD)
        write(0xCB)
        write(Int(displacement))
        write(0x86 + bit * 8)
    }

    public mutating func resNAtIyd(_ bit: UInt8, _ displacement: Int8) {
        write(0xFD)
        write(0xCB)
        write(Int(displacement))
        write(0x86 + bit * 8)
    }

    public mutating func jp(_ address: UInt16) {
        write(0xC3)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jr(_ displacement: Int8) {
        write(0x18)
        write(Int(displacement - 2))
    }

    public mutating func jrNz(_ displacement: Int8) {
        write(0x20)
        write(Int(displacement - 2))
    }

    public mutating func jrZ(_ displacement: Int8) {
        write(0x28)
        write(Int(displacement - 2))
    }

    public mutating func jrNc(_ displacement: Int8) {
        write(0x30)
        write(Int(displacement - 2))
    }

    public mutating func jrC(_ displacement: Int8) {
        write(0x38)
        write(Int(displacement - 2))
    }

    public mutating func jpHl() {
        write(0xE9)
    }

    public mutating func jpIx() {
        write(0xDD)
        write(0xE9)
    }

    public mutating func jpIy() {
        write(0xFD)
        write(0xE9)
    }

    public mutating func djnz(_ displacement: Int8) {
        write(0x10)
        write(Int(displacement - 2))
    }

    public mutating func jpNz(_ address: UInt16) {
        write(0xC2)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpZ(_ address: UInt16) {
        write(0xCA)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpNc(_ address: UInt16) {
        write(0xD2)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpC(_ address: UInt16) {
        write(0xDA)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpPo(_ address: UInt16) {
        write(0xE2)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpPe(_ address: UInt16) {
        write(0xEA)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpP(_ address: UInt16) {
        write(0xF2)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func jpM(_ address: UInt16) {
        write(0xFA)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func call(_ address: UInt16) {
        write(0xCD)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callNz(_ address: UInt16) {
        write(0xC4)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callZ(_ address: UInt16) {
        write(0xCC)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callNc(_ address: UInt16) {
        write(0xD4)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callC(_ address: UInt16) {
        write(0xDC)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callPo(_ address: UInt16) {
        write(0xE4)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callPe(_ address: UInt16) {
        write(0xEC)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callP(_ address: UInt16) {
        write(0xF4)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func callM(_ address: UInt16) {
        write(0xFC)
        write(UInt8(address & 0xFF))
        write(UInt8(address >> 8))
    }

    public mutating func ret() {
        write(0xC9)
    }

    public mutating func retNz() {
        write(0xC0)
    }

    public mutating func retZ() {
        write(0xC8)
    }

    public mutating func retNc() {
        write(0xD0)
    }

    public mutating func retC() {
        write(0xD8)
    }

    public mutating func retPo() {
        write(0xE0)
    }

    public mutating func retPe() {
        write(0xE8)
    }

    public mutating func retP() {
        write(0xF0)
    }

    public mutating func retM() {
        write(0xF8)
    }

    public mutating func retI() {
        write(0xED)
        write(0x4D)
    }

    public mutating func retN() {
        write(0xED)
        write(0x45)
    }

    public mutating func rst(_ page: UInt8) {
        write(0xC7 + page * 8)
    }

    public mutating func inAPort(_ port: UInt8) {
        write(0xDB)
        write(port)
    }

    public mutating func inRegBc(_ register: UInt8) {
        write(0xED)
        write(0x40 + register * 8)
    }

    public mutating func ini() {
        write(0xED)
        write(0xA2)
    }

    public mutating func inir() {
        write(0xED)
        write(0xB2)
    }

    public mutating func ind() {
        write(0xED)
        write(0xAA)
    }

    public mutating func indr() {
        write(0xED)
        write(0xBA)
    }

    public mutating func outPortA(_ port: UInt8) {
        write(0xD3)
        write(port)
    }

    public mutating func outBcReg(_ register: UInt8) {
        write(0xED)
        write(0x41 + register * 8)
    }

    public mutating func outi() {
        write(0xED)
        write(0xA3)
    }

    public mutating func outir() {
        write(0xED)
        write(0xB3)
    }

    public mutating func outd() {
        write(0xED)
        write(0xAB)
    }

    public mutating func outdr() {
        write(0xED)
        write(0xBB)
    }
}
