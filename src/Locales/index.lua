local addonName, GAC = ...

function GAC:_(key)
    if GAC.Locales and GAC.Locales.ES_es and GAC.Locales.ES_es[key] then
        return GAC.Locales.ES_es[key]
    end
    return key
end