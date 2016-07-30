def getLayer(name):
    for lyr in QgsMapLayerRegistry.instance().mapLayers().values():
        if lyr.name() == name:
            return lyr
    
ped_layer = getLayer('ped_counts')
building_layer = getLayer('buildings_with_lat_long')
scratch_layer = getLayer('scratch')
building_features = [b for b in building_layer.getFeatures() if b.geometry() ]

canvas = iface.mapCanvas()

distancearea = QgsDistanceArea()
distancearea.setSourceCrs(canvas.mapRenderer().destinationCrs().srsid())
ellispoid = QgsProject.instance().readEntry("Measure", "/Ellipsoid", GEO_NONE)
distancearea.setEllipsoid(ellispoid[0])
mode = canvas.mapRenderer().hasCrsTransformEnabled()
# distancearea.setEllipsoidalMode(ellispoidemode)

for count in ped_layer.getFeatures():
    # circ = count.geometry().buffer(0.01, 100)
    # print(circ)
    # resulting = [pt for pt in building_features if circ.contains(pt.geometry())]
    resulting = [pt for pt in building_features if ( distancearea.measureLine(pt.geometry().asPoint(), count.geometry().asPoint()) < 0.001)]
    print len(resulting)
    # feat = QgsFeature()
    # feat.setGeometry(circ)
    # scratch_layer.dataProvider().addFeatures([feat])
 
    