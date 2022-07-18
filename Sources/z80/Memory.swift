public struct Memory {
    private(set) var memory: [UInt8]
    private(set) var ramStart: UInt16

    public subscript(address: UInt16) -> UInt8 {
        get {
            memory[Int(address)]
        }

        set(newValue) {
            if address >= ramStart {
                memory[Int(address)] = newValue
            }
        }
    }

    init(_ memory: [UInt8], _ ramStart: UInt16) {
        self.memory = memory
        self.ramStart = ramStart
    }
}
