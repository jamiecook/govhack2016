from sets import Set

def getLayer(name):
    for lyr in QgsMapLayerRegistry.instance().mapLayers().values():
        if lyr.name() == name:
            return lyr
    
layer = getLayer('buildings_with_lat_long')

uses = Set()
for v in layer.getValues('Predominant space use')[0]:
    uses.add(v)
    
print(uses)
    