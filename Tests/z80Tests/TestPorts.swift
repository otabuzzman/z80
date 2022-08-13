@testable import z80

final class TestPorts: IPorts
{
    private(set) var inputs = Array<byte>(repeating: 0, count: 0x10000)
    private(set) var outputs = Array<byte>(repeating: 0, count: 0x10000)
    private(set) var _data: byte = 0x00
    private(set) var _mi: bool = false
    private(set) var _nmi: bool = false

    func SetInput(_ port: ushort, _ value: byte)
    {
        inputs[port] = value
    }

    func GetOutput(_ port: ushort) -> byte
    {
        return outputs[port];
    }

    func ReadPort(_ port: ushort) -> byte
    {
        return inputs[port];
    }

    func WritePort(_ port: ushort, _ value: byte)
    {
        outputs[port] = value
    }

    var NMI: bool
    {
        get
        {
            let ret = _nmi
            _nmi = false
            return ret
        }
        set { _nmi = newValue }
    }

    var MI: bool
    {
        get
        {
            let ret = _mi
            _mi = false
            return ret
        }
        set { _mi = newValue }
    }

    var Data: byte
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
