
import adsk.fusion
import os

class STLExporter:
    def __init__(self, design):
        self.export_manager = design.exportManager
        self.occurence_to_path = {}
        self.component_to_path = {}

    def export_recursively(self, occurences, destination_folder):
        for occurence in occurences:
            self.export(occurence, destination_folder)
            self.export_recursively(occurence.childOccurrences, destination_folder)

    def export(self, occurence, destination_folder):
        already_saved_stl = self.component_to_path.get(occurence.component.name, None)

        path = os.path.join(destination_folder, self._as_export_name(occurence.component.name) + '.stl')
        self.occurence_to_path[occurence.name] = path
        self.component_to_path[occurence.component.name] = path

        if already_saved_stl:
            return True
            
        stl_export_options = self.export_manager.createSTLExportOptions(occurence, path)
        stl_export_options.meshRefinement = adsk.fusion.MeshRefinementSettings.MeshRefinementLow
        stl_export_options.isBinaryFormat = False
        stl_export_options.isOneFilePerBody = False

        return self.export_manager.execute(stl_export_options)
    
    def _as_export_name(self, name):
        return name.replace(':', "_").replace('/', "_")

    def path_for_occurence(self, occurence):
        return self.occurence_to_path[occurence.name]

    def path_for_component(self, component):
        return self.component_to_path[component.name]
