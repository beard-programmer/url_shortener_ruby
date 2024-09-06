-- Define the character set for Base58
local ALPHABET_BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

-- Convert the Base58 alphabet to a character table
local charset = {}
for i = 1, #ALPHABET_BASE58 do
    charset[i] = ALPHABET_BASE58:sub(i, i)
end

-- Function to convert a number to Base58 representation
local function numberToBase58(n)
    local result = ""
    while n > 0 do
        local remainder = (n - 1) % 58
        result = charset[remainder + 1] .. result
        n = math.floor((n - remainder) / 58)
    end
    return result
end

-- Function to generate sequential Base58 strings
local function generateBase58Sequence(start, count)
    local results = {}
    for i = start, start + count - 1 do
        table.insert(results, numberToBase58(i))
    end
    return results
end

-- Initialize Base58 sequence
local startIndex = 1
local numberOfItems = 10500100  -- Number of sequences to generate
local base58Values = generateBase58Sequence(startIndex, numberOfItems)

-- Counter for Base58 values
local counter = 1

-- Function to generate HTTP request with sequential Base58 values
request = function()
    -- Generate the current suffix using the counter
    local suffix = base58Values[counter]

    -- Increment counter for the next request
    counter = counter + 1
    if counter > #base58Values then
        counter = 1  -- Loop back to the beginning if needed
    end

    -- Create the HTTP request body
    local body = '{"short_url": "https://short.est/' .. suffix .. '"}'

    -- Return the HTTP request to be sent
    return wrk.format("POST", "/decode", {["Content-Type"] = "application/json"}, body)
end