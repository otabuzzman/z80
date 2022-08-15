@testable import z80

final class TestPorts: IPorts
{
    private(set) var inputs = Array<Byte>(repeating: 0, count: 0x10000)
    private(set) var outputs = Array<Byte>(repeating: 0, count: 0x10000)
    private(set) var nmi: Bool = false
    private(set) var int: Bool = false
    private(set) var _data: Byte = 0x00

    func SetInput(_ port: UShort, _ value: Byte)
    {
        inputs[port] = value
    }

    func GetOutput(_ port: UShort) -> Byte
    {
        return outputs[port];
    }

    func rdPort(_ port: UShort) -> Byte
    {
        return inputs[port];
    }

    func wrPort(_ port: UShort, _ data: Byte)
    {
        outputs[port] = data
    }

    var NMI: Bool
    {
        get
        {
            let ret = nmi
            nmi = false
            return ret
        }
        set { nmi = newValue }
    }

    var INT: Bool
    {
        get
        {
            let ret = int
            int = false
            return ret
        }
        set { int = newValue }
    }

    var data: Byte
    {
        get
        {
            let ret = _data
            _data = 0x00
            return ret
        }
        set { _data = newValue }
    }
}

final class TestMPorts: MPorts
{
    private var block: Array<Byte>

    init(_ mmap: ClosedRange<UShort>) {
        self.mmap = mmap
        block = Array<Byte>(repeating: 0, count: Int(mmap.upperBound - mmap.lowerBound + 1))
    }

    func rdPort(_ port: UShort) -> Byte
    {
        return block[port - mmap.lowerBound] + 1;
    }

    func wrPort(_ port: UShort, _ data: Byte)
    {
        block[port - mmap.lowerBound] = data + 1
    }

    var mmap: ClosedRange<UShort>
}
