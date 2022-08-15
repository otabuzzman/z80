public protocol IPorts
{
    func ReadPort(_ port: UShort) -> Byte
    func WritePort(_ port: UShort, _ value: Byte)
    var NMI: Bool { get }
    var MI: Bool { get }
    var Data: Byte { get }
}
