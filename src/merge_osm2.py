import sys
from xml.etree import ElementTree as et

class XMLCombiner(object):
    def __init__(self, filenames):
        assert len(filenames) > 0, 'No filenames!'
        # save all the roots, in order, to be processed later
        self.roots = [et.parse(f).getroot() for f in filenames]

    def combine(self):
        for node in self.roots[1].findall('node'):
            node.attrib["id"] = str(int(node.attrib["id"]) - 1000000)
            self.roots[0].append(node)
        # return the string representation
        return et.tostring(self.roots[0])


if __name__ == '__main__':

    targs = len(sys.argv)
    if targs != 4:
        print ("Error: wrong number of arguments.")
        print ("usage: merge_osm polygons.osm nodes.osm output.osm")
        exit()

    firstosm = str(sys.argv[1])
    secondosm = str(sys.argv[2])
    outputosm = str(sys.argv[3])

    r = XMLCombiner((firstosm, secondosm)).combine()
    f = open(outputosm, 'w')
    f.write(r)
    f.close()
