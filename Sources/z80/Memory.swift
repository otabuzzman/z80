public class Memory
{
    private(set) var mem: [Byte]
    private(set) var start: UShort

    public init(_ ram: [Byte], _ start: UShort)
    {
        mem = ram
        self.start = start
    }

    public func clear() {
        for addr in 0..<mem.count {
            mem[addr] = 0
        }
    }

    public subscript(addr: UShort) -> Byte {
        get {
            mem[Int(addr)]
        }
        set(newValue) {
            if addr >= start {
                mem[Int(addr)] = newValue
            }
        }
    }
}
