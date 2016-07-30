def getLayer(name):
    for lyr in QgsMapLayerRegistry.instance().mapLayers().values():
        print(lyr.name())
        if lyr.name() == name:
            return lyr
    
layer = getLayer('ped_counts')