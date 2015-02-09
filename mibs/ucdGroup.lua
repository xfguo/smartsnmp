-- 
-- This file is part of SmartSNMP
-- Copyright (C) 2014, Credo Semiconductor Inc.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-- 

local mib = require "smartsnmp"
local io = require "io"

local loadavg_info

local getLoadavg = function()
	local procfs_loadavg = io.lines("/proc/loadavg")()
	local la1, la5, la10 = procfs_loadavg:match(
			 "^(%d+\.%d+) (%d+\.%d+) (%d+\.%d+) .*$")
	local laTable = {}
	local la_time_mapping = {1, 5, 15}

	for i, la in ipairs{la1, la5, la10} do
		local _la_dict = {}
		local _la = tonumber(la)

		_la_dict.index = i
		_la_dict.names = string.format("Load-%d", la_time_mapping[i])
		_la_dict.load = string.format("%.2f", _la)
		_la_dict.loadInt = math.floor(_la * 100)
		_la_dict.loadFloat = _la
		
		laTable[i] = _la_dict
	end
	return laTable
end

loadavg_info = getLoadavg()

local getLoadavgInfoFactory = function(k)
	-- TODO: cache the results
	return function (i)
		loadavg_info = getLoadavg()
		return loadavg_info[i][k]
	end
end

local laIndex		= 1
local laNames		= 2
local laLoad		= 3
local laLoadInt		= 5
local laLoadFloat	= 6

local ucdGroup = {
	[10] = {
		[1] = {
			indexes = loadavg_info,
			[laIndex]	= mib.ConstInt(getLoadavgInfoFactory("index")),
			[laNames]	= mib.ConstOctString(getLoadavgInfoFactory("names")),
			[laLoad]	= mib.ConstOctString(getLoadavgInfoFactory("load")),
			[laLoadInt]	= mib.ConstInt(getLoadavgInfoFactory("loadInt")),
--			[laLoadFloat]	= mib.ConstInt(getLoadavgInfoFactory("loadFloat")),
		}
	}
}

return ucdGroup
