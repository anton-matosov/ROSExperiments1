

import odio_urdf as urdf


class URDFBuilder:
    current = None

    def robot(self, name):
        self.current = urdf.Robot(name)

    def link(self, name):
        self.__add(urdf.Link(name))

    def __add(self, element):
        if self.current:
            self.current(element)
        self.current = element
