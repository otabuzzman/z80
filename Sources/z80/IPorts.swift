public protocol IPorts
{
    func rdPort(_ port: UShort) -> Byte
    func wrPort(_ port: UShort, _ data: Byte)
    var NMI: Bool { get }
    var MI: Bool { get }
    var data: Byte { get }
}
