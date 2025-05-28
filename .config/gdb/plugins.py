import gdb.printing

class Arena_printer(gdb.ValuePrinter):
    def __init__(self, val):
        self.val = val

    def to_string(self):
        beg = self.val["beg"]
        end = self.val["end"]
        return '{capacity: %d}' % (end - beg)

class Stream_printer(gdb.ValuePrinter):
    def __init__(self, val):
        self.val = val

    def to_string(self):
        len = self.val["widx"]
        str = self.val["data"].string(length=min(max(len, 0), 64))
        return '{len = %d, data = "%s"}' % (len, str)

class str8_printer(gdb.ValuePrinter):
    def __init__(self, val):
        self.val = val

    def to_string(self):
        len = self.val["len"]
        str = self.val["data"].string(length=min(max(len, 0), 64))
        return '{len = %d, data = "%s"}' % (len, str)

def build_pretty_printer():
    pp = gdb.printing.RegexpCollectionPrettyPrinter("rnpnr")
    pp.add_printer("s8",     "s8",     str8_printer)
    pp.add_printer("str8",   "str8",   str8_printer)
    pp.add_printer("Arena",  "Arena",  Arena_printer)
    pp.add_printer("Stream", "Stream", Stream_printer)
    return pp

gdb.printing.register_pretty_printer(
    gdb.current_objfile(), build_pretty_printer()
)
