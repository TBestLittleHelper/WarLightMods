function Dump(obj)
	if obj.proxyType ~= nil then
		DumpProxy(obj);
		elseif type(obj) == 'table' then
		DumpTable(obj);
		else
		print('Dump ' .. type(obj));
	end
end
function DumpTable(tbl)
    for k,v in pairs(tbl) do
        print('k = ' .. tostring(k) .. ' (' .. type(k) .. ') ' .. ' v = ' .. tostring(v) .. ' (' .. type(v) .. ')');
	end
end
function DumpProxy(obj)
	
	print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end

function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

function map(array, func)
	local new_array = {}
	local i = 1;
	for _,v in pairs(array) do
		new_array[i] = func(v);
		i = i + 1;
	end
	return new_array
end


function filter(array, func)
	local new_array = {}
	local i = 1;
	for _,v in pairs(array) do
		if (func(v)) then
			new_array[i] = v;
			i = i + 1;
		end
	end
	return new_array
end

function first(array, func)
	for _,v in pairs(array) do
		if (func(v)) then
			return v;
		end
	end
	return nil;
end

function randomFromArray(array)
	local len = #array;
	local i = math.random(len);
	return array[i];
end

function startsWith(str, sub)
	
	
	return string.sub(str, 1, string.len(sub)) == sub;
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
		end
	end
	
    return false
end


function tablelength(T)
	local count = 0
	for _ in pairs(T) do 
		print(count)
	count = count + 1 end
	return count
end

function addToSet(set, key)
    set[key] = true
end

function removeFromSet(set, key)
    set[key] = nil
end

function setContains(set, key)
    return set[key] ~= nil
end

function toint(n)
	local s = tostring(n)
	local i, j = s:find('%.')
	if i then
		return tonumber(s:sub(1, i-1))
		else
		return n
	end
end

function randomColor()	
	--List given by Fizzer. 74 diffrent colors
	local PossibleColors = "00A0FF#00B5FF#F3FFAE#43C731#43C631#1274A4#1274A5#B03B3B#0021FF#359029#00E9FF#00FF21#FFF700#AA3A3A#43C732#00D4FF#B03C3C#00F4FF#00BFFF#4EC4FF#FFFF00#615DDF#100C08#943E3E#0000ff#4effff#59009d#008000#ff7d00#ff0000#606060#00ff05#ff697a#94652e#00ff8c#ff4700#009b9d#23a0ff#ac0059#ff87ff#ffff00#943e3e#feff9b#ad7e7e#b70aff#ffaf56#ff00b1#8ebe57#DAA520#990024#00FFFF#8F9779#880085#00755E#FFE5B4#4169E1#FF43A4#8DB600#40826D#C04000#FFDDF4#CD7F32#C19A6B#C09999#B0BF1A#3B7A57#4B5320#664C28#893F45#D2691E#36454F#FF00FF#76FF7A#100C08"
	
	local randomStart = math.random(0,73) *7;
	local color = string.sub(PossibleColors, randomStart,randomStart+6);
	
	return color;
end