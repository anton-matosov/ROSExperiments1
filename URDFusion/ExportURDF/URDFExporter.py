
from . import odio_urdf as urdf
from .STLExporter import *
import adsk.core
import adsk.fusion
import adsk.cam
import traceback
import os
import errno
import logging
import math

class ExporterUI:
    selectedDirectory = ""

    def __init__(self, ui):
        self.ui = ui

    def askForExportDirectory(self):
        fileDialog = self.ui.createFileDialog()
        fileDialog.isMultiSelectEnabled = False
        fileDialog.title = "Export to"
        fileDialog.filter = "directory (*/*)"
        fileDialog.filterIndex = 0
        fileDialog.initialDirectory = self.selectedDirectory
        dialogResult = fileDialog.showSave()

        if dialogResult == adsk.core.DialogResults.DialogOK:
            self.selectedDirectory = fileDialog.filename


def traverseAssembly(occurrences, currentLevel, inputString):
    for occ in occurrences:
        inputString += ' ' * (currentLevel * 5) + 'Name: ' + occ.name + '\n'
        traverseJoints(occ.component, currentLevel, inputString)


        if occ.childOccurrences:
            inputString = traverseAssembly(
                occ.childOccurrences, currentLevel + 1, inputString)

    return inputString


def traverseJoints(component, currentLevel, inputString):
    for joint in component.joints:
        inputString += ' ' * (currentLevel * 5 + 2) + \
            'Joint: {}, type: {}\n'.format(
                joint.name, joint.jointMotion.jointType)
    return inputString


def allBodies(design):
    return [body for component in design.allComponents for body in component.bRepBodies]


class URDFExporter:

    def __init__(self, app, *args, **kwargs):
        self.app = app
        self.ui = self.app.userInterface

        # get active design
        self.product = self.app.activeProduct
        self.design = adsk.fusion.Design.cast(self.product)

        if not self.design:
            self.ui.messageBox('No active Fusion design', 'No Design')
            return

        self.stl_exporter = STLExporter(design = self.design)

        # get root component in this design
        self.rootComponent = self.design.rootComponent

    def export(self, destination):
        # self.showDocumentStructure()

        self.destination = destination
        self.destination_meshes = os.path.join(destination, 'meshes')
        self.destination_urdf = os.path.join(destination, 'urdf')
        self.modelName = os.path.basename(self.destination)

        self.createDirectoryStructure()
        self.createLogger()

        self.export_all_stl()
        self.build_urdf()

        self.ui.messageBox('Exported URDF successfully')

    def showDocumentStructure(self):
        resultString = 'Assembly structure of ' + \
            self.design.parentDocument.name + '\n'
        resultString = traverseJoints(self.rootComponent, 1, resultString)
        resultString = traverseAssembly(
            self.rootComponent.occurrences.asList, 1, resultString)

        resultString += "\n\nAll Bodies:\n"
        for body in allBodies(self.design):
            resultString += " - {}\n".format(body.name)
        
        resultString += "\n\nAll Bodies as self.rootComponent.bRepBodies:\n"
        for body in self.rootComponent.bRepBodies:
            resultString += " - {}\n".format(body.name)

        # Display the result.
        self.ui.messageBox(resultString)

    def export_all_stl(self):
        self.stl_exporter.export_recursively(self.rootComponent.occurrences,
            destination_folder = self.destination_meshes)

    def build_urdf(self):
        robot = urdf.Robot("robot")
        for occurrence in self.rootComponent.occurrences:
            
            name = self._element_name(occurrence.name)
            link = urdf.Link(
                urdf.Visual(
                    self._origin_for_occurence(occurrence),
                    urdf.Geometry(
                        urdf.Mesh(filename = self._mesh_path(occurrence)
                            , scale="0.001 0.001 0.001"
                        )
                        , name = name + "_visual"
                    )
                )
                , name = name
            )
            robot(link)
        
        for joint in self.rootComponent.joints:
            # switch joint.jointMotion.jointType:
            # adsk.fusion.RevoluteJointType
            # adsk.fusion.RigidJointType
            # adsk.fusion.SliderJointType
            # adsk.fusion.PlanarJointType
            # adsk.fusion.BallJointType
            parent = urdf.Parent(self._element_name(joint.occurrenceOne.name))
            child = urdf.Child(self._element_name(joint.occurrenceTwo.name))
            limits = urdf.Limit(effort=1000, velocity=0.5,
                lower=joint.jointMotion.rotationLimits.minimumValue,
                upper=joint.jointMotion.rotationLimits.maximumValue)
# vec = joi.geometryOrOriginTwo.origin
#         print(vec.asArray())
            axis = urdf.Axis(xyz = self._vector_str(joint.jointMotion.rotationAxisVector))
            origin = urdf.Origin(xyz=self._vector_str(joint.geometryOrOriginTwo.origin))
            jointModel = urdf.Joint(parent, child, limits, axis, origin, type="revolute", name=joint.name) 

            robot(jointModel)

        file = open(self.destination_urdf + '/robot.urdf', 'w')
        try:
            file.write(str(robot))
        finally:
            file.close()

    def _origin_for_occurence(self, occurrence):
        matrix = occurrence.transform
        
        # calculate roll pitch yaw from transformation matrix
        r11 = matrix.getCell(0, 0)
        r21 = matrix.getCell(1, 0)
        r31 = matrix.getCell(2, 0)
        r32 = matrix.getCell(2, 1)
        r33 = matrix.getCell(2, 2)
        
        pitch = math.atan2(-r31, math.sqrt(math.pow(r11, 2) + math.pow(r21, 2)))
        cp = math.cos(pitch)
        yaw = math.atan2(r21 / cp, r11 / cp)
        roll = math.atan2(r32 / cp, r33 / cp)
        
        return urdf.Origin(xyz = self._vector_str(matrix.translation), 
            rpy = "{} {} {}".format(roll, pitch, yaw))

    def _vector_str(self, vector):
        return "{} {} {}".format(vector.x, vector.y, vector.z)

    def _element_name(self, name):
        return name.replace(':', "_") \
            .replace('/', "_") \
            .replace('_1', "")

    def _mesh_path(self, occurrence):
        mesh_path = os.path.relpath(self.stl_exporter.path_for_occurence(occurrence), self.destination)
        return "package://{}/{}".format(self.modelName, mesh_path)

    def createDirectoryStructure(self):
        os.makedirs(self.destination, exist_ok=True)
        os.makedirs(self.destination_meshes, exist_ok=True)
        os.makedirs(self.destination_urdf, exist_ok=True)

    def createLogger(self):
        pass
        # self.logfile = open(self.destination + '/logfile.txt', 'w')
