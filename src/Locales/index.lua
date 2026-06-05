local addonName, GAC = ...

function GAC:_(key)
    if GAC.Locales and GAC.Locales.ES_es and GAC.Locales.ES_es[key] then
        return GAC.Locales.ES_es[key]
    end
    return string.format("Translate for %s doesn't existe", tostring(key))
end