-- Define the Base58 alphabet
local ALPHABET_BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
local BASE58 = 58

-- Function to encode an integer into a Base58 string
local function encode(key)
    local encoded = ""

    -- Perform Base58 encoding
    while key > 0 do
        local remainder = key % BASE58
        encoded = ALPHABET_BASE58:sub(remainder + 1, remainder + 1) .. encoded
        key = math.floor(key / BASE58)
    end

    return encoded
end

-- Example usage
local integer_to_encode = 657508406
local base58_string = encode(integer_to_encode)

-- Counter for Base58 values
local counter = 0

-- Function to generate HTTP request with sequential Base58 values
request = function()
    local suffix = encode(integer_to_encode + counter)
    counter = counter + 1
    -- Create the HTTP request body
    local body = '{"short_url": "https://short.est/' .. suffix .. '"}'

    -- Return the HTTP request to be sent
    return wrk.format("POST", "/decode", {["Content-Type"] = "application/json"}, body)
end