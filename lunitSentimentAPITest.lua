local lunit = require("lunit")
local http = require("socket.http") -- luasocket
local json = require("json") -- luajson
local ltn12 = require("ltn12")
local log = require("logging")
module("sentiment_api_testcase", lunit.testcase, package.seeall)


local logger = log.new(function(self, level, message)
    print(level, message)
    return true
end)

logger:setLevel (log.WARN)

--[[ Test the Response Status
-- The server sends back the traditional HTTP response codes
-- For a successful information exchange, we expect the status to be "OK"
--]]
function test_status()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=All%20our%20knowledge%20begins%20with%20the%20senses%2C%20proceeds%20then%20to%20the%20understanding%2C%20and%20ends%20with%20reason"..
                "&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])
    local expected_status = "OK"
    local actual_status = table["status"]

    assert_equal(expected_status, actual_status)
end

--[[ Test the Response Status for an Invalid apikey
-- The apiKey is a required parameter. Without it, the request cannot be fulfilled
--]]
function test_status_invalid_apiKey()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey="..
                "&text=All%20our%20knowledge%20begins%20with%20the%20senses%2C%20proceeds%20then%20to%20the%20understanding%2C%20and%20ends%20with%20reason"..
                "&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])
    local expected_status = "ERROR"
    local actual_status = table["status"]

    local expected_statusInfo = "invalid-api-key"
    local actual_statusInfo = table["statusInfo"]

    assert_equal(expected_status, actual_status)
    assert_equal(expected_statusInfo, actual_statusInfo)
end

--[[ Test the Number of Transactions
-- A single request to a server should result in one transaction
--]]
function test_num_transactions()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=All%20our%20knowledge%20begins%20with%20the%20senses%2C%20proceeds%20then%20to%20the%20understanding%2C%20and%20ends%20with%20reason"..
                "&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_num_transactions = "1"
    local actual_num_transactions = table["totalTransactions"]

    assert_equal(expected_num_transactions, actual_num_transactions)
end

--[[ Test the Language
-- Test weather the API recognises the language given a certain text
--]]
function test_language()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=All%20our%20knowledge%20begins%20with%20the%20senses%2C%20proceeds%20then%20to%20the%20understanding%2C%20and%20ends%20with%20reason"..
                "&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_language = "english"
    local actual_language = table["language"]

    assert_equal(expected_language, actual_language)
end

--[[ Test the Sentiment Type
-- Given a certain text, the Sentiment API should detect if it's positive, negative or neutral
--]]
function test_type_neutral()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=adjective"..
                "&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_type = "neutral"
    local actual_sentiment_type = table["docSentiment"]["type"]

    assert_equal(expected_sentiment_type, actual_sentiment_type)
end

--[[ Test the Sentiment Type
-- Given a certain text, the Sentiment API should detect if it's positive, negative or neutral
--]]
function test_type_negative()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=hate&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_type = "negative"
    local actual_sentiment_type = table["docSentiment"]["type"]

    assert_equal(expected_sentiment_type, actual_sentiment_type)
end

--[[ Test the Score Attribute for a Given Negative text
-- The score is a quantifier of how negative a sentiment is.
--]]
function test_type_negative()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=hate&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_score = "-0.810031"
    local actual_sentiment_score = table["docSentiment"]["score"]

    assert_equal(expected_sentiment_score, actual_sentiment_score)
end

--[[ Test the Score Attribute for a Given Positive text
-- The score is a quantifier of how psoitive a sentiment is.
--]]
function test_type_negative()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=love&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_score = "0.587138"
    local actual_sentiment_score = table["docSentiment"]["score"]

    assert_equal(expected_sentiment_score, actual_sentiment_score)
end

--[[ Test the Sentiment Type
-- Given a certain text, the Sentiment API should detect if it's positive, negative or neutral
--]]
function test_type_positive()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTextSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=love&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_type = "positive"
    local actual_sentiment_type = table["docSentiment"]["type"]

    assert_equal(expected_sentiment_type, actual_sentiment_type)
end

--[[ Test a targeted, positive sentiment.
-- The TextGetTargetedSentiment API call is used to extract a sentiment targeted towards a user-specified phrase from within
-- the posted text document
--]]
function test_targeted_positive_sentiment()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTargetedSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=Today%20was%20good.%20Today%20was%20fun.%20Tomorrow%20is%20another%20one&targets=good|fun&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_type = "positive"
    local actual_sentiment_type = table["results"][1]["sentiment"]["type"]

    assert_equal(expected_sentiment_type, actual_sentiment_type)
end

--[[ Test a targeted, negative sentiment.
-- The TextGetTargetedSentiment API call is used to extract a sentiment targeted towards a user-specified phrase from within
-- the posted text document
--]]
function test_targeted_negative_sentiment()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTargetedSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=Everything%20negative%20-%20pressure%2C%20challenges%20-%20is%20all%20an%20opportunity%20for%20me%20to%20rise&targets=negative&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])

    local expected_sentiment_type = "negative"
    local actual_sentiment_type = table["results"][1]["sentiment"]["type"]

    assert_equal(expected_sentiment_type, actual_sentiment_type)
end

--[[ Test a targeted sentiment without specifying the target.
-- The TextGetTargetedSentiment API call needs at least one target to function properly
--]]
function test_targeted_sentiment_invalid_targets()

    local response = {}

    --- send the request
    local code, status, header = http.request {
        method = "POST",
        url = "http://gateway-a.watsonplatform.net/calls/text/TextGetTargetedSentiment?apikey=49e910d612035b3f2db73c49a7b6e6a35e27045c"..
                "&text=Everything%20negative%20-%20pressure%2C%20challenges%20-%20is%20all%20an%20opportunity%20for%20me%20to%20rise&targets=&outputMode=json",
        sink = ltn12.sink.table(response)
    }

    local table = json.decode(response[1])
    local expected_status = "ERROR"
    local actual_status = table["status"]

    assert_equal(expected_status, actual_status)
end

