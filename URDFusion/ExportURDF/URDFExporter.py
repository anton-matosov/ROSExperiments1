
from . import odio_urdf as urdf
from .STLExporter import *
import adsk.core
import adsk.fusion
import adsk.cam
import traceback
import os
import errno
import logging


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

        # adsk.fusion.RevoluteJointType
        # adsk.fusion.RigidJointType
        # adsk.fusion.SliderJointType
        # adsk.fusion.PlanarJointType
        # adsk.fusion.BallJointType

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
            mesh_path = os.path.relpath(self.stl_exporter.path_for_occurence(occurrence), self.destination)
            link = urdf.Link(
                urdf.Visual(
                    urdf.Geometry(
                        urdf.Mesh(filename=mesh_path)
                        , name = occurrence.name + "_visual"
                    )
                )
                , name = occurrence.name
            )
            robot(link)

        file = open(self.destination + '/robot.urdf', 'w')
        try:
            file.write(str(robot))
        finally:
            file.close()

        # base = urdf.Parent("link1")
        # joint1 = urdf.Joint(base, urdf.Child("link2"), type="revolute") 

    def createDirectoryStructure(self):
        os.makedirs(self.destination, exist_ok=True)
        os.makedirs(self.destination_meshes, exist_ok=True)

    def createLogger(self):
        self.logfile = open(self.destination + '/logfile.txt', 'w')