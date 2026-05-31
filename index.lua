local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.0.0"


print("Cargando ", GAC.name, " versión ", GAC.version)
if WLV_Extends  then
    print("WLV Extension cargado con la versión ", WLV_Extends.GetVersion())
end