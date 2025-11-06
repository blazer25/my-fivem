Locales = {}

function _(str, ...)
	if Locales[cfg.lang] then
		if Locales[cfg.lang][str] then
			return string.format(Locales[cfg.lang][str], ...)
		else
			return 'Translation [' .. cfg.lang .. '][' .. str .. '] does not exist'
		end
	end

	return 'Language [' .. cfg.lang .. '] does not exist'
end

function lang(str, ...)
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
