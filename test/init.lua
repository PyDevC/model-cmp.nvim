local testconnect = require("test.test_connect")
local testghosttext = require("test.test_ghosttext")
local testhighspeed = require("test.test_high_speed")

local assert = require("luassert")
local async = require("plenary.async")
local plenary = require("plenary")

local describe = require("plenary/busted").describe
local it = require("plenary/busted").it

describe("ghosttext", function()
  it("test ghosttext suggestion", function()
    testghosttext.test_suggestion()
  end)
end)
