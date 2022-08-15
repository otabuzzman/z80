public protocol IPorts
{
    func rdPort(_ port: UShort) -> Byte
    func wrPort(_ port: UShort, _ data: Byte)

    var NMI: Bool { get }
    var MI: Bool { get }
    var data: Byte { get }
}

public protocol MPorts
{
    func rdPort(_ addr: UShort) -> Byte
    func wrPort(_ addr: UShort, _ data: Byte)

    var mmap: ClosedRange<UShort> { get }
}
