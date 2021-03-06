local class = require('code.libs.middleclass')

local Log = class('Log')

function Log:initiallize() 
  -- need to save data to client?
end

function Log:insert(msg, event, date)
  date = date or os.time()    
  
  self[#self+1] = {
    msg = msg,
    event = event,
    date = date,
  }
end

function Log:append(msg) self[#self].msg = self[#self].msg..'  '..msg end

function Log:reset() for i=1, #self do self[i] = nil end end

local second = 1
local minute = second*60
local hour = minute*60
local day = hour*24
local week = day*7
local month = week*4
local year = month*12

local function getTimeStamp(date)  -- time in seconds
  local time_passed = os.difftime(os.time(), date)
  local num, unit 
  
  if minute > time_passed then       num, unit = second, 'second'
  elseif hour > time_passed then     num, unit = minute, 'minute'
  elseif day > time_passed then      num, unit = hour, 'hour'
  elseif week > time_passed then     num, unit = day, 'day'
  elseif month > time_passed then    num, unit = week, 'week'
  elseif year > time_passed then     num, unit = month, 'month'
  else                               num, unit = year, 'year'
  end
  
  local amount = math.floor(time_passed/num)
  local suffix = amount > 1 and 's' or ''  -- plural or singular
  return '('..amount..' '..unit..suffix..' ago)'
end

function Log:read()
  local list = {}
  for _, incident in ipairs(self) do  -- sort this by day
    local date = os.date('%x', incident.date)
    local index

    -- splits our list into indexes based date
    if #list == 0 then index = 1
    else index = (date == os.date('%x', list[#list].date) and #list) or #list+1 
    end

    list[index] = list[index] or {date=incident.date, collapsed=true, events={}}  -- create an empty index if no events present
    
    local event_tbl = list[index].events
    event_tbl[#event_tbl+1] = incident.msg..' '..getTimeStamp(incident.date) 
  end
  return list
end

return Log