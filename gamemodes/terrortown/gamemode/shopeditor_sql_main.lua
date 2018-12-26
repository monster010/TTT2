local tableName = "ttt2_items"

local db_version = CreateConVar("ttt2_item_db_version", "1", {FCVAR_ARCHIVE})

function ShopEditor.BuildInsertString(name, item, keys)
	keys = keys or ShopEditor.savingKeys

	local tmp = {}

	for key, data in pairs(keys) do
		if item[key] then
			local dat = item[key]

			if data.typ == "bool" then
				dat = dat and 1 or 0
			end

			tmp[key] = dat
		end
	end

	local str = "INSERT INTO " .. tableName .. " (name"

	for k in pairs(tmp) do
		str = str .. "," .. k
	end

	str = str .. ") VALUES ('" .. name .. "'"

	for _, v in pairs(tmp) do
		str = str .. ",'" .. v .. "'"
	end

	str = str .. ")"

	return str
end

function ShopEditor.BuildUpdateString(name, item, keys)
	keys = keys or ShopEditor.savingKeys

	local tmp = {}

	for key, data in pairs(keys) do
		if item[key] then
			local dat = item[key]

			if data.typ == "bool" then
				dat = dat and 1 or 0
			end

			tmp[key] = dat
		end
	end

	local b = true
	local str = "UPDATE " .. tableName .. " SET "

	for k, v in pairs(tmp) do
		if not b then
			str = str .. ","
		end

		b = false
		str = str .. k .. "='" .. v .. "'"
	end

	str = str .. " WHERE name='" .. name .. "'"

	return str
end

function ShopEditor.CreateSqlTable()
	local result

	if not sql.TableExists(tableName) then
		result = sql.Query("CREATE TABLE " .. tableName .. " (name TEXT PRIMARY KEY, credits INTEGER, globalLimited INTEGER, minPlayers INTEGER)")
	else
		local version = db_version:GetInt()

		if version < 1 or version > 1 then
			print("[TTT2][SQL] There is an error with your sql table...")
		end
	end

	return result ~= false
end

function ShopEditor.InitItem(name, item, keys)
	return sql.Query(ShopEditor.BuildInsertString(name, item, keys))
end

function ShopEditor.SaveItem(name, item, keys)
	return sql.Query(ShopEditor.BuildUpdateString(name, item, keys))
end

function ShopEditor.LoadItem(name, item, keys)
	keys = keys or ShopEditor.savingKeys

	local result = sql.Query("SELECT * FROM " .. tableName .. " WHERE name = '" .. name .. "'")

	if not result or not result[1] then
		return false, false
	end

	local changed = false

	for k, v in pairs(result[1]) do
		for key, data in pairs(keys) do
			if k == key and (not item[k] or item[k] ~= v) then
				if data.typ == "number" then
					item[k] = tonumber(v)
				elseif data.typ == "bool" then
					item[k] = tobool(v)
				else
					item[k] = v
				end

				changed = true
			end
		end
	end

	return true, changed
end
