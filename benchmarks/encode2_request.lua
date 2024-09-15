-- Define the character set for Base58
local ALPHABET_BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

-- Convert the Base58 alphabet to a character table
local charset = {}
for i = 1, #ALPHABET_BASE58 do
    table.insert(charset, ALPHABET_BASE58:sub(i, i))
end

-- Function to generate random strings
local function randomString(length)
    math.randomseed(os.time() + math.random())
    if length > 0 then
        return randomString(length - 1) .. charset[math.random(1, #charset)]
    else
        return ""
    end
end

-- HTTP request function to be called for each request
request = function()
    -- Random string appended to URL
    local random_path = randomString(2)
    local random_domain = randomString(5)
    local body = '{"url": "https://subdomain-' .. random_domain .. '-something..io/library/react-' .. random_path .. '"}'

    -- Return the HTTP request to be sent
    return wrk.format("POST", "/encode2", {["Content-Type"] = "application/json"}, body)
end
