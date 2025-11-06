Locales = {}

function _(str, ...)
	if Locales[shared.Locale] then
		if Locales[shared.Locale][str] then
			return string.format(Locales[shared.Locale][str], ...)
		else
			return 'Translation [' .. shared.Locale .. '][' .. str .. '] does not exist'
		end
	end

	return 'Language [' .. shared.Locale .. '] does not exist'
end

function _U(str, ...)
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
