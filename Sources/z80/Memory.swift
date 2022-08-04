public class Memory
{
    private(set) var memory: [byte]
    private(set) var start: ushort

    public init(_ ram: [byte], _ start: ushort)
    {
        memory = ram
        self.start = start
    }

    public func clear() {
        for addr in 0..<memory.count {
            memory[addr] = 0
        }
    }

    public subscript(address: ushort) -> byte {
        get {
            memory[int(address)]
        }
        set(newValue) {
            if address >= start {
                memory[int(address)] = newValue
            }
        }
    }
}
