#Author-Anton Matosov
#Description-

import adsk.core, adsk.fusion, adsk.cam, traceback



from .URDFExporter import URDFExporter, ExporterUI

def run(context):
    ui = None
    try:    
        
        
        app = adsk.core.Application.get()
        ui  = app.userInterface

        # selectedDirectory = "/Users/antonmatosov/Downloads/exports/u1"
        selectedDirectory = "/Users/antonmatosov/Develop/VM-Shared/ros1/code/src/u1"
        # exporterUI = ExporterUI(ui)
        # exporterUI.askForExportDirectory()
        # selectedDirectory = exporterUI.selectedDirectory

        exporter = URDFExporter(app)
        exporter.export(selectedDirectory)

    except:
        if ui:
            ui.messageBox('Exporting URDF failed:\n{}'.format(traceback.format_exc()))
