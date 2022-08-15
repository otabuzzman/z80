public class Memory
{
    private(set) var memory: [Byte]
    private(set) var start: UShort

    public init(_ ram: [Byte], _ start: UShort)
    {
        memory = ram
        self.start = start
    }

    public func clear() {
        for addr in 0..<memory.count {
            memory[addr] = 0
        }
    }

    public subscript(address: UShort) -> Byte {
        get {
            memory[Int(address)]
        }
        set(newValue) {
            if address >= start {
                memory[Int(address)] = newValue
            }
        }
    }
}
