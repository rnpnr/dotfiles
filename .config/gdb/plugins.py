import gdb.printing


class s8_printer(gdb.ValuePrinter):
    def __init__(self, val):
        self.val = val

    def to_string(self):
        len = self.val["len"]
        str = self.val["data"].string(length=len)
        return '{data = "%s", len = %s}' % (str, len)


def build_pretty_printer():
    pp = gdb.printing.RegexpCollectionPrettyPrinter("rnpnr")
    pp.add_printer("s8", "s8", s8_printer)
    return pp


gdb.printing.register_pretty_printer(
    gdb.current_objfile(), build_pretty_printer()
)
